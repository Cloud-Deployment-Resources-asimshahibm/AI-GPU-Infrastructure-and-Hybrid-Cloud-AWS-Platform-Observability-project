variable "subscription_id" {
  type = string
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "prefix" {
  type    = string
  default = "acme"
}
variable "vnet_cidr" {
  type    = string
  default = "10.50.0.0/16"
}
