import functools
import inspect
import time
from typing import Any, Callable

from opentelemetry import trace
from opentelemetry.trace import Status, StatusCode
from prometheus_client import Counter, Histogram

REQUEST_DURATION = Histogram(
    "inference_request_duration_seconds", "End-to-end model call latency",
    ["model", "status"], buckets=(0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10, 30, 60),
)
TOKENS = Counter("inference_tokens_total", "Tokens processed", ["model", "direction"])
REQUESTS = Counter("inference_requests_total", "Model calls", ["model", "status"])


def _record(span, model: str, result: Any, started: float, status: str) -> None:
    elapsed = time.perf_counter() - started
    REQUEST_DURATION.labels(model, status).observe(elapsed)
    REQUESTS.labels(model, status).inc()
    if isinstance(result, dict):
        for key, direction in (("input_tokens", "input"), ("output_tokens", "output")):
            n = result.get(key)
            if isinstance(n, int):
                TOKENS.labels(model, direction).inc(n)
                span.set_attribute(f"gen_ai.usage.{key}", n)


def track_inference(model_arg: str = "model", span_name: str = "call_model") -> Callable:
    # Decorator for functions that call a model. The function may return a dict with
    # input_tokens / output_tokens to record token usage. Works for sync and async functions.
    def decorator(fn: Callable) -> Callable:
        sig = inspect.signature(fn)
        tracer = trace.get_tracer("obs.inference")

        def _model(args, kwargs) -> str:
            bound = sig.bind_partial(*args, **kwargs)
            return str(bound.arguments.get(model_arg, "unknown"))

        if inspect.iscoroutinefunction(fn):
            @functools.wraps(fn)
            async def async_wrapper(*args, **kwargs):
                model = _model(args, kwargs)
                started = time.perf_counter()
                with tracer.start_as_current_span(span_name) as span:
                    span.set_attribute("gen_ai.request.model", model)
                    try:
                        result = await fn(*args, **kwargs)
                    except Exception as exc:
                        span.record_exception(exc)
                        span.set_status(Status(StatusCode.ERROR))
                        _record(span, model, None, started, "error")
                        raise
                    _record(span, model, result, started, "ok")
                    return result
            return async_wrapper

        @functools.wraps(fn)
        def wrapper(*args, **kwargs):
            model = _model(args, kwargs)
            started = time.perf_counter()
            with tracer.start_as_current_span(span_name) as span:
                span.set_attribute("gen_ai.request.model", model)
                try:
                    result = fn(*args, **kwargs)
                except Exception as exc:
                    span.record_exception(exc)
                    span.set_status(Status(StatusCode.ERROR))
                    _record(span, model, None, started, "error")
                    raise
                _record(span, model, result, started, "ok")
                return result
        return wrapper
    return decorator
