#cloud-config
autoinstall:
  version: 1
  refresh-installer:
    update: true
  updates: "all"
  early-commands:
    # workaround to stop ssh for packer as it thinks it timed out
    - sudo systemctl stop ssh
  locale: en_US.UTF-8
  keyboard:
    layout: fr
    variant: latin9
  timezone: Europe/Paris
  packages:
    - openssh-server
    - qemu-guest-agent
    - cloud-init
  identity:
    hostname: ${build_hostname}
    realname: ${build_fullname}
    username: ${build_username}
    password: ${build_password_encrypted}
  ssh:
    install-server: yes
    authorized-keys:
      - ${build_authorized_key}
    allow-pw: no
  storage:
    layout:
      name: direct