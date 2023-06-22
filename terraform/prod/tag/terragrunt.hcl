terraform {
  source = "${get_parent_terragrunt_dir()}/modules//tag"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  tags = [
    "ansible_managed",
    "dns",
    "kubernetes",
    "kubernetes_master",
    "kubernetes_worker"
  ]
}