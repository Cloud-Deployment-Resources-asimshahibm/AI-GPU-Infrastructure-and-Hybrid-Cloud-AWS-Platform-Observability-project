# Watchdog heartbeat missing

**What it means:** The alerting pipeline itself is broken.

## How to check
1. Check Alertmanager pods and Thanos Ruler.
2. Check meta-monitoring stack.

## How to fix
Restore Alertmanager/Ruler; until fixed, watch dashboards manually.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
