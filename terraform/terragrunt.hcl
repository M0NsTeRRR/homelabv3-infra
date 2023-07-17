terraform_version_constraint  = "v1.5.3"
terragrunt_version_constraint = "v0.48.2"

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  network_vars = read_terragrunt_config(find_in_parent_folders("network.hcl"))

  vsphere_server     = local.account_vars.locals.vsphere_server
  vsphere_user       = local.account_vars.locals.vsphere_user
  vsphere_password   = local.account_vars.locals.vsphere_password
  vsphere_datacenter = local.env_vars.locals.vsphere_datacenter
  vsphere_cluster    = local.env_vars.locals.vsphere_cluster

  powerdns_api_key    = local.account_vars.locals.powerdns_api_key
  powerdns_server_url = local.account_vars.locals.powerdns_server_url

  network = local.network_vars.locals.network
  domain  = local.network_vars.locals.domain
}

terraform {
  before_hook "before_cache" {
    commands = [get_terraform_command()]
    execute  = ["mkdir", "-p", abspath("${get_parent_terragrunt_dir()}/build/terraform")]
  }
  extra_arguments "cache" {
    commands = [get_terraform_command()]
    env_vars = {
      TF_PLUGIN_CACHE_DIR = abspath("${get_parent_terragrunt_dir()}/build/terraform")
    }
  }
}
download_dir = abspath("${get_parent_terragrunt_dir()}/.terragrunt-cache")

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.4.1"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "1.5.0"
    }
  }
}

provider "vsphere" {
  vsphere_server = "${local.vsphere_server}"
  user           = "${local.vsphere_user}"
  password       = "${local.vsphere_password}"
}

provider "powerdns" {
  api_key    = "${local.powerdns_api_key}"
  server_url = "${local.powerdns_server_url}"
}
EOF
}

inputs = merge(
  local.account_vars.locals,
  local.env_vars.locals,
  local.network_vars.locals,
)
