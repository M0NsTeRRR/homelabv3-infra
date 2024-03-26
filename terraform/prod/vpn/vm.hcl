locals {
  target_node = "server3"
  vm_hostname = "vpn"
  vm_tags     = ["ansible_managed", "vpn"]

  cores  = 2
  memory = 2048

  disk = {
    storage = "SSD1"
    size    = 20
  }

  vm_ip  = "192.168.10.70"
  vm_ip6 = "2a0c:b641:2c0:110::70"
}