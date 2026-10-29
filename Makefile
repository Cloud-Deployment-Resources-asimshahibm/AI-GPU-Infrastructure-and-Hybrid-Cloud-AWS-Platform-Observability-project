.PHONY: check tf-fmt tf-validate yaml rules python go helm

check: tf-fmt yaml rules helm python

tf-fmt:
	terraform fmt -check -recursive terraform/

tf-validate:
	for d in terraform/live/prod/*/; do (cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate); done

yaml:
	yamllint -c .yamllint.yaml gitops alerts slos charts

rules:
	promtool check rules alerts/*.yaml
	promtool test rules alerts/tests/*.yaml

helm:
	helm lint charts/observability-onboarding

python:
	cd libs/obs-py && pip install -e .[dev] && pytest -q

go:
	cd libs/obs-go && go vet ./... && go test ./...
