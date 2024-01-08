# Welcome to my homelab documentation

This is the third version of my homelab :rocket:

~~v1 : [Personnal-docker-config](https://github.com/M0NsTeRRR/Personnal-docker-config)~~  
~~v2 : [Homelab-infra](https://github.com/M0NsTeRRR/Homelab-infra)~~  
v3 : [homelabv3-infra](https://github.com/M0NsTeRRR/homelabv3-infra)

## What are the key features

- [x] Open source
- [x] Dual stacks IPv4/IPv6
- [x] Privacy
- [x] Security
- [x] Monitoring, logging and alerting
- [x] Manage everything except :
    * [ ] Public DNS
    * [ ] Emails
- [x] Eveything is automated with scripts, IaC, etc except :
    * [ ] Hypervisor installation but can be done with [netboot.xyz](https://netboot.xyz/)
    * [ ] Networking hardware (routers, switchs)

## Roadmap

- Prometheus rule :
    * [ ] external dns
    * [ ] traefik
    * [ ] trust-manager
- Kubernetes :
    * [ ] Kubernetes node firewalling
    * [ ] Kubernetes policies rules
    * [ ] Etcd encryption
- Documentation :
    * [ ] Explain architecture
    * [ ] Explain project motivation
    * [ ] Explain project choice (applications, hardwares, providers)
- Monitoring/Logging/Alerting :
    * [x] Kubernetes cluster
    * [ ] Outside kubernetes services
    * [ ] Hypervisors
    * [ ] VM
- Misc :
    * [ ] Autounseal vault
    * [ ] Fix DHCPv6
    * [ ] Implement systemd-resolved dnssec validation
