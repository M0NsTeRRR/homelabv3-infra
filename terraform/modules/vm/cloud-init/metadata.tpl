network:
  version: 2
  ethernets:
    ens192:
      dhcp4: no
      dhcp6: no
      accept-ra: no
      ipv6-privacy: true
      addresses:
        - ${ip}
        - ${ipv6}
      gateway4: ${gateway4}
      gateway6: ${gateway6}