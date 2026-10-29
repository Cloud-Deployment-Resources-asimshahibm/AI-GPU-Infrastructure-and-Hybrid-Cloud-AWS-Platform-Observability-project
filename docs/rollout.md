# Rollout waves

| Wave | Scope | Paging | Exit |
| --- | --- | --- | --- |
| 1 | dev + staging clusters | Slack only | 1 week stable, sizing confirmed |
| 2 | one production EKS or AKS cluster | Slack only, parallel with existing tools | incidents match old tooling for 2 weeks |
| 3 | on-prem GPU clusters, rack by rack | Slack only | DCGM/fabric metrics match hardware team tools |
| 4 | remaining clusters + cloud accounts | Slack only | scorecard green |
| Cutover | per team | PagerDuty from new Alertmanager | 2 weeks parity, old alerts muted 1 more week |

Every wave: change ticket, rollback = Argo CD revert to previous commit, named owner on call, post-change review.
