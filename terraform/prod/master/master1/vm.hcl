locals {
  target_node = "server1"
  vm_hostname = "master1"
  vm_tags     = ["ansible_managed", "kubernetes", "kubernetes_master"]

  cores  = 2
  memory = 4096

  disk = {
    storage = "SSD1"
    size    = 40
  }

  vm_ip  = "192.168.10.81"
  vm_ip6 = "2a0c:b641:2c0:110::81"
}