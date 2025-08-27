terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.52.0"
    }
  }
  required_version = ">= 1.12.0"
}

resource "hcloud_primary_ip" "this" {
  name              = var.name
  datacenter        = var.datacenter
  type              = var.type
  assignee_type     = var.assignee_type
  labels            = var.labels
  delete_protection = var.delete_protection
  auto_delete       = var.auto_delete
}

