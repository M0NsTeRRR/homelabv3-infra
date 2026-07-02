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

In settings page configure the following :

`acme.agree_tos`: `true`
`acme.ca_url`: `https://openbao.unicornafk.fr:8200/v1/pki/acme/directory`
`acme.domain`: `server.unicornafk.fr,serverX.unicornafk.fr` (where `X` represents the server number)
`acme.email`: `admin@unicornafk.fr`

## Tips

### Add a flatcar image and profile

1. Export the env file
```fish
set -gx CHANNEL "stable"
set -gx VERSION "4593.2.3" # https://www.flatcar.org/releases/
set -gx IMAGE_BASENAME "flatcar_production_qemu_uefi_secure"
# Server1
set -gx SERVER_NAME "server1"
# Server2
set -gx SERVER_NAME "server2"
# Server3
set -gx SERVER_NAME "server3"
```

2. Download the image  and associated files
```fish
curl -Lo "$IMAGE_BASENAME.img" "https://$CHANNEL.release.flatcar-linux.net/amd64-usr/$VERSION/{$IMAGE_BASENAME}_image.img"
curl -Lo "$IMAGE_BASENAME.img.sig" "https://$CHANNEL.release.flatcar-linux.net/amd64-usr/$VERSION/{$IMAGE_BASENAME}_image.img.sig"
curl -Lo $IMAGE_BASENAME"_efi_code.qcow2" "https://$CHANNEL.release.flatcar-linux.net/amd64-usr/$VERSION/{$IMAGE_BASENAME}_efi_code.qcow2"
curl -Lo $IMAGE_BASENAME"_efi_vars.qcow2" "https://$CHANNEL.release.flatcar-linux.net/amd64-usr/$VERSION/{$IMAGE_BASENAME}_efi_vars.qcow2"
```

3. Verify image signature
```fish
gpg --verify "$IMAGE_BASENAME.img.sig"
```

4. Convert efi code and vars from qcow2 to raw
```fish
qemu-img convert -f qcow2 -O raw {$IMAGE_BASENAME}_efi_code.qcow2 {$IMAGE_BASENAME}_efi_code.fd
qemu-img convert -f qcow2 -O raw {$IMAGE_BASENAME}_efi_vars.qcow2 {$IMAGE_BASENAME}_efi_vars.fd
```

5. Create the [metadata file](https://linuxcontainers.org/incus/docs/main/reference/image_format/#metadata)
```fish
echo "---
architecture: x86_64
creation_date: $(date +%s)
properties:
  description: $IMAGE_BASENAME
  os: Flatcar
  release: $VERSION" > metadata.yaml
tar -cvzf metadata.tar.gz metadata.yaml
```

6. Import the metadata, the image and the efi code and vars
```fish
incus image import metadata.tar.gz "$IMAGE_BASENAME.img" --alias "flatcar/$VERSION"
incus storage volume file push $IMAGE_BASENAME"_efi_code.fd" $SERVER_NAME":local" "flatcar/"$IMAGE_BASENAME"_efi_code.fd"
incus storage volume file push $IMAGE_BASENAME"_efi_vars.fd" $SERVER_NAME":local" "flatcar/"$IMAGE_BASENAME"_efi_vars.fd"
```

7. Create the flatcar profile
```fish
echo "---
config:
  limits.cpu: 12
  limits.memory: 50GiB
  boot.autostart: true
  raw.apparmor: |-
    /var/lib/incus/storage-pools/local/custom/default_flatcar/"$IMAGE_BASENAME"_efi_code.fd rk,
    /var/lib/incus/storage-pools/local/custom/default_flatcar/"$IMAGE_BASENAME"_efi_vars.fd rwk,
  raw.qemu: |-
    -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_flatcar/"$IMAGE_BASENAME"_efi_code.fd,readonly=on
    -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_flatcar/"$IMAGE_BASENAME"_efi_vars.fd
  raw.qemu.conf: |-
    [drive][0]
    [drive][1]
devices:
  eth0:
    network: prod
    type: nic
  efi:
    type: disk
    pool: local
    source: flatcar
    path: /mnt/efi
  root:
    path: /
    pool: local
    type: disk
    size: 16GiB
name: flatcar
used_by:" | incus profile create flatcar
```

### Deploy flatcar VM

```fish
task flatcar:deploy
```

### List hardware ressources

```fish
incus info --resources
```

### Wipe a drive

```fish
incus admin os system storage wipe-drive -d '{"id":"/dev/disk/by-id/<disk-id>"}'
```
