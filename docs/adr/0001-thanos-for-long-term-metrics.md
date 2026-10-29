# ADR 0001: Thanos for long-term metrics

**Status:** Accepted
**Context:** Metrics from many clusters (on-prem GPU, EKS, AKS) need a global view, HA dedup and 13-month history on object storage.
**Options:** Thanos (sidecar), Grafana Mimir, VictoriaMetrics cluster, Prometheus federation.
**Decision:** Thanos with sidecars. Keeps Prometheus as the local source of truth, survives hub outages (local alerting continues),
uses cheap object storage, supports downsampling.
**Consequences:** More components (store, compactor, query). Revisit if active series exceed ~50M or query latency SLO is missed —
evaluate Mimir/VictoriaMetrics via the bake-off in Phase 11.
