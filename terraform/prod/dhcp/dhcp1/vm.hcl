locals {
  target_node = "server1"
  vm_hostname = "dhcp1"
  vm_tags     = ["ansible_managed", "dhcp"]

  cores  = 1
  memory = 3072

  disk = {
    storage = "SSD1"
    size    = 20
  }

  vm_ip  = "192.168.10.23"
  vm_ip6 = "2a0c:b641:2c0:110::23"
}