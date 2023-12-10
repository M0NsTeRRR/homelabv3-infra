data "proxmox_virtual_environment_vms" "template" {
  node_name = var.target_node
  tags      = ["template", var.template_tag]
}

resource "proxmox_virtual_environment_file" "cloud_network_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/cloud-init/network_config.tpl",
      {
        ip       = "${var.vm_ip}/${var.network.netmask}"
        ipv6     = "${var.vm_ip6}/${var.network.netmask6}"
        gateway4 = var.network.gateway
        gateway6 = var.network.gateway6
      }
    )

    file_name = "${var.vm_hostname}.${var.domain}-ci-network.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_user_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = file("${path.module}/cloud-init/user_data")

    file_name = "${var.vm_hostname}.${var.domain}-ci-user.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_meta_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/cloud-init/meta_data.tpl",
      {
        instance_id    = sha1(var.vm_hostname)
        local_hostname = var.vm_hostname
      }
    )

    file_name = "${var.vm_hostname}.${var.domain}-ci-meta_data.yml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = "${var.vm_hostname}.${var.domain}"
  node_name = var.target_node

  on_boot = var.onboot

  agent {
    enabled = true
  }

  tags = var.vm_tags

  bios = "ovmf"

  cpu {
    type    = "x86-64-v2-AES"
    cores   = var.cores
    sockets = var.sockets
    flags   = []
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
    vlan_id = var.network.tag
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  boot_order    = ["scsi0"]
  scsi_hardware = "virtio-scsi-single"

  disk {
    interface    = "scsi0"
    iothread     = true
    datastore_id = "${upper(var.target_node)}-${upper(var.disk.storage)}"
    size         = var.disk.size
    discard      = "ignore"
  }

  dynamic "disk" {
    for_each = var.additionnal_disks
    content {
      interface    = "scsi${1 + disk.key}"
      iothread     = true
      datastore_id = "${upper(var.target_node)}-${upper(disk.value.storage)}"
      size         = disk.value.size
      discard      = "ignore"
      file_format  = "raw"
    }
  }

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
  }

  initialization {
    interface            = "ide2"
    network_data_file_id = proxmox_virtual_environment_file.cloud_network_config.id
    user_data_file_id    = proxmox_virtual_environment_file.cloud_user_config.id
    meta_data_file_id    = proxmox_virtual_environment_file.cloud_meta_config.id
  }

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible"
    command     = "ansible all -i ${var.vm_ip}, -m shell -a '/usr/bin/cloud-init status --wait' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }
}
