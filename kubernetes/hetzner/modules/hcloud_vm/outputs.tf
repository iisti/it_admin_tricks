output "vm_name" {
  description = "Name of the VM."
  value       = hcloud_server.vm.name
}

/*
output "private_ip" {
  description = "Private IP of the VM."
  value       = hcloud_server.vm.network
}
*/

output "vm_ip_public" {
  description = "Public IP of the VM."
  value       = hcloud_server.vm.ipv4_address
}
/*
output "network_id" {
  description = "Network ID."
  value       = hcloud_server.vm.network.id
}*/

output "vm_image" {
  description = "Instance image."
  value       = hcloud_server.vm.image
}

output "vm_datacenter" {
  description = "Instance datacenter."
  value       = hcloud_server.vm.datacenter
}

output "vm_id" {
  description = "Insance ID."
  value       = hcloud_server.vm.id
}
