#!/usr/bin/env bash
# Wraps promtool-format rule files into PrometheusRule CRs for Argo CD. CI fails if output differs from what is committed.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p ../gitops/manifests/rules
for f in *.yaml; do
  name="${f%.yaml}"
  {
    echo "apiVersion: monitoring.coreos.com/v1"
    echo "kind: PrometheusRule"
    echo "metadata:"
    echo "  name: ${name}"
    echo "  namespace: monitoring"
    echo "  labels: { scope: global }"
    echo "spec:"
    sed 's/^/  /' "$f"
  } > "../gitops/manifests/rules/${name}.yaml"
done
