resource "hcloud_load_balancer" "load_balancer" {
  name               = "${var.base_name}-load-balancer"
  load_balancer_type = "lb11"
  location           = "fsn1"
  delete_protection  = false
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "https"
  destination_port = 30080

  http {
    redirect_http = true
    certificates = [
      hcloud_managed_certificate.wildcard.id,
    ]
  }

  depends_on = [hcloud_load_balancer.load_balancer]

  health_check {
    protocol = "http"
    port     = 30880
    interval = 30
    timeout  = 5
    retries  = 5

    http {
      path         = "/ping"
      status_codes = ["200"]
    }
  }
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  #network_id       = hcloud_network.private_network.id
  network_id = data.terraform_remote_state.kubernetes_network.outputs.network_id

  #depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_load_balancer.load_balancer]
  depends_on = [hcloud_load_balancer.load_balancer]
}

locals {
  vm_ids = flatten([
    for vm_key, val in module.vm[*] : [
      val.master01.vm_id
    ]
  ])
}
resource "hcloud_load_balancer_target" "load_balancer_target" {
  ##for_each = { for idx, server in hcloud_server.worker_nodes : idx => server }
  for_each = var.create_lb_targets ? toset(local.vm_ids) : []
  #for_each = toset(local.vm_ids)

  type             = "server"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  server_id        = each.value
  use_private_ip   = true

  #depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_load_balancer_network.lb_network, hcloud_server.worker_nodes]
  depends_on = [local.vms]
}
