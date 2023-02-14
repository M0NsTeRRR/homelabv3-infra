terraform {
  source = "../../../..//modules/vsphere_vm"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vsphere_host = "server1.unicornafk.fr"
  vm_name      = "worker1"
  template     = "packer-debian"

  hardware = {
    num_cpus = 4
    memory   = 20480
  }

  disk = {
    datastore = "SERVER1-RAID1"
    size      = 20
  }

  vm_ip  = "192.168.10.91"
  vm_ip6 = "2a0c:b641:2c0:110::91"
}
