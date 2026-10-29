# obs-py

```python
from obs import setup_observability, track_inference

setup_observability(service="inference-api", team="ai-platform")

@track_inference(model_arg="model")
def generate(model: str, prompt: str):
    ...
    return {"text": out, "input_tokens": n_in, "output_tokens": n_out}
```

What you get:
- OTel tracing to the node's agent collector (`OTEL_EXPORTER_OTLP_ENDPOINT`, default `http://otel-agent-collector.observability:4317`)
- Resource attributes `service.name`, `team`, `deployment.environment`, `k8s.cluster.name`
- JSON logs with `trace_id` / `span_id` injected
- Prometheus metrics on `:9464/metrics`: `inference_request_duration_seconds`, `inference_tokens_total`, `inference_requests_total`
- `call_model` spans with GenAI semantic-convention attributes
