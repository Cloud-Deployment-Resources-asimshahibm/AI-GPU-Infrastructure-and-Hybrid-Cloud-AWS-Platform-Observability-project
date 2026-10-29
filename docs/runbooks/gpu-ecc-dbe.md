# GPU double-bit ECC error

**What it means:** Uncorrectable memory errors on a GPU.

## How to check
1. Confirm `DCGM_FI_DEV_ECC_DBE_VOL_TOTAL` increase.
2. Check row-remap status with `nvidia-smi -q -d ROW_REMAPPER`.

## How to fix
Drain node; schedule GPU reset or RMA.

## Escalate to
Observability platform on-call → owning team (`team` label) → data center operations for hardware.
