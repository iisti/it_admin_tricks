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
    prefix = "VAR_GCS_PREFIX_K3S"
  }
}

# Configure the Hetzner Cloud Provider with your token
provider "hcloud" {
  token = var.hcloud_token
}

/*
data "hcloud_network" "kubernetes" {
  name = "kubernetes"
}*/

data "terraform_remote_state" "kubernetes_network" {
  backend = "gcs"

  config = {
    bucket = "VAR_GCS_BUCKET"
    prefix = "VAR_GCS_PREFIX_NETWORKS"
  }
}

/*
data "hcloud_primary_ip" "public" {
  with_selector = var.vms.public_ip_label_master
}*/

locals {
  vms = flatten([
    for vm_key, val in module.vm[*] : {
      vm_id        = val.master01.vm_id,
      vm_name      = val.master01.vm_name
      vm_ip_public = val.master01.vm_ip_public
    }
  ])
}

module "vm" {
  source = "../../modules/hcloud_vm"

  #depends_on = [hcloud_ssh_key.admin]

  for_each  = var.vms
  vm_name   = each.value.vm_name
  base_name = each.value.base_name
  vm_image  = each.value.vm_image
  #vm_type                    = each.value.vm_type
  #vm_datacenter              = each.value.vm_datacenter 
  #vm_backups                 = each.value.vm_backups
  #vm_delete_protection       = each.value.vm_delete_protection
  #vm_rebuild_protection      = each.value.vm_rebuild_protection
  #ssh_key_label_admin = each.value.ssh_key_label_admin
  network_name    = each.value.network_name
  private_ip      = each.value.private_ip
  public_ip_label = each.value.public_ip_label
  #source_ips_database = each.value.source_ips_database
  #source_ips_ssh      = each.value.source_ips_ssh
  user_data = templatefile(each.value.user_data_file, {
    ssh_key_pub_admin  = var.ssh_key_pub_admin
    ssh_key_pub_worker = var.ssh_key_pub_worker
    ##ssh_key_pub_christianweichselbaum = var.ssh_key_pub_christianweichselbaum
    #db_pw              = var.database_password
    #postgres_path_data = "/var/lib/pgsql/12/data/"
    #email_cert         = each.value.database_certificate_email
    #cifs_user          = var.cifs_user
    #cifs_pw            = var.cifs_pw
  })
  ssh_key_pub_admin = each.value.ssh_key_pub_admin
  #database_password          = each.value.database_password
  #cifs_user                  = each.value.cifs_user
  #cifs_pw                    = each.value.cifs_pw
  #database_certificate_email = each.value.database_certificate_email
  vm_labels = each.value.vm_labels
  #delete_protection = each.value.delete_protection
  #auto_delete       = each.value.auto_delete

  # Edit user data to install required software.

}


# Add more firewall rules if required
resource "hcloud_firewall_attachment" "basic_egress" {
  firewall_id     = hcloud_firewall.fw_egress.id
  label_selectors = ["VAR_FW_LABEL_MASTER"]
}

resource "hcloud_firewall_attachment" "basic_ingress" {
  firewall_id     = hcloud_firewall.fw_ingress.id
  label_selectors = ["VAR_FW_LABEL_MASTER"]
}

resource "hcloud_firewall_attachment" "ssh" {
  firewall_id     = hcloud_firewall.fw_ssh.id
  label_selectors = ["VAR_FW_LABEL_MASTER"]
}

resource "hcloud_firewall_attachment" "kubernetes_api" {
  firewall_id     = hcloud_firewall.fw_kubernetes_api.id
  label_selectors = ["VAR_FW_LABEL_MASTER"]
}
