terraform {
  source = "../../../..//modules/vsphere_vm"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vsphere_host = "server3.unicornafk.fr"
  vm_name      = "worker3"
  template     = "packer-debian"

  hardware = {
    num_cpus = 4
    memory   = 20480
  }

  disk = {
    datastore = "SERVER3-RAID1"
    size      = 20
  }

  vm_ip  = "192.168.10.93"
  vm_ip6 = "2a0c:b641:2c0:110::93"
}
