terraform {
  required_version = ">= 1.10"
  required_providers {
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket       = "acme-terraform-state"
    key          = "observability/prod/pagerduty.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

# Token from env var PAGERDUTY_TOKEN
provider "pagerduty" {}
