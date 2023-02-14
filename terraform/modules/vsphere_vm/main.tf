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

# default interface
data "vsphere_network" "network" {
  name          = var.network.name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# additional interface
data "vsphere_network" "additional_network" {
  for_each      = {for network in var.networks:  network.name => network}
  name          = each.value.name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "powerdns_record" "dns_A" {
  zone    = "${var.domain}."
  name    = "${var.vm_name}.${var.domain}."
  type    = "A"
  ttl     = 3600
  records = [var.vm_ip]
}

resource "powerdns_record" "dns_AAAA" {
  zone    = "${var.domain}."
  name    = "${var.vm_name}.${var.domain}."
  type    = "AAAA"
  ttl     = 3600
  records = [var.vm_ip6]
}

resource "powerdns_record" "dns_PTR_ipv4" {
  zone    = "${var.reverse_zone}."
  name    = "${join(".", reverse(split(".", var.vm_ip)))}.in-addr.arpa."
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_name}.${var.domain}."]
}

data "external" "reverse_ptr_ipv6" {
  program = ["python3", "${path.module}/scripts/reverse_ptr_ipv6.py", var.vm_ip6]
}

resource "powerdns_record" "dns_PTR_ipv6" {
  zone    = "${var.reverse_zone6}."
  name    = data.external.reverse_ptr_ipv6.result.reversed
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_name}.${var.domain}."]

  depends_on = [data.external.reverse_ptr_ipv6]
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id   = data.vsphere_host.host.id

  guest_id = data.vsphere_virtual_machine.template.guest_id

  num_cpus = var.hardware.num_cpus
  memory   = var.hardware.memory

  # default interface
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # additional interface
  dynamic "network_interface" {
    for_each = {for network in var.networks:  network.name => network}
    content {
      network_id = data.vsphere_network.additional_network[network_interface.key].id
    }
  }

  disk {
    label = "disk0"
    size  = var.disk.size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.domain
      }

      # default interface
      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = var.network.netmask
        ipv6_address = var.vm_ip6
        ipv6_netmask = var.network.netmask6
      }

      # additional interface
      dynamic "network_interface" {
        for_each     = {for network in var.networks:  network.name => network}
        content {
          ipv4_address = network_interface.value.ip
          ipv4_netmask = network_interface.value.netmask
          ipv6_address = network_interface.value.ipv6
          ipv6_netmask = network_interface.value.netmask6
        }
      }

      dns_server_list = var.dns.server_list
      dns_suffix_list = var.dns.suffix_list
      ipv4_gateway    = var.network.gateway
      ipv6_gateway    = var.network.gateway6
    }
  }

  provisioner "remote-exec" {
    connection {
      host = var.vm_ip
      user = var.vm_user
      password = var.vm_password
    }
    inline = ["echo 'Wait VM creation'"]
  }

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible/playbooks"
    command = "ansible-playbook -i ${var.vm_ip}, lvm_resize.yml --extra-vars 'ansible_user=${var.vm_user} ansible_ssh_pass=${var.vm_password}' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible/playbooks"
    command = "ansible-playbook -i ${var.vm_ip}, disable_slaac.yml --extra-vars 'ansible_user=${var.vm_user} ansible_ssh_pass=${var.vm_password}' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }

  provisioner "local-exec" {
    working_dir = "${var.terraform_root_dir}/../ansible"
    command = "ANSIBLE_VAULT_PASS=${var.ansible_vault_pass} ansible-playbook -i ${var.vm_ip}, deploy_terraform.yml --extra-vars 'ansible_user=${var.vm_user} ansible_ssh_pass=${var.vm_password} inventory_hostname=${var.vm_name}.${var.domain}' --ssh-common-args='-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'"
  }

  depends_on = [powerdns_record.dns_A, powerdns_record.dns_AAAA, powerdns_record.dns_PTR_ipv4, powerdns_record.dns_PTR_ipv6]
}

data "external" "sshfp" {
  program = ["python3", "${path.module}/scripts/sshfp.py", "${var.vm_name}.${var.domain}"]

  depends_on = [vsphere_virtual_machine.vm]
}

resource "powerdns_record" "dns_SSHFP" {
  zone    = "${var.domain}."
  name    = "${var.vm_name}.${var.domain}."
  type    = "SSHFP"
  ttl     = 3600
  records = [data.external.sshfp.result.sshfp]

  depends_on = [data.external.sshfp]
}

resource discord_message vm_update {
    channel_id = var.discord_log_channel_id
    embed {
        title = "Terraform VM"

        fields {
            name = "Name"
            value = "${var.vm_name}.${var.domain}."
            inline = false
        }

        fields {
            name = "IPv4"
            value = "${var.vm_ip}/${var.network.netmask}"
            inline = true
        }

        fields {
            name = "IPv6"
            value = "${var.vm_ip6}/${var.network.netmask6}"
            inline = false
        }

        fields {
            name = "vCPU"
            value = var.hardware.num_cpus
            inline = true
        }

        fields {
            name = "Memory"
            value = var.hardware.memory
            inline = true
        }

        fields {
            name = "Disk size"
            value = var.disk.size
            inline = false
        }
    }
}
