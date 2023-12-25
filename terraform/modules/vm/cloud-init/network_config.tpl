network:
  version: 2
  ethernets:
    enp6s18:
      dhcp4: no
      dhcp6: no
      accept-ra: no
      ipv6-privacy: true
      addresses:
        - ${ip}
        - ${ipv6}
      routes:
        - to: 0.0.0.0/0
          via: ${gateway4}
        - to: ::/0
          via: ${gateway6}