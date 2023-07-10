output "vm_id" {
  value       = proxmox_vm_qemu.vm.id
  description = "VM ressource id"
}

output "vm_hostname" {
  value       = var.vm_hostname
  description = "VM hostname"
}

output "domain" {
  value       = var.domain
  description = "VM domain"
}

output "vm_tags" {
  value       = var.vm_tags
  description = "VM tags"
}

output "vm_ip" {
  value       = var.vm_ip
  description = "VM IP"
}

output "vm_ip6" {
  value       = var.vm_ip6
  description = "VM IPv6"
}

output "server_used" {
  value       = var.target_node
  description = "Server used to deploy the instance"
}