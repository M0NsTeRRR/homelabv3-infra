locals {
  vsphere_host = "server3"
  vm_hostname  = "master3"
  vm_tags      = ["ansible_managed", "kubernetes", "kubernetes_master"]

  hardware = {
    num_cpus = 2
    memory   = 4096
  }

  disk = {
    datastore = "RAID1"
    size      = 40
  }

  vm_ip  = "192.168.10.83"
  vm_ip6 = "2a0c:b641:2c0:110::83"
}