# Day-2 operations

- **On-call:** platform rotation in PagerDuty service `observability-platform`; paged by meta-monitoring.
- **Upgrades:** Renovate PRs → dev → staging → one prod cluster → all (Argo CD sync waves, 24 h canary).
- **Capacity review (monthly):** series, log GB/day, spans/s vs `docs/sizing.md`; scale before 70%.
- **Weekly health review:** platform SLOs, top tenants by growth, alert precision, open postmortem actions.
- **Security (quarterly):** certificate/credential rotation check, Grafana access review, Trivy image scan results.
- **DR drill (quarterly):** restore Grafana DB, point Thanos Query at replica bucket.
