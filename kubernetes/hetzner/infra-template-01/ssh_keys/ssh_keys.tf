resource "hcloud_ssh_key" "admin" {
  name       = var.ssh_key_admin.name
  public_key = var.ssh_key_admin.public_key
  labels = {
    ssh_key = var.ssh_key_admin.label
  }
}
