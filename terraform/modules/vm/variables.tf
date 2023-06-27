variable "terraform_root_dir" {
  description = "Terraform root directory"
  type        = string
}

variable "ignore_providers" {
  description = "Providers to ignore"
  type        = list(string)
  default     = []
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
  type        = string
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  type        = string
}

variable "vsphere_host" {
  description = "vSphere host"
  type        = string
}

variable "vsphere_domain" {
  description = "vSphere domain"
  type        = string
}

variable "vm_hostname" {
  description = "VM hostname"
  type        = string
}

variable "domain" {
  description = "VM domain"
  type        = string
}

variable "vm_tags" {
  description = "VM tags"
  type = list(string)
}

variable "template" {
  description = "Template name"
  type = string
}

variable "hardware" {
  description = "Hardware informations"
  type = object({
    num_cpus = number
    memory   = number
  })
}

variable "vm_ip" {
  description = "VM IP"
  type        = string
}

variable "vm_ip6" {
  description = "VM IPv6"
  type        = string
}

variable "vm_user" {
  description = "User"
  type        = string
  sensitive   = true
}

variable "disk" {
  description = "Disk size in Gb"
  type = object({
    datastore = string
    size      = number
  })
}

variable "network" {
  description = "Network config"
  type = object({
    name     = string
    netmask  = string
    gateway  = string
    netmask6 = string
    gateway6 = string
  })
}