variable "network_name" {
  type    = string
  default = "network-1"
}

variable "network_zone" {
  type    = string
  default = "eu-central"
}

variable "network_ip_range" {
  type    = string
  default = "10.0.96.0/20" # 10.0.96.1 - 10.0.111.254, 4096 hosts
}

variable "subnet_ip_range" {
  type    = string
  default = "10.0.98.0/23" # 10.0.98.1 - 10.0.99.254, 512 hosts
}
