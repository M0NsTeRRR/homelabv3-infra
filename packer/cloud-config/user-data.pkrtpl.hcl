#cloud-config
autoinstall:
  version: 1
  refresh-installer:
    update: true
  updates: "all"
  locale: en_US.UTF-8
  keyboard:
    layout: fr
    variant: latin9
  timezone: Europe/Paris
  packages:
    - qemu-guest-agent
    - cloud-init
  ssh:
    install-server: yes
    authorized-keys: []
    allow-pw: no
  storage:
    layout:
      name: direct
  user-data:
    system_info:
      default_user:
        name: ${build_username}
        gecos:  ${build_fullname}
        hashed_passwd: ${build_password_encrypted}
        ssh_authorized_keys:
          - ${build_authorized_key}
