output "cluster_name" {
  value = module.eks.cluster_name
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
