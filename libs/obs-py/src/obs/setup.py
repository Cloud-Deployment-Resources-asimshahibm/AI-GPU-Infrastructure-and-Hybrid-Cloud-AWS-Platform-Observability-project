import json
import logging
import os
import sys
from typing import Optional

from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, SpanExporter
from prometheus_client import start_http_server

_STATE = {"configured": False, "service": None}


class JsonFormatter(logging.Formatter):
    # One JSON object per line with trace context for log-to-trace links in Grafana.
    def __init__(self, service: str):
        super().__init__()
        self.service = service

    def format(self, record: logging.LogRecord) -> str:
        span = trace.get_current_span()
        ctx = span.get_span_context()
        payload = {
            "timestamp": self.formatTime(record, "%Y-%m-%dT%H:%M:%S%z"),
            "level": record.levelname.lower(),
            "service": self.service,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if ctx.is_valid:
            payload["trace_id"] = format(ctx.trace_id, "032x")
            payload["span_id"] = format(ctx.span_id, "016x")
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        for key, value in getattr(record, "extra_fields", {}).items():
            payload[key] = value
        return json.dumps(payload)


def setup_observability(
    service: str,
    team: str,
    env: Optional[str] = None,
    metrics_port: Optional[int] = 9464,
    span_exporter: Optional[SpanExporter] = None,
    log_level: int = logging.INFO,
) -> TracerProvider:
    # Configure tracing, metrics endpoint and JSON logging. Safe to call once per process.
    if _STATE["configured"]:
        return trace.get_tracer_provider()

    resource = Resource.create({
        "service.name": service,
        "team": team,
        "deployment.environment": env or os.getenv("DEPLOY_ENV", "prod"),
        "k8s.cluster.name": os.getenv("CLUSTER_NAME", "unknown"),
    })
    provider = TracerProvider(resource=resource)
    if span_exporter is None:
        from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
        endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-agent-collector.observability:4317")
        span_exporter = OTLPSpanExporter(endpoint=endpoint, insecure=endpoint.startswith("http://"))
    provider.add_span_processor(BatchSpanProcessor(span_exporter))
    trace.set_tracer_provider(provider)

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter(service))
    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(log_level)

    if metrics_port:
        start_http_server(metrics_port)

    _STATE.update(configured=True, service=service)
    return provider


def get_tracer(name: str = "obs"):
    return trace.get_tracer(name)
