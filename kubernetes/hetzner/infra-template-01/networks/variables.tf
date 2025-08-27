# Declare the hcloud_token variable in .tfvars
variable "hcloud_token" {
  sensitive = true
}

# Remember to set backend block variables in main.tf!
variable "conf" {
  type = map(string)
  default = {
    network_name     = "VAR_NETWORK_NAME"
    network_ip_range = "VAR_NETWORK_IP_RANGE"
    subnet_ip_range  = "VAR_SUBNET_IP_RANGE"
  }
}
