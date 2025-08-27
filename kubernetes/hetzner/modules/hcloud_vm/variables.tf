variable "ssh_key_pub_admin" {
  type = string
}

variable "vm_name" {
  type = string
}

# is this actually required?
variable "base_name" {
  type = string
}

variable "vm_image" {
  type        = string
  description = "Instance image name."
  default     = "rocky-9"
}

variable "vm_type" {
  type        = string
  description = "Instance type."
  default     = "cpx21"
  validation {
    condition     = contains(["cx11", "cx21", "cx22", "cx31", "cx32", "cx41", "cx42", "cx51", "cx52", "cpx11", "cpx21", "cpx31", "cpx41", "cpx51", "ccx12", "ccx22", "ccx32", "ccx42", "ccx52", "ccx62", "ccx13", "ccx23", "ccx33", "ccx43", "ccx53", "ccx63", "cax11", "cax21", "cax31", "cax41"], lower(var.vm_type))
    error_message = "Unsupported server type."
  }
}

variable "vm_datacenter" {
  type    = string
  default = "fsn1-dc14"
}

variable "vm_backups" {
  type    = bool
  default = false
}

variable "vm_delete_protection" {
  type    = bool
  default = false
}

variable "vm_rebuild_protection" {
  type    = bool
  default = false
}

variable "ssh_key_label_admin" {
  default = "ssh_key=admin"
}

variable "network_name" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "public_ip_label" {
  type = string
}

variable "user_data" {
  type = string
}

variable "vm_labels" {
  type = map(string)
}
