variable "host_ip" {
  type    = string
  default = ""
}

variable "http_port" {
  type    = number
  default = 8888
}

variable "ssh_new_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh_password" {
  type    = string
  default = ""
}

variable "ssh_password_encrypted" {
  type    = string
  default = ""
}

variable "ssh_fullname" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "ssh_autorized_key" {
  type    = string
  default = ""
}

variable "proxmox_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "proxmox_url" {
  type    = string
  default = ""
}

variable "proxmox_username" {
  type    = string
  default = ""
}

variable "proxmox_node" {
  type    = string
  default = ""
}

variable "distribution" {
  type    = string
  default = "ubuntu"
}

variable "version" {
  type    = string
  default = "22.04.2"
}

variable "vm_ip" {
  type    = string
  default = "192.168.20.80"
}

variable "vm_netmask" {
  type    = string
  default = "255.255.255.0"
}

variable "vm_gateway_ip" {
  type    = string
  default = "192.168.20.2"
}

variable "vm_dns_ip" {
  type    = string
  default = "9.9.9.9"
}