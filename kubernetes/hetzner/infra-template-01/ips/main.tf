terraform {
  required_version = ">= VAR_TF_VERSION"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= VAR_HCLOUD_VERSION"
    }
  }

  backend "gcs" {
    bucket = "VAR_GCS_BUCKET"
    prefix = "VAR_GCS_PREFIX_IPS"
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

module "ip" {
  source = "../../modules/hcloud_ip"

  for_each          = var.ips
  name              = each.value.name
  datacenter        = each.value.datacenter
  type              = each.value.type
  assignee_type     = each.value.assignee_type
  labels            = each.value.labels
  delete_protection = each.value.delete_protection
  auto_delete       = each.value.auto_delete
}

