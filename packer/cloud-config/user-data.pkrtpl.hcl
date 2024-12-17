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
    install-server: true
    authorized-keys: []
    allow-pw: false
  storage:
    layout:
      name: direct
  user-data:
    users:
      - name: ${build_username}
        gecos:  ${build_fullname}
        groups:
          - sudo
        hashed_passwd: ${build_password_encrypted}
        lock_passwd: false
        ssh_authorized_keys:
          - ${build_authorized_key}
