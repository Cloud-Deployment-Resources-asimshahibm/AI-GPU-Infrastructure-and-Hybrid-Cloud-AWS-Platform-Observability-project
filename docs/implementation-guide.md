# Implementation guide

Work through the phases in order. Each has exit criteria; do not start the next production wave until they pass.

## Phase 0 — Design sign-off
1. Fill in `docs/sizing.md` with today's volumes (series, log GB/day, spans/s, GPU nodes) and 3x growth.
2. Agree platform SLOs (`docs/design.md#platform-slos`).
3. Confirm tenancy model (one tenant per team) and SSO groups.
4. Review `docs/adr/` with SRE, security and network; get change approval.

## Phase 1 — Foundation
```bash
cd terraform/live/prod/aws   && cp terraform.tfvars.example terraform.tfvars && terraform init && terraform apply
cd ../azure                  && cp terraform.tfvars.example terraform.tfvars && terraform init && terraform apply
cd ../pagerduty              && cp terraform.tfvars.example terraform.tfvars && terraform init && terraform apply
cp ansible/inventory/hosts.example.ini ansible/inventory/hosts.ini   # list on-prem GPU hosts
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/gpu-node-observability.yml
```
Install Argo CD (HA) on the hub cluster, register every cluster with label `obs=enabled` and a `role` label
(`hub`, `gpu`, `aws`, `azure`), then:
```bash
kubectl apply -n argocd -f gitops/bootstrap/project.yaml
kubectl apply -n argocd -f gitops/bootstrap/root-app.yaml
```
Exit: all clusters Healthy in Argo CD; buckets reachable through workload identity.

## Phase 2 — Metrics
Argo CD syncs `kube-prometheus-stack`, `gpu-operator`, `cloud-exporters`, `thanos`, `grafana`.
Verify:
```bash
kubectl -n monitoring get prometheus -o wide               # 2 replicas per cluster
kubectl -n gpu-operator get pods | grep dcgm               # exporter on every GPU node
curl -s thanos-query.example.com/api/v1/query?query=count(DCGM_FI_DEV_GPU_UTIL)
```
Load test: `kubectl apply -f loadtest/avalanche-job.yaml`.

## Phase 3 — Logs
Argo CD syncs `strimzi`, `kafka` manifests, `fluent-bit`, `vector`, `loki`, `clickhouse`.
Apply ClickHouse schema: `kubectl exec -n observability chi-obs-analytics-0-0-0 -- clickhouse-client --multiquery < gitops/manifests/clickhouse/schema.sql`.
Exit test: scale Loki write path to 0 for 30 min under load; confirm Kafka lag drains to 0 and no gaps.

## Phase 4 — Traces and profiles
Argo CD syncs `opentelemetry-operator`, `otel` manifests, `tempo`, `pyroscope`.
Annotate a namespace for auto-instrumentation:
```bash
kubectl annotate ns ai-inference instrumentation.opentelemetry.io/inject-python=observability/default
```

## Phase 5 — Alerting and SLOs
```bash
promtool test rules alerts/tests/*.yaml
sloth generate -i slos/ -o gitops/manifests/slo-rules/   # CI does this on merge
```
Store PagerDuty integration keys in the secret store under `observability/pagerduty`.

## Phase 6 — Retention and cost
Retention is set in `gitops/values/{thanos,loki,tempo}/values.yaml` and ClickHouse TTLs. See `docs/retention.md`.

## Phase 7 — Gap detection
Deploy `tools/coverage-scorecard` (Argo CD app `coverage-scorecard`). Edit `tools/coverage-scorecard/catalog.yaml`.

## Phase 8 — Self-service
Teams add `charts/observability-onboarding` as a dependency and use `libs/obs-py` or `libs/obs-go`.

## Phase 9 — Rollout
Follow `docs/rollout.md` waves.

## Phase 10 — Game days
`chaos/` experiments; postmortems in `docs/postmortems/` using the template.

## Phases 11–12 — Governance and day-2
`docs/review-checklist.md`, `docs/day2-operations.md`, Renovate.
