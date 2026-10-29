# DCGM exporter down

**What it means:** GPU telemetry missing from a node — you are blind to GPU faults.

## How to check
1. `kubectl -n gpu-operator get pods -o wide | grep dcgm`.
2. Check driver status on host.

## How to fix
Restart the exporter pod; if the driver is broken, drain the node.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
