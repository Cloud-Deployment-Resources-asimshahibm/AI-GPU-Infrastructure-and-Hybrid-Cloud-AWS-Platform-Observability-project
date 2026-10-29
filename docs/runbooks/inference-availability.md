# Inference API SLO burn

**What it means:** Error budget for inference-api is burning fast.

## How to check
1. Open *AI inference service* dashboard.
2. Click an exemplar on the error panel → Tempo trace → Loki logs.
3. Check GPU saturation and vLLM queue depth.

## How to fix
Roll back last deploy (Argo CD), scale replicas, or shed load at the gateway.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
