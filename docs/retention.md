# Retention and cost

| Signal | Hot | Long-term | Config |
| --- | --- | --- | --- |
| Metrics raw | 2 d (Prometheus) | 30 d | `gitops/values/thanos/values.yaml` `compactor.retentionResolutionRaw` |
| Metrics 5 m | — | 90 d | `compactor.retentionResolution5m` |
| Metrics 1 h | — | 395 d | `compactor.retentionResolution1h` |
| Logs (app) | — | 30 d (debug 7 d) | `gitops/values/loki/values.yaml` `limits_config` |
| Logs (audit) | — | 365 d | tenant `security` override |
| Inference analytics | — | 180 d | `gitops/manifests/clickhouse/schema.sql` TTL |
| Traces | — | 14 d | `gitops/values/tempo/values.yaml` `block_retention` |
| Profiles | — | 14 d | `gitops/values/pyroscope/values.yaml` |

Object storage lifecycle (Terraform): transition to IA / Cool after 30 days; expire after the longest retention + 7 days.

## Cost model
Per tenant per month = (series × $/series) + (log GB × $/GB) + (spans × $/M spans). Platform usage metrics:
`loki_distributor_bytes_received_total`, `tempo_distributor_spans_received_total`, `prometheus_tsdb_head_series` by `team`.
