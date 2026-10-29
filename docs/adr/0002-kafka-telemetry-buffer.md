# ADR 0002: Kafka between log collectors and stores

**Status:** Accepted
**Context:** Backend outages (Loki, ClickHouse) must not lose logs; multiple consumers need the same stream.
**Decision:** Fluent Bit → Kafka (RF 3, 72 h retention) → Vector consumer groups.
**Consequences:** Kafka must be operated (Strimzi) or bought (MSK / Event Hubs). Consumer lag becomes a key platform signal.
