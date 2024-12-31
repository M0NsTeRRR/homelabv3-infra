locals {
  target_node = "server1"
  vm_hostname = "worker1"
  vm_tags     = ["ansible_managed", "kubernetes", "kubernetes_worker"]

  cores  = 8
  memory = 32768

  disk = {
    storage = "SSD1"
    size    = 80
  }

  additionnal_disks = [
    {
      storage = "SSD1"
      size    = 1000
    }
  ]

  vm_ip  = "192.168.10.91"
  vm_ip6 = "2a0c:b641:2c0:110::91"
}