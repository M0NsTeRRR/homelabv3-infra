locals {
  network = {
    name     = "VPN"
    netmask  = "24"
    gateway  = "192.168.70.2"
    netmask6 = "64"
    gateway6 = "2a0c:b641:2c0:170::2"
  }
  domain        = "vpn.unicornafk.fr"
  reverse_zone  = "70.168.192.in-addr.arpa"
  reverse_zone6 = "0.7.1.0.0.c.2.0.1.4.6.b.c.0.a.2.ip6.arpa"
}
