locals {
  vsphere_host = "server3.unicornafk.fr"
  vm_hostname  = "worker3"
  vm_tags      = ["ansible_managed", "kubernetes", "kubernetes_worker"]

  hardware = {
    num_cpus = 2
    memory   = 32768
  }

  disk = {
    datastore = "SERVER3-RAID1"
    size      = 40
  }

  vm_ip  = "192.168.10.93"
  vm_ip6 = "2a0c:b641:2c0:110::93"
}