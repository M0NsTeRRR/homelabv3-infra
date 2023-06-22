resource "powerdns_record" "dns_A" {
  zone    = "${var.domain}."
  name    = "${var.vm_hostname}.${var.domain}."
  type    = "A"
  ttl     = 3600
  records = [var.vm_ip]
}

resource "powerdns_record" "dns_AAAA" {
  zone    = "${var.domain}."
  name    = "${var.vm_hostname}.${var.domain}."
  type    = "AAAA"
  ttl     = 3600
  records = [var.vm_ip6]
}

resource "powerdns_record" "dns_PTR_ipv4" {
  zone    = "${var.reverse_zone}."
  name    = "${join(".", reverse(split(".", var.vm_ip)))}.in-addr.arpa."
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_hostname}.${var.domain}."]
}

data "external" "reverse_ptr_ipv6" {
  program = ["python3", "${path.module}/scripts/reverse_ptr_ipv6.py", var.vm_ip6]
}

resource "powerdns_record" "dns_PTR_ipv6" {
  zone    = "${var.reverse_zone6}."
  name    = data.external.reverse_ptr_ipv6.result.reversed
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_hostname}.${var.domain}."]

  depends_on = [data.external.reverse_ptr_ipv6]
}

data "external" "sshfp" {
  program = ["python3", "${path.module}/scripts/sshfp.py", "${var.vm_ip}"]
}

resource "powerdns_record" "dns_SSHFP" {
  zone    = "${var.domain}."
  name    = "${var.vm_hostname}.${var.domain}."
  type    = "SSHFP"
  ttl     = 3600
  records = [data.external.sshfp.result.sshfp]

  depends_on = [data.external.sshfp]
}