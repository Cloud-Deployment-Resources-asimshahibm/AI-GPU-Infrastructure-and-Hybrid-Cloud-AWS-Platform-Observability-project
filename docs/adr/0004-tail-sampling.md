# ADR 0004: Two-tier OTel Collector with tail sampling

**Status:** Accepted
**Decision:** Agents forward to a load-balancing tier that routes by `trace_id` to a tail-sampling tier.
Keep 100% of error and slow (>2 s) traces, 10% of the rest.
**Consequences:** Sampling tier needs memory for `decision_wait` (10 s) of traffic; scale on `otelcol_processor_tail_sampling_*`.
