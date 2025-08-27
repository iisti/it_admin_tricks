# Tell Terraform to include the hcloud provider
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
    prefix = "VAR_GCS_PREFIX_NETWORKS"
  }
}

# Configure the Hetzner Cloud Provider with your token
provider "hcloud" {
  token = var.hcloud_token
}

module "network" {
  source = "../../modules/hcloud_network"

  network_name     = var.conf.network_name
  network_ip_range = var.conf.network_ip_range
  subnet_ip_range  = var.conf.subnet_ip_range
}
