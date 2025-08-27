variable "zone" {
  type        = string
  description = "Domain Name / Domain Zone"
}

variable "name" {
  type        = string
  description = "Name of the DNS record."
}

variable "value" {
  type        = string
  description = "Value of the DNS record."
}

variable "type" {
  type        = string
  description = "Type of the DNS record."
}

variable "ttl" {
  type        = number
  description = "TTL value of the DNS record."
  default     = 3600
}
