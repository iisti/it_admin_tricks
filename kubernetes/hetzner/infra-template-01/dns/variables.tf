variable "api_token" {
  sensitive = true
}

variable "ttl" {
  type    = number
  default = 3600
}
