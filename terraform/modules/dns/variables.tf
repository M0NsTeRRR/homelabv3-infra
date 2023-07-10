variable "vm_hostname" {
  description = "VM name"
  type        = string
}

variable "domain" {
  description = "VM domain"
  type        = string
}

variable "vm_ip" {
  description = "VM IP"
  type        = string
}

variable "vm_ip6" {
  description = "VM IPv6"
  type        = string
}

variable "reverse_zone" {
  description = "IPv4 reverse zone"
  type        = string
}

variable "reverse_zone6" {
  description = "IPv6 reverse zone"
  type        = string
}