output "a" {
  value       = var.vm_ip
  description = "IPv4 record"
}

output "aaaa" {
  value       = var.vm_ip6
  description = "IPv6 record"
}
