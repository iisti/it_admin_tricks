resource "hcloud_firewall" "fw_egress" {
  name = "${var.base_name}-fw_egress"

  #########################
  #### EGRESS
  #########################

  # ICMP / PING, anywhere
  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # TCP, anywhere
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "any"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # UDP, anywhere
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "any"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "fw_ingress" {
  name = "${var.base_name}-fw_ingress"

  #########################
  #### INGRESSS
  #########################

  # ICMP / PING, anywhere
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "node_internal" {
  name = "${var.base_name}-fw_node_internal"
  # All internal TCP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      data.terraform_remote_state.kubernetes_network.outputs.private_network_subnet,
    ]
  }

  # All Internal UDP
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "any"
    source_ips = [
      data.terraform_remote_state.kubernetes_network.outputs.private_network_subnet,
    ]
  }
}

resource "hcloud_firewall" "fw_kubernetes_api" {
  name = "${var.base_name}-fw_kubernetes_api"
  # k3s master node port
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.ips_kubernetes_api_ingress
  }
}


resource "hcloud_firewall" "fw_ssh" {
  name = "${var.base_name}-fw_ssh"

  # SSH
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ips_ssh_ingress
  }
}
