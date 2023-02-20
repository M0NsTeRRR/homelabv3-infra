This is my Homelab v3 infrastructure.

![Ansible Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Ansible%20Lint/badge.svg)
![Packer Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Packer%20Lint/badge.svg)
![Terraform Lint](https://github.com/M0NsTeRRR/homelabv3-infra/workflows/Terraform%20Lint/badge.svg)

# Requirements

- Ansible core (version >= 2.14)
  - Python3 and Pip
- Packer (version >= 1.8)
  - Packer builder arm
- Terraform (version >= 1.3)
  - Terragrunt (version >= 0.43)

Install python dependencies `pip3 install -r requirements.txt`

Set environment variable `ANSIBLE_VAULT_PASS` like `export ANSIBLE_VAULT_PASS='password'`

# Ansible

`cd ansible`

Fill certs folders

Install ansible galaxy dependencies `ansible-galaxy install -r requirements.yml`

fill all `secrets.yml` based on `secrets.example` in each subdirectory of `groups_vars`

### Playbooks to add fingerprint on know_hosts

`ansible-playbook -i hosts playbooks/add-ssh-keys.yml`

### Playbooks to create client certificate signed by a CA

`ansible-playbook -i hosts playbooks/generate-certs.yml`

### Playbooks to deploy a zone

`ansible-playbook -i hosts deploy_<zone>.yml`
Replace `<zone>` by the appropriate zone name

# Packer
`cd packer`

Init packer plugins
`packer init packer/templates/debian`

Port 8888 used for debian build

Open both ports on windows firewall
Start powershell prompt with admin right `netsh interface portproxy add v4tov4 listenaddress=<WINDOWS IP> connectaddress=<WSL IP> listenport=<WINDOWS PORT> connectport=<WSL PORT>`
Replace <IP> with the LAN IP of your PC and <PORT> with [8888]
To delete the rules `netsh interface portproxy del v4tov4 listenaddress=<IP> listenport=<PORT>`

Supported distributions :

**VM**

- Debian 11.6.0

**Raspberry Pi (v3/v4)**

- Ubuntu 22.04.1

### Create template

`./build.sh` (sudo permission required for Raspberry Pi choice only)

# Terraform

`cd terraform`

fill all `secrets.env` based on `secrets.example` and encrypt it with `ansible-vault`

Export environment variables with `./vars.sh`

**Command must be run in one of this directories (prod/vpn)**

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
