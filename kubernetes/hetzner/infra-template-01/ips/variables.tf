variable "hcloud_token" {
  sensitive = true
}

variable "ips" {
  type = map(object({
    name              = string,
    datacenter        = string,
    type              = string,
    assignee_type     = string,
    labels            = map(string),
    delete_protection = bool,
    auto_delete       = bool
  }))
  default = {
    "VAR_VM_NAME_MASTER" = {
      name          = "VAR_VM_LABEL_MASTER"
      datacenter    = "VAR_IP_DATACENTER"
      type          = "ipv4"
      assignee_type = "server"
      labels = {
        "vm" : "VAR_VM_LABEL_MASTER"
      }
      delete_protection = false
      auto_delete       = false
    }
  }
}

