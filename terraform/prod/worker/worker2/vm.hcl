locals {
  vsphere_host = "server2"
  vm_hostname  = "worker2"
  vm_tags      = ["ansible_managed", "kubernetes", "kubernetes_worker"]

  hardware = {
    num_cpus = 2
    memory   = 32768
  }

  disk = {
    datastore = "RAID1"
    size      = 40
  }

  vm_ip  = "192.168.10.92"
  vm_ip6 = "2a0c:b641:2c0:110::92"
}