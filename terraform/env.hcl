locals {
  vsphere_datacenter = "Homelab"
  vsphere_cluster    = "HA"
  dns = {
    server_list = ["192.168.10.21", "192.168.10.22", "2a0c:b641:2c0:110::21", "2a0c:b641:2c0:110::22"]
    suffix_list = ["unicornafk.fr", "adminafk.fr", "as212510.net"]
  }
  terraform_root_dir = get_parent_terragrunt_dir()
}
