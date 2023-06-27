locals {
  vsphere_host = "server1"
  vm_hostname  = "dhcp2-test"
  vm_tags      = ["ansible_managed", "dhcp"]

  hardware = {
    num_cpus = 2
    memory   = 2048
  }

  disk = {
    datastore = "RAID1"
    size      = 15
  }

  vm_ip  = "192.168.10.25"
  vm_ip6 = "2a0c:b641:2c0:110::25"
}