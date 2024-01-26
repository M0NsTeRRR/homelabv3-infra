# Proxmox acme

## What is Proxmox ?

[Proxmox Virtual Environment](https://proxmox.com) is a complete open-source platform for enterprise virtualization. With the built-in web interface you can easily manage VMs and containers, software-defined storage and networking, high-availability clustering, and multiple out-of-the-box tools using a single solution.

## How to enable Proxmox ACME ?
In this guide we will see how to enable proxmox ACME with vault.
This guide assume vault PKI is already setup using the ansible role from this repository.
This guide also assume that you proxmox server trust vault PKI.

- `email_account` with your email account (not used)
- `vault_acme_url` like `https://vault.unicornafk.fr:8200/v1/pki/acme/directory`
- `proxmox_domains` it's a list of domains separated by ";" like `server.unicornafk.fr;server1.unicornafk.fr`. As we are using DNS round robin (recommended way to get cluster metrics) on proxmox exporter we must have an entry matching that record `server.unicornafk.fr`

Execute the following steps :

1. SSH to a proxmox node
2. Run `pvenode acme account register default <email_acount>`
3. Choose option 3 as we are using a custom endpoint
4. Type your `<vault_acme_url>` and don't use external account binding.
5. Configure ACME hostname `pvenode config set --acme domains="<proxmox_domains>"`
6. Order a certificate `pvenode acme cert order`

!!! info "Repeat step `5` to `6` on each server as step `1` to `4` need to be run only the first time on one node."
