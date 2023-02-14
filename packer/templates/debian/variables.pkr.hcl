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

variable "vcenter_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vcenter_server" {
  type    = string
  default = ""
}

variable "vcenter_username" {
  type    = string
  default = ""
}

variable "distribution" {
  type    = string
  default = "debian"
}

variable "version" {
  type    = string
  default = "11.6.0"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
}
