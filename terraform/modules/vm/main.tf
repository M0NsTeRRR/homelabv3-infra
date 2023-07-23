resource "proxmox_cloud_init_disk" "ci" {
  name     = var.vm_hostname
  pve_node = var.target_node
  storage  = "local"

  network_config = templatefile("${path.module}/cloud-init/network_config.tpl",
    {
      ip       = "${var.vm_ip}/${var.network.netmask}"
      ipv6     = "${var.vm_ip6}/${var.network.netmask6}"
      gateway4 = var.network.gateway
      gateway6 = var.network.gateway6
    }
  )

  meta_data = templatefile("${path.module}/cloud-init/meta_data.tpl",
    {
      instance_id    = sha1(var.vm_hostname)
      local_hostname = var.vm_hostname
    }
  )

  user_data = file("${path.module}/cloud-init/user_data")
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_hostname
  target_node = var.target_node

  agent = 1

  tags = join(";", var.vm_tags)

  bios = "ovmf"

  cpu     = "x86-64-v2-AES"
  sockets = var.sockets
  cores   = var.cores

  memory  = var.memory

  network {
    bridge = "vmbr1"
    model  = "virtio"
    tag    = var.network.tag
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes = [
      network
    ]
  }

  boot   = "order=scsi0"
  scsihw = "virtio-scsi-single"

  disk {
    type     = "scsi"
    iothread = 1
    storage  = "${upper(var.target_node)}-${var.disk.storage}"
    slot     = 0
    size     = "${upper(var.disk.size)}G"
  }

  disk {
    type    = "scsi"
    media   = "cdrom"
    storage = "local"
    volume  = proxmox_cloud_init_disk.ci.id
    slot    = 2
    size    = proxmox_cloud_init_disk.ci.size
  }

  clone = var.template

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible"
    command     = "ansible all -i ${var.vm_ip}, -m shell -a '/usr/bin/cloud-init status --wait' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }
}
