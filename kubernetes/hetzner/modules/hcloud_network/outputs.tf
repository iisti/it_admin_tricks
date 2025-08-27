output "network_name" {
  description = "Network name"
  value       = var.network_name
}

output "network_zone" {
  description = "Network zone"
  value       = var.network_zone
}

output "network_ip_range" {
  description = "Network IP range"
  value       = var.network_ip_range
}

output "private_network_subnet" {
  description = "Private network subnet"
  value       = var.subnet_ip_range
}

output "network_id" {
  description = "Network ID"
  value       = hcloud_network.private_network.id
}
