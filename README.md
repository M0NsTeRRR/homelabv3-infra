This is my Homelab v3 infrastructure.

![Ansible Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Ansible%20Lint/badge.svg)
![Packer Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Packer%20Lint/badge.svg)
![Terraform Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Terraform%20Lint/badge.svg)
![Octodns](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Octodns/badge.svg)

# Requirements

- Python3 and Pip
- Packer
  - Packer builder arm (needed for rpi build)
- Terraform
  - Terragrunt
- Docker (needed for kube-vip manifest generation)

Create venv `python3 -m venv venv`  
Source venv `source venv/bin/activate`  
Upgrade pip `python3 -m pip install --upgrade pip`  
Install python dependencies `pip install '.[ansible,terraform,octodns]'`  

# Ansible

`cd ansible`

Fill certs folders

Install ansible galaxy dependencies `ansible-galaxy install -r requirements.yml`

fill all `.vault_password.txt` at root with ansible vault password used   
fill all `secrets.yml` based on `secrets.example` in each subdirectory of `groups_vars`  
fill `inventory.vmware.yml` and encrypt it with `vault` based on `inventory.vmware.example`

### Playbooks to create client certificate signed by a CA

`ansible-playbook playbooks/generate-certs.yml`

### Playbooks to deploy a zone

`ansible-playbook deploy_<zone>.yml`  
Replace `<zone>` by the appropriate zone name  

# Packer
`cd packer`

Init packer plugins
`packer init packer/templates/ubuntu`

Port 8888 used for ubuntu build

Open both ports on windows firewall
Start powershell prompt with admin right `netsh interface portproxy add v4tov4 listenaddress=<WINDOWS IP> connectaddress=$($(wsl hostname -I).Trim()) listenport=<WINDOWS PORT> connectport=<WSL PORT>`  
Replace <IP> with the LAN IP of your PC and <PORT> with [8888]
To delete the rules `netsh interface portproxy del v4tov4 listenaddress=<IP> listenport=<PORT>`

### Supported distributions :

**VM**

- Ubuntu

**Raspberry Pi (v3/v4)**

- Ubuntu

### Create template

To init packer plugin `packer init templates/ubuntu`  

`./build.sh` (sudo permission required for Raspberry Pi choice only)

# Terraform

`cd terraform`

fill all `account.hcl` based on `account.example`  

**Command must be run in this directory (prod)**

### Create an execution plan

`terragrunt run-all plan`

### Deploy/update infrastructure

`terragrunt run-all apply`

# Licence

The code is under CeCILL license.

You can find all details here: https://cecill.info/licences/Licence_CeCILL_V2.1-en.html

# Credits

Copyright © Ludovic Ortega, 2023

Contributor(s):

-Ortega Ludovic - ludovic.ortega@adminafk.fr
