variable "prefix" {
  type = string
}
variable "team" {
  type = string
}
variable "account_alias" {
  type = string
}
variable "yace_role_arn" {
  description = "IRSA role ARN of YACE in the hub account"
  type        = string
}
variable "escalation_policy_id" {
  type = string
}
