variable "http_server_name" {
  type    = string
  default = "192.168.30.21"
}

variable "http_port" {
  type    = number
  default = 8888
}

variable "ssh_fullname" {
  type    = string
  default = "ludovic ortega"
}

variable "ssh_username" {
  type    = string
  default = "lortega"
}

variable "ssh_password" {
  type    = string
  default = "ludovic"
}

variable "ssh_password_encrypted" {
  type    = string
  default = "$6$rounds=4096$z0Sg0elddrnKbQkP$JIDnEJBLfwgLQQNPs966.2x2q2IPS/ybaIY0nVLEDQ9owg4VtbTV0k11DPPkm.rUMpOgOjonqETzgZK8FubYD/"
}

variable "ssh_autorized_key_file_path" {
  type    = string
  default = "../../../ssh_pub_keys/lortega.pub"
}

variable "proxmox_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "proxmox_url" {
  type    = string
  default = "https://server1.unicornafk.fr:8006/api2/json"
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

variable "proxmox_node" {
  type    = string
  default = "server1"
}

variable "distribution" {
  type    = string
  default = "ubuntu"
}

variable "version" {
  type    = string
  default = "24.04.3"
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
  default = "192.168.20.1"
}

variable "vm_dns_ip" {
  type    = string
  default = "192.168.10.21"
}
