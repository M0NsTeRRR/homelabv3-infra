output "server_used" {
  value       = data.vsphere_host.host.name
  description = "Server used to deploy the instance"
}

output "instance_name" {
  value       = format("%s.%s", var.vm_name, var.domain)
  description = "The FQDN of the VM"
}
