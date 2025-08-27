terraform {
  required_providers {
    hetznerdns = {
      source  = "germanbrew/hetznerdns"
      version = ">= 3.4.3"
    }
  }
  required_version = ">= 1.12.0"
}

data "hetznerdns_zone" "zone" {
  name = var.zone
}

resource "hetznerdns_record" "record" {
  zone_id = data.hetznerdns_zone.zone.id
  name    = var.name
  value   = var.value
  type    = var.type
  ttl     = var.ttl
}
