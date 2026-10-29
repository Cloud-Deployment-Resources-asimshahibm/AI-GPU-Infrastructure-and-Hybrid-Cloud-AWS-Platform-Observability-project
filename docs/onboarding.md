# Onboarding a service (target: < 1 hour)

1. Add the chart dependency:
```yaml
# Chart.yaml
dependencies:
  - name: observability-onboarding
    version: 0.1.0
    repository: oci://ghcr.io/asimshahibm/charts
```
2. Set values:
```yaml
observability:
  service: embeddings-api
  team: ai-platform
  tier: 1
  port: http-metrics
  slo: { availability: 99.5, latencyThresholdSeconds: 0.8 }
  gpu: true
```
3. Instrument code: `pip install obs-py` then `setup_observability(service="embeddings-api", team="ai-platform")`.
4. Merge. Argo CD deploys; your dashboard appears in Grafana folder `ai-platform`; SLO alerts route to your PagerDuty service.
