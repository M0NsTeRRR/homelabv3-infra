set working-directory := '../flatcar'

import 'common.just'

flatcar_version := '4757.2.3'
flatcar_channel := 'stable'
image_basename := 'flatcar_production_qemu_uefi_secure'
base_url := 'https://' + flatcar_channel + '.release.flatcar-linux.net/amd64-usr/' + flatcar_version
volume_dir := '/var/lib/incus/storage-pools/local/custom/default_flatcar-'
wait_nodes := 'kubectl wait --for=condition=Ready node/k8s-1 node/k8s-2 node/k8s-3 --timeout=1m'
wait_ceph := "kubectl -n rook-ceph wait cephcluster/rook-ceph --for=jsonpath='{.status.ceph.health}'=HEALTH_OK --timeout=30m"

# Deploy all Flatcar nodes as a new cluster (k3s_bootstrap), use deploy-node to add or replace a node
deploy: (deploy-node 'k8s-1' 'yes') (deploy-node 'k8s-2' 'yes') (deploy-node 'k8s-3' 'yes')

# Replace all Flatcar nodes one at a time (bump flatcar_version / k3s version and run add-image first)
replace: (replace-node 'k8s-1') (replace-node 'k8s-2') (replace-node 'k8s-3')

# Deploy a single Flatcar node, it joins the existing cluster unless bootstrap=yes (new cluster). Each node has its own volume with its EFI files and ignition
deploy-node node bootstrap='' server=shell('yq .incus_server "$1"', 'data/hosts/' + node + '.yml') disk=shell('yq .incus_disk "$1"', 'data/hosts/' + node + '.yml'): (generate-ignition node bootstrap)
    incus storage volume create {{ cluster }}:local flatcar-{{ node }} --target {{ server }}
    incus storage volume file push tmp/{{ image_basename }}_efi_code.fd {{ cluster }}:local flatcar-{{ node }}/efi_code.fd
    incus storage volume file push tmp/{{ image_basename }}_efi_vars.fd {{ cluster }}:local flatcar-{{ node }}/efi_vars.fd
    incus storage volume file push output/{{ node }}.ign {{ cluster }}:local flatcar-{{ node }}/ignition.json
    incus init {{ cluster }}:flatcar/{{ flatcar_version }} {{ cluster }}:{{ node }} --target {{ server }} --vm --profile flatcar
    incus config set {{ cluster }}:{{ node }} raw.qemu="-drive if=pflash,format=raw,file={{ volume_dir }}{{ node }}/efi_code.fd,readonly=on -drive if=pflash,format=raw,file={{ volume_dir }}{{ node }}/efi_vars.fd -fw_cfg name=opt/org.flatcar-linux/config,file={{ volume_dir }}{{ node }}/ignition.json"
    incus config set {{ cluster }}:{{ node }} raw.apparmor="{{ volume_dir }}{{ node }}/efi_code.fd rk, {{ volume_dir }}{{ node }}/efi_vars.fd rwk, {{ volume_dir }}{{ node }}/ignition.json rk, /dev/disk/by-id/{{ disk }} rwk,"
    incus config device add {{ cluster }}:{{ node }} data disk source=/dev/disk/by-id/{{ disk }} wwn=0x5000000000000001
    incus config device add {{ cluster }}:{{ node }} efi disk pool=local source=flatcar-{{ node }} path=/mnt/efi
    incus start {{ cluster }}:{{ node }}

# Replace a single Flatcar node (same name, same IP), its data disk is kept for rook-ceph
replace-node node server=shell('yq .incus_server "$1"', 'data/hosts/' + node + '.yml') disk=shell('yq .incus_disk "$1"', 'data/hosts/' + node + '.yml'): && (deploy-node node '' server disk) (wait-node node)
    {{ wait_nodes }}
    {{ wait_ceph }}
    kubectl drain {{ node }} --ignore-daemonsets --delete-emptydir-data --timeout=15m
    kubectl delete node {{ node }}
    incus delete -f {{ cluster }}:{{ node }}
    incus storage volume delete {{ cluster }}:local flatcar-{{ node }} --target {{ server }}

[private]
wait-node node:
    kubectl wait --for=create node/{{ node }} --timeout=15m
    kubectl wait --for=condition=Ready node/{{ node }} --timeout=15m
    {{ wait_ceph }}

# Generate ignition for a single Flatcar node
[private]
generate-ignition node bootstrap='':
    mkdir -p generated/{{ node }}
    minijinja-cli templates/hostname.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/hostname
    minijinja-cli templates/network.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/network.conf
    minijinja-cli templates/resolved.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/resolved.conf
    minijinja-cli templates/timesyncd.conf.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/timesyncd.conf
    minijinja-cli -D k3s_bootstrap={{ bootstrap }} templates/k3s/config.yaml.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/k3s_config.yaml
    minijinja-cli -D k3s_token=$K3S_TOKEN templates/k3s/token.j2 data/default.yml data/hosts/{{ node }}.yml -o generated/k3s_token
    butane -d . --pretty --strict base.bu > generated/base.ign
    butane -d . --pretty --strict base.k3s.bu > generated/base.k3s.ign
    butane -d . --pretty --strict k3s-server.bu > output/{{ node }}.ign

# Import the Flatcar image into the cluster
add-image: download-artifacts
    incus image import tmp/metadata.tar.gz tmp/{{ image_basename }}.img {{ cluster }}: --alias flatcar/{{ flatcar_version }}

# Create the Flatcar profile in the cluster
add-profile:
    incus profile create {{ cluster }}:flatcar < incus-profile.yaml

# Download and prepare artifacts for incusos
[private]
download-artifacts:
    mkdir -p tmp
    curl -Lo tmp/flatcar.asc https://www.flatcar.org/security/image-signing-key/Flatcar_Image_Signing_Key.asc
    curl -Lo tmp/{{ image_basename }}.img {{ base_url }}/{{ image_basename }}_image.img
    curl -Lo tmp/{{ image_basename }}.img.sig {{ base_url }}/{{ image_basename }}_image.img.sig
    curl -Lo tmp/{{ image_basename }}_efi_code.qcow2 {{ base_url }}/{{ image_basename }}_efi_code.qcow2
    curl -Lo tmp/{{ image_basename }}_efi_vars.qcow2 {{ base_url }}/{{ image_basename }}_efi_vars.qcow2
    gpg --import --keyid-format LONG tmp/flatcar.asc
    gpg tmp/{{ image_basename }}.img.sig
    qemu-img convert -f qcow2 -O raw tmp/{{ image_basename }}_efi_code.qcow2 tmp/{{ image_basename }}_efi_code.fd
    qemu-img convert -f qcow2 -O raw tmp/{{ image_basename }}_efi_vars.qcow2 tmp/{{ image_basename }}_efi_vars.fd
    minijinja-cli -D flatcar_version={{ flatcar_version }} -D creation_date={{ datetime("%s") }} incus-metadata.yaml.j2 -o tmp/metadata.yaml
    tar -czf tmp/metadata.tar.gz -C tmp metadata.yaml
