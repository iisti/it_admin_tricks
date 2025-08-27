output "all_values" {
  description = "All values"
  value       = values(hcloud_primary_ip.this)[*]
}

output "all_info" {
  description = "All information"
  value       = hcloud_primary_ip.this
}
