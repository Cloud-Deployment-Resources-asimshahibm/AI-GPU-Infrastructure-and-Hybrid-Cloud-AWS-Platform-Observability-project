# ADR 0003: Loki for search, ClickHouse for analytics

**Status:** Accepted
**Context:** Engineers need cheap log search during incidents; AI/ML teams need fast aggregate queries over inference events.
**Decision:** All logs → Loki. Structured inference events → ClickHouse (ReplicatedMergeTree, 180-day TTL).
**Consequences:** Two stores to run. Elasticsearch kept as a bake-off candidate only.
