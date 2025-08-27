# Declare the hcloud_token variable in .tfvars
variable "hcloud_token" {
  sensitive = true
}

variable "ssh_key_pub_admin_name" {
}

variable "ssh_key_pub_admin" {
}

variable "ssh_key_worker" {
  sensitive = true
}

variable "ssh_key_pub_worker" {
}

variable "base_name" {
  type        = string
  description = "Base name of the project."
  default     = "VAR_PROJECT"
}

variable "tld_domain_name" {
  type    = string
  default = "VAR_TLD_DOMAIN_NAME"
}

variable "sub_domain_name" {
  type    = string
  default = "VAR_SUB_DOMAIN_NAME"
}

variable "create_lb_targets" {
  type    = bool
  default = true
}

variable "master_ip_internal" {
  type    = string
  default = "VAR_MASTER_IP_INTERNAL"
}

variable "vms" {
  type = map(object({
    vm_name                    = string,
    base_name                  = string,
    vm_image                   = string,
    vm_type                    = string,
    vm_datacenter              = string,
    vm_backups                 = bool,
    vm_delete_protection       = bool,
    vm_rebuild_protection      = bool,
    ssh_key_label              = string,
    network_name               = string,
    private_ip                 = string,
    public_ip_label            = string,
    user_data_file             = string,
    ssh_key_pub_admin          = string,
    database_password          = string,
    cifs_user                  = string,
    cifs_pw                    = string,
    database_certificate_email = string,
    vm_labels                  = map(string),
    delete_protection          = bool,
    auto_delete                = bool
  }))
  default = {
    "VAR_VM_NAME_MASTER" = {
      vm_name                    = "VAR_VM_NAME_MASTER",
      base_name                  = "VAR_BASE_NAME",
      vm_image                   = "VAR_VM_IMAGE",
      vm_type                    = "VAR_VM_TYPE",
      vm_datacenter              = "VAR_VM_DATACENTER",
      vm_backups                 = VAR_VM_BACKUPS,
      vm_delete_protection       = VAR_VM_DELETE_PROTECTION,
      vm_rebuild_protection      = VAR_VM_REBUILD_PROTECTION,
      ssh_key_label              = "VAR_SSH_KEY_LABEL",
      network_name               = "VAR_NETWORK_NAME",
      private_ip                 = "VAR_MASTER_IP_INTERNAL",
      public_ip_label            = "VAR_PUBLIC_IP_LABEL_MASTER",
      user_data_file             = "VAR_USER_DATA_FILE_MASTER",
      ssh_key_pub_admin          = null,
      database_password          = null,
      cifs_user                  = null,
      cifs_pw                    = null,
      database_certificate_email = "VAR_DATABASE_CERTIFICATE_EMAIL",
      vm_labels = {
        "vm" = "VAR_VM_LABEL_MASTER"
      }
      delete_protection = VAR_DELETE_PROTECTION_MASTER
      auto_delete       = VAR_AUTO_DELETE_MASTER
    }
  }
}

variable "ips_ssh_ingress" {
  type = list(string)
  default = [
    VAR_IPS_SSH_INGRESS,
  ]
}

variable "ips_kubernetes_api_ingress" {
  type = list(string)
  default = [
    VAR_IPS_KUBERNETES_API_INGRESS,
  ]
}
