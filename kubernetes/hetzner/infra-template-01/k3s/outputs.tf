output "vm_ids" {
  value = local.vm_ids
}

output "vms" {
  value = local.vms
}

output "lb_ips" {
  value = [hcloud_load_balancer.load_balancer.ipv4]
}
