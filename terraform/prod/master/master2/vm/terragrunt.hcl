locals {
  vm_vars = read_terragrunt_config(find_in_parent_folders("vm.hcl"))

  terraform_root_dir = get_parent_terragrunt_dir()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//vm"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../../../tag"]
}

inputs = merge(
  local.vm_vars.locals,
  { "terraform_root_dir" = "${local.terraform_root_dir}" }
)