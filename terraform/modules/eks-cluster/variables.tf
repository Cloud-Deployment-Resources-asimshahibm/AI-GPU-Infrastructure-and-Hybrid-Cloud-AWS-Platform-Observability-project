variable "name" {
  type = string
}
variable "kubernetes_version" {
  type    = string
  default = "1.31"
}
variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}
variable "azs" {
  type = list(string)
}
variable "gpu_instance_types" {
  type    = list(string)
  default = ["g5.xlarge"]
}
variable "gpu_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}
variable "gpu_max_size" {
  type    = number
  default = 4
}
variable "tags" {
  type    = map(string)
  default = {}
}
