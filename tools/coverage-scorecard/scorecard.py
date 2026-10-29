#!/usr/bin/env python3
# Checks every catalog service for metrics, logs, traces, SLOs and alerts, and exports the result as
#   obs_coverage_check{service, team, tier, check} = 1 (ok) | 0 (missing)
import os
import time
import urllib.parse
import urllib.request
import json

import yaml
from prometheus_client import Gauge, start_http_server

THANOS = os.getenv("THANOS_URL", "http://thanos-query-frontend.observability:9090")
LOKI = os.getenv("LOKI_URL", "http://loki-gateway.observability")
TEMPO = os.getenv("TEMPO_URL", "http://tempo-query-frontend.observability:3100")
CATALOG = os.getenv("CATALOG", "/config/catalog.yaml")
INTERVAL = int(os.getenv("INTERVAL_SECONDS", "900"))

CHECK = Gauge("obs_coverage_check", "1 if the observability check passes", ["service", "team", "tier", "check"])


def get_json(url: str, headers=None) -> dict:
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())


def prom_nonempty(query: str) -> bool:
    data = get_json(f"{THANOS}/api/v1/query?" + urllib.parse.urlencode({"query": query}))
    return bool(data.get("data", {}).get("result"))


def run_checks(svc: dict) -> dict:
    name, team = svc["name"], svc["team"]
    tenant = {"X-Scope-OrgID": team}
    now = int(time.time())
    checks = {}
    checks["metrics"] = prom_nonempty(f'count(up{{service="{name}"}} == 1)')
    checks["slo"] = prom_nonempty(f'slo:sli_error:ratio_rate5m{{sloth_service="{name}"}}')
    checks["alerts"] = prom_nonempty(f'count(ALERTS{{service="{name}"}}) or count(slo:objective:ratio{{sloth_service="{name}"}})')
    try:
        logs = get_json(f"{LOKI}/loki/api/v1/query_range?" + urllib.parse.urlencode(
            {"query": f'count_over_time({{app="{name}"}}[1h])', "start": (now - 3600) * 10**9, "limit": 1}), tenant)
        checks["logs"] = bool(logs.get("data", {}).get("result"))
        checks["logs_have_trace_id"] = bool(get_json(f"{LOKI}/loki/api/v1/query_range?" + urllib.parse.urlencode(
            {"query": f'{{app="{name}"}} |= "trace_id"', "start": (now - 3600) * 10**9, "limit": 1}), tenant)
            .get("data", {}).get("result"))
    except Exception:
        checks["logs"] = checks["logs_have_trace_id"] = False
    try:
        traces = get_json(f"{TEMPO}/api/search?" + urllib.parse.urlencode(
            {"tags": f"service.name={name}", "start": now - 3600, "end": now, "limit": 1}), tenant)
        checks["traces"] = bool(traces.get("traces"))
    except Exception:
        checks["traces"] = False
    return checks


def main() -> None:
    start_http_server(int(os.getenv("PORT", "9100")))
    while True:
        with open(CATALOG) as fh:
            services = yaml.safe_load(fh)["services"]
        for svc in services:
            try:
                results = run_checks(svc)
            except Exception as exc:  # backend down: mark everything unknown-as-failed, keep looping
                print(json.dumps({"level": "error", "service": svc["name"], "message": str(exc)}), flush=True)
                results = {c: False for c in ("metrics", "slo", "alerts", "logs", "logs_have_trace_id", "traces")}
            for check, ok in results.items():
                CHECK.labels(svc["name"], svc["team"], str(svc.get("tier", 2)), check).set(1 if ok else 0)
            print(json.dumps({"level": "info", "service": svc["name"], "checks": results}), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
