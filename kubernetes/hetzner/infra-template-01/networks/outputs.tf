output "network_name" {
  description = "Network name"
  value       = module.network.network_name
}

output "network_zone" {
  description = "Network zone"
  value       = module.network.network_zone
}

output "network_ip_range" {
  description = "Network IP range"
  value       = module.network.network_ip_range
}

output "private_network_subnet" {
  description = "Private network subnet"
  value       = module.network.private_network_subnet
}

output "network_id" {
  description = "Network ID"
  value       = module.network.network_id
}
