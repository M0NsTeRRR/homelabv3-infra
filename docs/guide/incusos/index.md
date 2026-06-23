# Proxmox acme

## What is IncusOS ?

[IncusOS](https://linuxcontainers.org/incus-os/) is an immutable OS solely designed around safely and reliably running Incus. Incus is a next-generation system container, application container, and virtual machine manager.

## Install IncusOS

1. Go to the [IncusOS image downloader](https://incusos-customizer.linuxcontainers.org/ui/).
2. In application configuration `Apply default configuration` must be checked **only** for server1.
3. In target drive identifier, put `wwn`
4. In the advanced settings, paste the network configuration from `incusos/serverX/network.yaml` (where `X` represents the server number).
5. Download the ISO.
6. [Configure the BIOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/installation/physical/).
7. Boot from the ISO.
8. Install and reboot
9. [Connect to IncusOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/access/#connecting-to-incusos)

## Post install setup

Create Volumes
```fish
# EFI volumes
incus storage volume create local efi

# VM Volumes
incus admin os system storage edit # paste the storage configuration from `incusos/serverX/storage.yaml` (where `X` represents the server number).
incus admin os system storage create-volume -d '{"pool":"data","name":"vm-volume","use":"incus"}'
incus storage create vm-storage zfs source=data/vm-volume
```

Create Networks
```fish
incus network create prod parent=enp3s0 vlan=10 --type=physical
incus network create lab parent=enp3s0 vlan=20 --type=physical
```

## Deploy a VM

1. Generate flatcar ignitions file `task flatcar:generate-ignitions`

2. Log in to the server via Sfish and create the VMs

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
set -gx OVMF_DIR "/opt/incus/share/qemu"
set -gx CHANNEL "stable"
set -gx VERSION "4593.2.3" # https://www.flatcar.org/releases/
set -gx IMAGE_BASENAME "flatcar_production_qemu_uefi_secure"
# Server1
set -gx SERVER_NAME "server1"
set -gx FLATCAR_NODE_NAME "$FLATCAR_NODE_NAME"
set -gx DISK_ID "nvme-Lexar_SSD_NQ790_2TB_NHM259R004004P220B"
# Server2
set -gx SERVER_NAME "server2"
set -gx FLATCAR_NODE_NAME "k8s-2"
set -gx DISK_ID "nvme-Lexar_SSD_NQ790_2TB_NHM259R006082P220B"
# Server3
set -gx SERVER_NAME "server3"
set -gx FLATCAR_NODE_NAME "k8s-3"
set -gx DISK_ID "nvme-Lexar_SSD_NQ790_2TB_NHM259R004004P220B"
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
incus storage volume file push $IMAGE_BASENAME"_efi_code.fd" $SERVER_NAME":local" "efi/"$IMAGE_BASENAME"_efi_code.fd"
incus storage volume file push $IMAGE_BASENAME"_efi_vars.fd" $SERVER_NAME":local" "efi/"$IMAGE_BASENAME"_efi_vars.fd"
```

7. Create the flatcar profile
```fish
echo "---
config:
  limits.cpu: 12
  limits.memory: 50GiB
  boot.autostart: true
  raw.apparmor: |-
    /var/lib/incus/storage-pools/local/custom/default_efi/"$IMAGE_BASENAME"_efi_code.fd rk,
    /var/lib/incus/storage-pools/local/custom/default_efi/"$IMAGE_BASENAME"_efi_vars.fd rwk,
  raw.qemu: |-
    -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_efi/"$IMAGE_BASENAME"_efi_code.fd,readonly=on
    -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_efi/"$IMAGE_BASENAME"_efi_vars.fd
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
    source: efi
    path: /mnt/efi
  root:
    path: /
    pool: local
    type: disk
    size: 16GiB
name: flatcar
used_by:" | incus profile create flatcar
```

### Create a flatcar VM from the profile

```fish
incus init flatcar/$VERSION $FLATCAR_NODE_NAME --vm --profile flatcar

set current_qemu (incus config get --expanded $FLATCAR_NODE_NAME raw.qemu)
incus config set $FLATCAR_NODE_NAME raw.qemu="$current_qemu
-fw_cfg name=opt/com.coreos/config,file=/var/lib/incus/devices/$FLATCAR_NODE_NAME/ignition.json"

set current_apparmor (incus config get --expanded $FLATCAR_NODE_NAME raw.apparmor)
incus config set $FLATCAR_NODE_NAME raw.apparmor="$current_apparmor
/dev/disk/by-id/$DISK_ID rwk,"

incus config device add $FLATCAR_NODE_NAME data disk source=/dev/disk/by-id/$DISK_ID

task flatcar:generate-ignition

incus file push ./flatcar/output/ignition.json $FLATCAR_NODE_NAME/var/lib/incus/devices/$FLATCAR_NODE_NAME/ignition.json

incus start $FLATCAR_NODE_NAME
```

### List hardware ressources

```fish
incus info --resources
```

### Wipe a drive

```fish
incus admin os system storage wipe-drive -d '{"id":"/dev/disk/by-id/<disk-id>"}'
```
