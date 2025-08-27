variable "hcloud_token" {
  sensitive = true
}

variable "ssh_key_admin" {
  type = map(string)
  default = {
    name       = "VAR_SSH_KEY_NAME_ADMIN",
    public_key = "VAR_SSH_KEY_PUBLIC_ADMIN",
    label      = "admin"
  }
}
