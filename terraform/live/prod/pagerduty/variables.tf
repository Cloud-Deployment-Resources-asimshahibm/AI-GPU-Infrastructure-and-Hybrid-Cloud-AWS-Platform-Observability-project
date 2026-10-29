variable "teams" {
  description = "team => list of on-call user emails (in rotation order)"
  type        = map(list(string))
}
variable "rotation_start" {
  type = string
}
