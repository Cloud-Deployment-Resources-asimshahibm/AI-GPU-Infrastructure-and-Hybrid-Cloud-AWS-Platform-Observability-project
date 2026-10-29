# GPU XID error

**What it means:** DCGM reports a non-zero XID on a GPU (hardware or driver fault).

## How to check
1. Open *GPU fleet health* dashboard, filter by `Hostname`.
2. `kubectl describe node <node>`; check `nvidia-smi -q` on host.
3. XID 48/63/64/79 = hardware: cordon and drain.

## How to fix
`kubectl cordon <node> && kubectl drain <node> --ignore-daemonsets --delete-emptydir-data`; open RMA ticket with data center team.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
