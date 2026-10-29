# Observability conventions

## Required labels (all workloads)
`team`, `service`, `env`, `cluster` (added by Prometheus external labels / collectors).

## Metric naming
`<service>_<thing>_<unit>` — e.g. `inference_request_duration_seconds`. Counters end in `_total`.
Never use as labels: user IDs, request IDs, full URLs, pod UIDs, prompts.
Label budget: ≤ 10,000 active series per service unless approved.

## Logs
JSON, one object per line. Required fields: `timestamp`, `level`, `service`, `message`, `trace_id`, `span_id`.
Loki labels (allow-list): `cluster`, `namespace`, `app`, `level`. Everything else is structured metadata.

## Traces
OpenTelemetry semantic conventions. AI spans follow GenAI conventions:
`gen_ai.request.model`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`. Span names: `retrieve_context`,
`call_model`, `stream_tokens`.

## Golden signals per service
Rate, errors, duration (p50/p95/p99), saturation. GPU workloads add GPU utilisation, memory, and time-to-first-token.
