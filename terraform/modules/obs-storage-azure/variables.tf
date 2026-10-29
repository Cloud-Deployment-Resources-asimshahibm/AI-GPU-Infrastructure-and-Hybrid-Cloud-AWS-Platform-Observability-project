variable "prefix" {
  type = string
}
variable "env" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "oidc_issuer_url" {
  type = string
}
variable "service_accounts" {
  description = "writer name => namespace:serviceaccount"
  type        = map(string)
}
variable "tags" {
  type    = map(string)
  default = {}
}
