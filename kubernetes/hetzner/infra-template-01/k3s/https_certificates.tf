resource "hcloud_managed_certificate" "wildcard" {
  name         = "wildcard"
  domain_names = ["*.${var.sub_domain_name}.${var.tld_domain_name}"]
  labels = {
    cert = "wildcard"
  }
}
