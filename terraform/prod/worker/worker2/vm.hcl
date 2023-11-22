locals {
  target_node = "server2"
  vm_hostname = "worker2"
  vm_tags     = ["ansible_managed", "kubernetes", "kubernetes_worker"]

  cores  = 6
  memory = 16384

  disk = {
    storage = "SSD1"
    size    = 20
  }

  additionnal_disks = [
    {
      storage = "SSD1"
      size    = 1000
    }
  ]

  vm_ip  = "192.168.10.92"
  vm_ip6 = "2a0c:b641:2c0:110::92"
}