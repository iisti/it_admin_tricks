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
    prefix = "VAR_GCS_PREFIX_SSH_KEYS"
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

