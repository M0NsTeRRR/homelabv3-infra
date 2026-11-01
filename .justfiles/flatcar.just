set working-directory := '../flatcar'

flatcar_version := '4757.2.0'
flatcar_channel := 'stable'
image_basename := 'flatcar_production_qemu_uefi_secure'
base_url := 'https://' + flatcar_channel + '.release.flatcar-linux.net/amd64-usr/' + flatcar_version
servers := 'server1 server2 server3'
self := just_executable() + " --justfile " + justfile_directory() + "/justfile flatcar"

# Deploy all Flatcar nodes
deploy:
    {{ self }} deploy-node k8s-1 server1 nvme-Lexar_SSD_NQ790_2TB_NHM259R004004P220B
    {{ self }} deploy-node k8s-2 server2 nvme-Lexar_SSD_NQ790_2TB_NHM259R006082P220B
    {{ self }} deploy-node k8s-3 server3 nvme-Lexar_SSD_NQ790_2TB_NHM259R002638P220B

# Deploy a single Flatcar node
deploy-node node server disk: (generate-ignition node)
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{ server }}:{{ node }}"
    pool_dir=/var/lib/incus/storage-pools/local/custom/default_flatcar
    current_qemu=$(incus profile get flatcar raw.qemu)
    current_apparmor=$(incus profile get flatcar raw.apparmor)
    # create VM
    incus init flatcar/{{ flatcar_version }} "$target" --vm --profile flatcar
    # configure qemu
    incus config set "$target" raw.qemu="$current_qemu -fw_cfg name=opt/org.flatcar-linux/config,file=$pool_dir/{{ node }}/ignition.json"
    # configure apparmor
    incus config set "$target" raw.apparmor="$current_apparmor /dev/disk/by-id/{{ disk }} rwk, $pool_dir/{{ node }}/ignition.json rk,"
    # configure disk
    incus config device add "$target" data disk source=/dev/disk/by-id/{{ disk }} wwn=0x5000000000000001
    # push ignition file
    incus storage volume file create -t directory {{ server }}:local flatcar/{{ node }}
    incus storage volume file push ./output/{{ node }}.ign {{ server }}:local flatcar/{{ node }}/ignition.json
    # start vm
    incus start "$target"

# Generate ignition for a single Flatcar node
[private]
generate-ignition node:
    mkdir -p generated/{{ node }}
    minijinja-cli templates/hostname.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/hostname
    minijinja-cli templates/network.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/network.conf
    minijinja-cli templates/resolved.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/resolved.conf
    minijinja-cli templates/timesyncd.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/timesyncd.conf
    minijinja-cli templates/k3s/config.yaml.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/k3s_config.yaml
    minijinja-cli -D k3s_token=$K3S_TOKEN templates/k3s/token.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/k3s_token
    butane -d . --pretty --strict base.bu > generated/base.ign
    butane -d . --pretty --strict base.k3s.bu > generated/base.k3s.ign
    butane -d . --pretty --strict k3s-server.bu > output/{{ node }}.ign

# Deploy Flatcar image to incusos
add-image node: download-artifacts
    for server in {{ servers }}; do {{ self }} import-artifacts "$server" {{ node }}; done

# Deploy Flatcar profile to incusos
add-profile:
    for server in {{ servers }}; do {{ self }} import-profile "$server"; done

# Download and prepare artifacts for incusos
[private]
download-artifacts:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p tmp/
    curl -Lo tmp/flatcar.asc https://www.flatcar.org/security/image-signing-key/Flatcar_Image_Signing_Key.asc
    curl -Lo tmp/{{ image_basename }}.img {{ base_url }}/{{ image_basename }}_image.img
    curl -Lo tmp/{{ image_basename }}.img.sig {{ base_url }}/{{ image_basename }}_image.img.sig
    curl -Lo tmp/{{ image_basename }}_efi_code.qcow2 {{ base_url }}/{{ image_basename }}_efi_code.qcow2
    curl -Lo tmp/{{ image_basename }}_efi_vars.qcow2 {{ base_url }}/{{ image_basename }}_efi_vars.qcow2
    # Verify image signature
    gpg --import --keyid-format LONG tmp/flatcar.asc
    gpg tmp/{{ image_basename }}.img.sig
    # Convert efi code and vars from qcow2 to raw
    qemu-img convert -f qcow2 -O raw tmp/{{ image_basename }}_efi_code.qcow2 tmp/{{ image_basename }}_efi_code.fd
    qemu-img convert -f qcow2 -O raw tmp/{{ image_basename }}_efi_vars.qcow2 tmp/{{ image_basename }}_efi_vars.fd
    # Create the metadata file (https://linuxcontainers.org/incus/docs/main/reference/image_format/#metadata)
    cat > tmp/metadata.yaml <<YAML
    ---
    architecture: x86_64
    creation_date: $(date +%s)
    properties:
      description: Flatcar {{ flatcar_version }}
      os: Flatcar
      release: {{ flatcar_version }}
    YAML
    tar -cvzf tmp/metadata.tar.gz -C tmp metadata.yaml

# Import Flatcar artifacts into incusos
[private]
import-artifacts server node:
    incus image import tmp/metadata.tar.gz tmp/{{ image_basename }}.img "{{ server }}:" --alias flatcar/{{ flatcar_version }}
    incus storage volume file push tmp/{{ image_basename }}_efi_code.fd {{ server }}:local flatcar/{{ node }}/{{ image_basename }}_efi_code.fd
    incus storage volume file push tmp/{{ image_basename }}_efi_vars.fd {{ server }}:local flatcar/{{ node }}/{{ image_basename }}_efi_vars.fd

# Import Flatcar profile into incusos
[private]
import-profile server:
    #!/usr/bin/env bash
    set -euo pipefail
    incus remote switch {{ server }}
    incus profile create flatcar <<'YAML'
    ---
    config:
      limits.cpu: 12
      limits.memory: 50GiB
      boot.autostart: true
      raw.apparmor: |-
        /var/lib/incus/storage-pools/local/custom/default_flatcar/{{ image_basename }}_efi_code.fd rk,
        /var/lib/incus/storage-pools/local/custom/default_flatcar/{{ image_basename }}_efi_vars.fd rwk,
      raw.qemu: |-
        -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_flatcar/{{ image_basename }}_efi_code.fd,readonly=on
        -drive if=pflash,format=raw,file=/var/lib/incus/storage-pools/local/custom/default_flatcar/{{ image_basename }}_efi_vars.fd
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
        size: 200GiB
    name: flatcar
    used_by:
    YAML
