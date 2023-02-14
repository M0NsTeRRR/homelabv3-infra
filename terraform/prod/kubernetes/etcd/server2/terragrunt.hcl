terraform {
  source = "../../../..//modules/vsphere_vm"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vsphere_host = "server2.unicornafk.fr"
  vm_name      = "etcd2"
  template     = "packer-debian"

  hardware = {
    num_cpus = 2
    memory   = 4096
  }

  disk = {
    datastore = "SERVER2-RAID1"
    size      = 20
  }

  vm_ip  = "192.168.10.82"
  vm_ip6 = "2a0c:b641:2c0:110::82"
}
