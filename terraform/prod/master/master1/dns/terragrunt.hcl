terraform {
  source = "${get_parent_terragrunt_dir()}/modules//dns"
}

include {
  path = find_in_parent_folders()
}

dependency "vm" {
  config_path = "../vm"
}

inputs = {
  vm_id = dependency.vm.outputs.vm_id,
  vm_hostname = dependency.vm.outputs.vm_hostname,
  domain = dependency.vm.outputs.domain,
  vm_ip = dependency.vm.outputs.vm_ip,
  vm_ip6 = dependency.vm.outputs.vm_ip6
}

dependencies {
  paths = ["../vm"]
}