# Sizing sheet (fill in)

| Input | Today | 12-month (3x) |
| --- | --- | --- |
| Active series (all clusters) | | |
| Log volume GB/day | | |
| Spans/s (after sampling) | | |
| GPU nodes | | |
| Kubernetes clusters | | |

## Rules of thumb (validate with load tests)
- Prometheus: ~1–2 KB RAM per active series per replica.
- Kafka disk: ingest/day × retention days × RF ÷ brokers, + 30% headroom.
- Loki ingesters: memory for 2–3 h of in-flight chunks per stream set.
- Tempo ingesters: memory for in-flight traces; scale on `tempo_ingester_live_traces`.
- Add 30% headroom to every result; keep components below 70% utilisation.
