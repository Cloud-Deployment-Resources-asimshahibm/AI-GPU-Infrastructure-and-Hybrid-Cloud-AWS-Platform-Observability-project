import json
import logging

import pytest
from opentelemetry.sdk.trace.export.in_memory_span_exporter import InMemorySpanExporter
from prometheus_client import REGISTRY

from obs import setup_observability, track_inference
from obs.setup import JsonFormatter

EXPORTER = InMemorySpanExporter()
PROVIDER = setup_observability(service="test-svc", team="qa", metrics_port=None, span_exporter=EXPORTER)


def flush():
    PROVIDER.force_flush()
    return EXPORTER.get_finished_spans()


def test_span_and_metrics_recorded():
    EXPORTER.clear()

    @track_inference(model_arg="model")
    def generate(model, prompt):
        return {"text": "hi", "input_tokens": 5, "output_tokens": 7}

    generate("llama-3-8b", "hello")
    spans = flush()
    assert spans[-1].name == "call_model"
    assert spans[-1].attributes["gen_ai.request.model"] == "llama-3-8b"
    assert spans[-1].attributes["gen_ai.usage.output_tokens"] == 7
    assert REGISTRY.get_sample_value("inference_tokens_total", {"model": "llama-3-8b", "direction": "output"}) == 7
    assert spans[-1].resource.attributes["team"] == "qa"


def test_error_marks_span():
    EXPORTER.clear()

    @track_inference()
    def broken(model):
        raise RuntimeError("gpu oom")

    with pytest.raises(RuntimeError):
        broken(model="m1")
    span = flush()[-1]
    assert span.status.status_code.name == "ERROR"
    assert REGISTRY.get_sample_value("inference_requests_total", {"model": "m1", "status": "error"}) == 1


def test_json_log_has_trace_id():
    from opentelemetry import trace
    fmt = JsonFormatter("test-svc")
    with trace.get_tracer("t").start_as_current_span("s"):
        rec = logging.LogRecord("x", logging.INFO, __file__, 1, "hello", None, None)
        out = json.loads(fmt.format(rec))
    assert out["service"] == "test-svc"
    assert len(out["trace_id"]) == 32
