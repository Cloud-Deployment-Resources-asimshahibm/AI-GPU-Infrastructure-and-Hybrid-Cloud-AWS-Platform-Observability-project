# Cardinality bomb game day

1. Deploy a canary of any test service with an extra metric label set to a random UUID per request.
2. Expected: `HighCardinalityMetric` ticket fires; `enforcedSampleLimit` rejects the scrape (`up == 0` for that target with
   `scrape_samples_scraped` over the limit); Prometheus memory stays flat.
3. Record time to detect and whether the guardrail held. Remove the canary.
