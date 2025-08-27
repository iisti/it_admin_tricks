variable "name" {
  type    = string
  default = null
}

variable "datacenter" {
  type    = string
  default = "fsn1-dc14"
}

variable "type" {
  type        = string
  description = "IPv4 or IPv6"
  default     = "ipv4"
}

variable "assignee_type" {
  type        = string
  description = "Assignee type (server, etc)"
  default     = "server"
}

variable "labels" {
  type    = map(any)
  default = {}
}

variable "delete_protection" {
  type    = bool
  default = false
}

variable "auto_delete" {
  type    = bool
  default = false
}
