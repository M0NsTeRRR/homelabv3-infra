terraform_version_constraint  = "v1.12.2"
terragrunt_version_constraint = "v0.81.10"

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  network_vars = read_terragrunt_config(find_in_parent_folders("network.hcl"))

  pm_api_url  = local.account_vars.locals.pm_api_url
  pm_user     = local.account_vars.locals.pm_user
  pm_password = local.account_vars.locals.pm_password

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
    proxmox = {
      source  = "bpg/proxmox"
      version = "=0.78.2"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "=1.5.0"
    }
  }
}

provider "proxmox" {
  endpoint = "${local.pm_api_url}"
  username = "${local.pm_user}"
  password = "${local.pm_password}"
  ssh {
    agent    = true
    username = "root"
  }
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
