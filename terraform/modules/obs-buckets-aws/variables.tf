variable "prefix" {
  type = string
}
variable "env" {
  type = string
}
variable "kms_key_arn" {
  type = string
}
variable "expire_days" {
  description = "Backstop expiry per signal (longest retention + 7 days)"
  type        = map(number)
  default = {
    metrics  = 402
    logs     = 372
    traces   = 21
    profiles = 21
  }
}
variable "tags" {
  type    = map(string)
  default = {}
}
