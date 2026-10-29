# Observability PR review checklist

- [ ] No new unbounded labels (IDs, URLs, prompts); series estimate stated in PR
- [ ] Every paging alert has `severity`, `team`, `runbook_url` and a `promtool` unit test
- [ ] Alert maps to an SLO or a clear hardware fault
- [ ] Dashboards use template variables (`cluster`, `namespace`, `service`) — no hard-coded values
- [ ] No secrets or PII in log lines or span attributes
- [ ] Retention/tenant limits impact considered
- [ ] Runbook updated if behaviour changes
