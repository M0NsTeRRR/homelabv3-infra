terraform {
  source = "${get_parent_terragrunt_dir()}/modules//ansible"
}

include {
  path = find_in_parent_folders()
}

dependency "vm" {
  config_path = "../vm"
}

inputs = {
  terraform_root_dir = get_parent_terragrunt_dir()
  vm_id = dependency.vm.outputs.vm_id,
  vm_hostname = dependency.vm.outputs.vm_hostname,
  domain = dependency.vm.outputs.domain,
  vm_tags = dependency.vm.outputs.vm_tags,
  vm_ip = dependency.vm.outputs.vm_ip,
  vm_ip6 = dependency.vm.outputs.vm_ip6
}

dependencies {
  paths = ["../vm", "../dns"]
}