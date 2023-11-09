resource "terraform_data" "cluster" {
  triggers_replace = var.vm_id

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible"
    command     = "ansible-playbook deploy_infra.yml --limit ${var.vm_hostname}.${var.domain} --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }
}
