# Ansible

## What is Ansible ?

[Ansible](https://www.ansible.com/) gives the ability to do software provisioning, configuration management, and application deployment functionality. It will allow us to deploy generic configuration to Packer template and applications.

## List of supported distributions

Version is pinned in configuration file.

Distributions :

* Ubuntu

## Usage

### List of playbooks

| Playbook                           | Description                                                          |
| ---------------------------------- | -------------------------------------------------------------------- |
| `deploy_infra.yml`                 | Deploy application                                                   |
| `deploy_packer.yml`                | Deploy generic configuration used by every VM                        |
| `playbooks/add-ssh-keys.yml`       | Update fingerprints in `~/.ssh/known_hosts` from all hosts inventory |
| `playbooks/generate-certs.yml`     | Generate certificate for a machine from PKI                          |
| `playbooks/parted.yml`             | Grow last partition to fill all available spaces on disk             |

### Execute

Configuration is stored in `ansible` folder.

Fill `inventory.proxmox.yml` based on `inventory.proxmox.example`.
Fill `ssl` folders with certificates.  
Fill `.vault_password.txt` at root with ansible vault password used.  
Fill all `secrets.yml` based on `secrets.example` in each subdirectory of `groups_vars`.

`PLAYBOOK` represents the playbook file used to deploy

```sh
cd ansible
ansible-playbook <PLAYBOOK>
```

!!! info "KUBECONFIG environment variable is hardcoded to `/home/vscode/.kube/homelab` in `.devcontainer/Dockerfile` and context is set to `default` in `.devcontainer/postCreateCommand.sh`"

!!! bug "Pyyaml does not support [YAML 1.2 core schema](https://github.com/yaml/pyyaml/issues/486), it's why `prometheus-operator-crds` must be manually applied for now : `kubectl kustomize --enable-helm | kubectl create -f -`"

??? question "How to execute only a part of an ansible playbook ?"
    * Filter by hosts

        ```sh
        -l SUBSET, --limit SUBSET # further limit selected hosts to an additional pattern
        ```

    * Filter by tags

        ```sh
        -t TAGS, --tags TAGS # only run plays and tasks tagged with these values. This argument may be specified multiple times.
        ```
