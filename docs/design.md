# Platform design

## Scope
- On-premise AI data center GPU clusters (bare-metal Kubernetes and Slurm hosts)
- AWS EKS clusters and AWS accounts (CloudWatch)
- Azure AKS clusters and subscriptions (Azure Monitor)

## Platform SLOs
| SLO | Target |
| --- | --- |
| Query API availability (Thanos Query, Loki read, Tempo query) | 99.9% / 30 days |
| Breach-to-page latency | p99 < 60 s |
| Telemetry loss on single pod or zone failure | 0 |
| Ingestion success rate (metrics, logs, spans) | 99.95% |

## High availability
- All stateful components spread across 3 zones (`topologySpreadConstraints`, PDBs).
- Prometheus: 2 replicas per cluster, deduplicated by Thanos on `prometheus_replica`.
- Kafka: 3 brokers, RF=3, `min.insync.replicas=2`.
- Loki / Tempo: replication factor 3, zone-aware.
- Alertmanager: 3-replica gossip cluster.
- Dedicated `observability` node pool with taint `dedicated=observability:NoSchedule`.

## Multi-tenancy
- Tenant = team. Derived from namespace label `team`.
- Loki / Tempo / Pyroscope: `X-Scope-OrgID` header, per-tenant limits.
- Thanos: `prom-label-proxy` enforces `team` label for tenant queries.
- Grafana: one folder + team per tenant, mapped from SSO groups.

## Security
- SSO (Keycloak or Entra ID) for Grafana; roles Viewer / Editor / Admin per team.
- TLS everywhere via cert-manager; Kafka SCRAM-SHA-512 over TLS.
- Workload identity (IRSA / Pod Identity, Azure Workload Identity) for object storage; no static keys.
- Secrets via External Secrets Operator from AWS Secrets Manager / Azure Key Vault / Vault.
- Vector redacts secrets and PII before storage.
