# Tell Terraform to include the hcloud provider
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.52.0"
    }
  }
  required_version = ">= 1.12.0"
}

data "hcloud_network" "network" {
  #with_selector = local.private_network_label
  name = var.network_name
}

data "hcloud_ssh_key" "admin_by_label" {
  with_selector = var.ssh_key_label_admin
}

data "hcloud_primary_ip" "public" {
  with_selector = var.public_ip_label
}

locals {
  base_name = var.base_name
  #ssh_key_label_admin = var.ssh_key_label_admin
}

resource "hcloud_server" "vm" {
  name               = var.vm_name
  image              = var.vm_image
  server_type        = var.vm_type
  datacenter         = var.vm_datacenter
  backups            = var.vm_backups
  delete_protection  = var.vm_delete_protection
  rebuild_protection = var.vm_rebuild_protection
  labels             = var.vm_labels

  user_data = var.user_data

  ssh_keys = [data.hcloud_ssh_key.admin_by_label.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
    ipv4         = data.hcloud_primary_ip.public.id
  }
  network {
    network_id = data.hcloud_network.network.id
    ip         = var.private_ip
  }

  depends_on = [
    data.hcloud_network.network,
    data.hcloud_ssh_key.admin_by_label
  ]

  lifecycle {
    # If this is not added, adding ssh_keys will prompt recreation of the vm.
    ignore_changes = [ssh_keys, user_data]
  }
}
