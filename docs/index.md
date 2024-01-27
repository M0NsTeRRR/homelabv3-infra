# Welcome to my homelab documentation

This is the third version of my homelab :rocket:

~~v1 : [Personnal-docker-config](https://github.com/M0NsTeRRR/Personnal-docker-config)~~  
~~v2 : [Homelab-infra](https://github.com/M0NsTeRRR/Homelab-infra)~~  
v3 : [homelabv3-infra](https://github.com/M0NsTeRRR/homelabv3-infra)

To start, I would like to thank all maintainers and contributors to open source projects that make my lab possible ! 

## What are the key features

- [x] Open source
- [x] Dual stacks IPv4/IPv6
- [x] Privacy
- [x] Security
- [x] Monitoring, logging and alerting
- [x] Offsite encrypted backup to S3 multi A-Z
- [x] Manage everything except :
    * [ ] Emails
- [x] Eveything is automated with scripts, IaC, etc except :
    * [ ] Hypervisor installation but can be done with [netboot.xyz](https://netboot.xyz/)
    * [ ] Networking hardware (routers, switchs)

## Roadmap

- Kubernetes :
    * [ ] Kubernetes node firewalling
    * [ ] Kubernetes policies rules
- Monitoring/Logging/Alerting :
    * [ ] Kea DHCP
    * [ ] PDNS rec/auth/dnsdist
    * [ ] Nginx
    * [ ] VM
- Security :
    * [ ] Crowdsec
    * [ ] CSP policy
    * [ ] Implement systemd-resolved dnssec validation (DS record not supported by my current registrar)
- Misc :
    * [ ] Autounseal vault
    * [ ] Fix DHCPv6
