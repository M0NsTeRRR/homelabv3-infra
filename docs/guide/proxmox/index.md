# Proxmox acme

## What is Proxmox ?

[Proxmox Virtual Environment](https://proxmox.com) is a complete open-source platform for enterprise virtualization. With the built-in web interface you can easily manage VMs and containers, software-defined storage and networking, high-availability clustering, and multiple out-of-the-box tools using a single solution.

## Deploy a VM on Proxmox

```bash
export VM_ID=XX
export VM_NAME=XX
export VM_STORAGE=XX
curl -LO https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_proxmoxve_image.img
vi /var/lib/vz/snippets/vm-$VM_ID-user-data
qm create $VM_ID --name $VM_NAME --cores 12 --memory 51200 --net0 "virtio,bridge=vmbr0,firewall=1,tag=10" --ipconfig0 "ip=dhcp"
qm disk import $VM_ID flatcar_production_proxmoxve_image.img $VM_STORAGE
qm set $VM_ID --scsi0 $VM_STORAGE:vm-$VM_ID-disk-0
qm set $VM_ID --boot order=scsi0
qm set $VM_ID --efidisk0 "file=$VM_STORAGE:1,efitype=4m,size=4M"
qm set $VM_ID --bios ovmf
qm set $VM_ID --machine q35
qm set $VM_ID --scsihw virtio-scsi-single
qm set $VM_ID --onboot 1
qm set $VM_ID --agent "enabled=1"
qm set $VM_ID --scsi1 "file=$VM_STORAGE:1000,iothread=1,discard=ignore,format=raw"
qm set $VM_ID --ide2 local-lvm:cloudinit
qm set $VM_ID --cicustom "user=local:snippets/vm-$VM_ID-user-data"
```

## How to enable Proxmox ACME ?

In this guide we will see how to enable proxmox ACME with vault.
This guide assume vault PKI is already setup using the ansible role from this repository.
This guide also assume that your proxmox server trust the vault PKI.

- `email_account` with your email account (not used)
- `vault_acme_url` like `https://vault.unicornafk.fr:8200/v1/pki/acme/directory`
- `proxmox_domains` it's a list of domains separated by `;` like `server.unicornafk.fr;server1.unicornafk.fr`. As we are using DNS round robin (recommended way to get cluster metrics) on proxmox exporter we must have an entry matching that record `server.unicornafk.fr`

Execute the following steps :

1. SSH to a proxmox node
2. Run `pvenode acme account register default <email_acount>`
3. Choose option 2 as we are using a custom endpoint
4. Type your `<vault_acme_url>` and don't use external account binding.
5. Configure ACME hostname `pvenode config set --acme domains="<proxmox_domains>"`
6. Order a certificate `pvenode acme cert order`

!!! info "Repeat step `5` to `6` on each server as step `1` to `4` need to be run only the first time on one node."

!!! info "If you need to delete a registered account when the ACME Server is not available `/etc/pve/priv/acme/default`"
