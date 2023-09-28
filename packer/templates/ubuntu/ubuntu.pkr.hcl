packer {
  required_version = "v1.9.4"
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "v1.1.5"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "1.1.0"
    }
  }
}

locals {
  iso_url      = "https://releases.ubuntu.com/${var.version}/ubuntu-${var.version}-live-server-amd64.iso"
  iso_checksum = "file:https://releases.ubuntu.com/${var.version}/SHA256SUMS"
}

source "proxmox-iso" "ubuntu" {
  cores  = 2
  memory = 2048
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz",
    " autoinstall ds=\"nocloud-net;seedfrom=http://${var.host_ip}:{{.HTTPPort}}/\"",
    " ip=${var.vm_ip}::${var.vm_gateway_ip}:${var.vm_netmask}::::${var.vm_dns_ip}",
    " --- <enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_wait = "10s"
  bios      = "ovmf"
  efi_config {
    efi_storage_pool  = "${upper(var.proxmox_node)}-SSD1"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  node              = "${var.proxmox_node}"
  http_bind_address = "0.0.0.0"
  http_port_max     = var.http_port
  http_port_min     = var.http_port
  http_content = {
    "/meta-data" = file("../../cloud-config/meta-data")
    "/user-data" = templatefile("../../cloud-config/user-data.pkrtpl.hcl", { build_fullname = var.ssh_fullname, build_hostname = var.distribution, build_username = var.ssh_username, build_password_encrypted = var.ssh_password_encrypted, build_authorized_key = var.ssh_autorized_key })
  }
  iso_checksum     = local.iso_checksum
  iso_url          = local.iso_url
  iso_storage_pool = "local"
  unmount_iso      = true
  machine          = "q35"
  network_adapters {
    bridge   = "vmbr1"
    model    = "virtio"
    vlan_tag = "20"
  }
  template_description = "${var.distribution}-${var.version}, generated on {{ timestamp }}"
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = "30m"
  scsi_controller      = "virtio-scsi-single"
  disks {
    type         = "scsi"
    io_thread    = true
    disk_size    = "10G"
    storage_pool = "${upper(var.proxmox_node)}-SSD1"
  }
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  password    = var.proxmox_password
  vm_name     = "packer-${var.distribution}-${var.version}"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_CONFIG=../ansible/ansible.cfg", "ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_BECOME_PASS=${var.ssh_password}"]
    extra_arguments  = ["--extra-vars", "ansible_password=${var.ssh_password} main_user=${var.ssh_username}", "--ssh-common-args='-o userknownhostsfile=/dev/null'"]
    playbook_file    = "../ansible/deploy_packer.yml"
    use_proxy        = false
  }
}
