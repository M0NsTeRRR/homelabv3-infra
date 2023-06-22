locals {
  vsphere_host = "server1.unicornafk.fr"
  vm_hostname  = "master1"
  vm_tags      = ["ansible_managed", "kubernetes", "kubernetes_master"]

  hardware = {
    num_cpus = 2
    memory   = 4096
  }

  disk = {
    datastore = "SERVER1-RAID1"
    size      = 40
  }

  vm_ip  = "192.168.10.81"
  vm_ip6 = "2a0c:b641:2c0:110::81"
}