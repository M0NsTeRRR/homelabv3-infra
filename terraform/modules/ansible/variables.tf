variable "terraform_root_dir" {
  description = "Terraform root directory"
  type = string
}

variable "vm_id" {
  description = "VM ressource id"
  type = string
}

variable "vm_hostname" {
  description = "VM name"
  type = string
}

variable "domain" {
  description = "VM domain"
  type = string
}

variable "vm_tags" {
  description = "VM tags"
  type = list(string)
}

variable "vm_ip" {
  description = "VM IP"
  type = string
}

variable "vm_ip6" {
  description = "VM IPv6"
  type = string
}