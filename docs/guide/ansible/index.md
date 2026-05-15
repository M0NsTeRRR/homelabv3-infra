# Ansible

## What is Ansible ?

[Ansible](https://www.ansible.com/) gives the ability to do software provisioning, configuration management, and application deployment functionality. It will allow us to deploy generic configuration to Packer template and applications.

## Usage

### List of playbooks

| Playbook                           | Description                                                          |
| ---------------------------------- | -------------------------------------------------------------------- |
| `playbooks/generate-certs.yml`     | Generate certificate for a machine from PKI                          |

### Execute

Configuration is stored in `ansible` folder.

Fill `ssl` folders with certificates.
Fill `.vault_password.txt` at root with ansible vault password used.

`PLAYBOOK` represents the playbook file used to deploy

```sh
uv run task ansible:<dns|dhcp|status>
```

!!! info "KUBECONFIG environment variable is hardcoded to `/home/vscode/.kube/homelab` in `.devcontainer/Dockerfile` and context is set to `default` in `.devcontainer/postCreateCommand.sh`"
