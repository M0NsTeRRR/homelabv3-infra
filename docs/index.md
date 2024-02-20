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
    * [ ] Networking hardware device configuration (routers, switchs)

## Roadmap

- Kubernetes :
    * [ ] Kubernetes node firewalling
    * [ ] Kubernetes policies rules
- Monitoring/Logging/Alerting :
    * [ ] Kea DHCP (need Docker image, PR created https://github.com/mweinelt/kea-exporter/pull/40)
    * [ ] Alerting system
- Security :
    * [ ] Crowdsec
    * [ ] CSP policy
    * [ ] Implement systemd-resolved dnssec validation (DS record not supported by my current registrar)
- Misc :
    * [ ] Autounseal vault (issue opened to support kubernetes proxy verb https://github.com/lrstanley/vault-unseal/issues/41)
    * [ ] Fix DHCPv6
