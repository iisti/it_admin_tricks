terraform {
  required_providers {
    hetznerdns = {
      source  = "germanbrew/hetznerdns"
      version = ">= VAR_GERMANBREW_HETZNERDNS_VERSION"
    }
  }
  backend "gcs" {
    bucket = "VAR_GCS_BUCKET"
    prefix = "VAR_GCS_PREFIX_DNS"
  }
}

provider "hetznerdns" {
  api_token = var.api_token
}

locals {
  yaml_dns_records = yamldecode(file("dns_records.yaml"))

  dns_records = flatten([
    for zone_key, records in local.yaml_dns_records.records : [
      for record_key, record_values in records : {
        zone  = zone_key
        name  = record_values.name
        value = record_values.value
        type  = record_values.type
        ttl   = try(record_values.ttl, var.ttl)
      }
    ]
  ])
}

module "dns_records" {
  source = "../../modules/hcloud_dns"

  for_each = { for k, v in local.dns_records : "${local.dns_records[k].name}" => v }
  zone     = each.value.zone
  name     = each.value.name
  value    = each.value.value
  type     = each.value.type
  ttl      = each.value.ttl
}
