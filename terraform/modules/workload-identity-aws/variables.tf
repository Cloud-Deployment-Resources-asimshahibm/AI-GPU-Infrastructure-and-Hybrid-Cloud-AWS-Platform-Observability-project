variable "prefix" {
  type = string
}
variable "oidc_provider_arn" {
  type = string
}
variable "kms_key_arn" {
  type = string
}
variable "service_buckets" {
  description = "service name => bucket ARN"
  type        = map(string)
}
variable "service_accounts" {
  description = "service name => list of namespace:serviceaccount"
  type        = map(list(string))
}
