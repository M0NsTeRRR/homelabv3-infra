data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.disk.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network.name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_tag_category" "category" {
  name        = "terraform"
}

data "vsphere_tag" "tag" {
  for_each      = toset(var.vm_tags)
  name          = each.key
  category_id   = data.vsphere_tag_category.category.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_hostname
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id   = data.vsphere_host.host.id

  guest_id = data.vsphere_virtual_machine.template.guest_id

  tags = [for tag in var.vm_tags : data.vsphere_tag.tag[tag].id]

  firmware = "efi"
  efi_secure_boot_enabled = true

  num_cpus = var.hardware.num_cpus
  memory   = var.hardware.memory

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = var.disk.size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata" = base64encode(
      templatefile("${path.module}/cloud-init/metadata.tpl",
        {
          ip              = "${var.vm_ip}/${var.network.netmask}"
          ipv6            = "${var.vm_ip6}/${var.network.netmask6}"
          gateway4        = var.network.gateway
          gateway6        = var.network.gateway6
        }
      )
    )
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(
      templatefile("${path.module}/cloud-init/userdata.tpl",
        {
          hostname        = var.vm_hostname
          domain          = var.domain
        }
      )
    )
    "guestinfo.userdata.encoding" = "base64"
  }

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible"
    command = "ansible all -i ${var.vm_ip}, -m shell -a '/usr/bin/cloud-init status --wait' --extra-vars 'ansible_config=ansible.cfg' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }
}
