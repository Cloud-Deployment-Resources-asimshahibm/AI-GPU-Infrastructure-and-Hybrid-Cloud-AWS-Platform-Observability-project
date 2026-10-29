variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "kubernetes_version" {
  type    = string
  default = "1.31"
}
variable "gpu_vm_size" {
  type    = string
  default = "Standard_NC4as_T4_v3"
}
variable "gpu_max_count" {
  type    = number
  default = 2
}
variable "tags" {
  type    = map(string)
  default = {}
}
