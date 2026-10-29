resource "aws_kms_key" "obs" {
  description         = "Observability object storage"
  enable_key_rotation = true
}

module "hub" {
  source = "../../../modules/eks-cluster"
  name   = "${var.prefix}-obs-hub-prod"
  azs    = var.azs
}

module "buckets" {
  source      = "../../../modules/obs-buckets-aws"
  prefix      = var.prefix
  env         = "prod"
  kms_key_arn = aws_kms_key.obs.arn
}

module "identity" {
  source            = "../../../modules/workload-identity-aws"
  prefix            = var.prefix
  oidc_provider_arn = module.hub.oidc_provider_arn
  kms_key_arn       = aws_kms_key.obs.arn
  service_buckets = {
    thanos    = module.buckets.bucket_arns["metrics"]
    loki      = module.buckets.bucket_arns["logs"]
    tempo     = module.buckets.bucket_arns["traces"]
    pyroscope = module.buckets.bucket_arns["profiles"]
  }
  service_accounts = {
    thanos    = ["monitoring:kube-prometheus-stack-prometheus", "observability:thanos-storegateway", "observability:thanos-compactor", "observability:thanos-ruler"]
    loki      = ["observability:loki"]
    tempo     = ["observability:tempo"]
    pyroscope = ["observability:pyroscope"]
  }
}

output "role_arns" {
  value = module.identity.role_arns
}
output "buckets" {
  value = module.buckets.bucket_names
}
