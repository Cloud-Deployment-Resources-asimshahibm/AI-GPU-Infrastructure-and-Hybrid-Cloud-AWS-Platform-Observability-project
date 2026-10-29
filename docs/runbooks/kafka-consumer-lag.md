# Vector consumer lag high

**What it means:** Logs are buffering in Kafka; search is delayed.

## How to check
1. Check Loki/ClickHouse health.
2. Check Vector error rate and CPU.

## How to fix
Scale Vector, fix the failing sink; lag drains automatically.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
