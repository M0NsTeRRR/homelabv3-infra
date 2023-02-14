locals {
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  network_vars = read_terragrunt_config(find_in_parent_folders("network.hcl"))

  vsphere_datacenter = local.env_vars.locals.vsphere_datacenter
  vsphere_cluster    = local.env_vars.locals.vsphere_cluster
  dns                = local.env_vars.locals.dns

  network = local.network_vars.locals.network
  domain  = local.network_vars.locals.domain

  terraform_root_dir = local.env_vars.locals.terraform_root_dir
}

generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    hostname = "${get_env("TF_VAR_tfc_hostname")}"
    organization = "${get_env("TF_VAR_tfc_organization")}"
    workspaces {
      name = "${get_env("TF_VAR_tfc_workspace")}"
    }
    token = "${get_env("TF_VAR_tfc_token")}"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2.0"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5.0"
    }
    discord = {
      source  = "transneptune/discord"
      version = "~> 0.0.1"
    }
  }
}

provider "vsphere" {
  vsphere_server = "${get_env("TF_VAR_vsphere_server")}"
  user           = "${get_env("TF_VAR_vsphere_user")}"
  password       = "${get_env("TF_VAR_vsphere_password")}"
}

provider "powerdns" {
  api_key    = "${get_env("TF_VAR_powerdns_api_key")}"
  server_url = "${get_env("TF_VAR_powerdns_server_url")}"
}

provider "discord" {
  token = "${get_env("TF_VAR_discord_token")}"
}
EOF
}

inputs = merge(
  local.env_vars.locals,
  local.network_vars.locals
)
