variable "terraform_root_dir" {
  description = "Terraform root directory"
  type        = string
}

variable "target_node" {
  description = "Proxmox node"
  type        = string
}

variable "target_node_domain" {
  description = "Proxmox node domain"
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
  type        = list(string)
}

variable "template" {
  description = "Template name"
  type        = string
}

variable "sockets" {
  description = "Number of sockets"
  type        = number
  default     = 1
}

variable "cores" {
  description = "Number of cores"
  type        = number
  default     = 1
}

variable "vcpus" {
  description = "Number of vcpus"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Number of memory in MB"
  type        = number
  default     = 1024
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
    storage = string
    size    = number
  })
}

variable "network" {
  description = "Network config"
  type = object({
    tag      = string
    netmask  = string
    gateway  = string
    netmask6 = string
    gateway6 = string
  })
}