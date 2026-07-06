# Proxmox acme

## What is IncusOS ?

[IncusOS](https://linuxcontainers.org/incus-os/) is an immutable OS solely designed around safely and reliably running Incus. Incus is a next-generation system container, application container, and virtual machine manager.

## Install IncusOS

1. Go to the [IncusOS image downloader](https://incusos-customizer.linuxcontainers.org/ui/).
2. In installation target `Wipe the target drive` must be checked.
3. In target drive identifier, put `wwn`
4. In application configuration `Apply default configuration` must be checked **only** for server1.
5. In TLS client certificate copy the output of `incus remote get-client-certificate`
6. In the advanced settings, paste the network configuration from `incusos/serverX/network.yaml` (where `X` represents the server number).
7. Download the ISO.
8. [Configure the BIOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/installation/physical/).
9. Boot from the ISO.
10. Install and reboot
11. [Connect to IncusOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/access/#connecting-to-incusos)

## Post install setup

Create Volumes
```fish
# Volumes
incus storage volume create local flatcar
```

Create Networks
```fish
incus network create prod parent=enp3s0 vlan=10 --type=physical
incus network create lab parent=enp3s0 vlan=20 --type=physical
```

## Add custom CA certs

https://linuxcontainers.org/incus-os/docs/main/reference/system/security/#configuration-options

## Configure ACME

In `OS` > `System` > `Security` add custom CA cert.
```
custom_ca_certs:
  - |
    -----BEGIN CERTIFICATE-----
    xxxxxxx
```

In settings page configure the following :

`acme.agree_tos`: `true`
`acme.ca_url`: `https://openbao.unicornafk.fr:8200/v1/pki/acme/directory`
`acme.domain`: `server.unicornafk.fr,serverX.unicornafk.fr` (where `X` represents the server number)
`acme.email`: `admin@unicornafk.fr`

## Usage

### Task

Use `uv run task --list` to find Flatcar group recipes for deploying the base VM infrastructure.

## Tips

### List hardware ressources

```fish
incus query /1.0/resources
```

### Wipe a drive

```fish
incus admin os system storage wipe-drive -d '{"id":"/dev/disk/by-id/<disk-id>"}'
```
