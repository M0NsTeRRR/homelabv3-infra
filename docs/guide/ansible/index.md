# Ansible

## What is Ansible ?

[Ansible](https://www.ansible.com/) gives the ability to do software provisioning, configuration management, and application deployment functionality. It will allow us to deploy generic configuration to Packer template and applications.

## Usage

### Execute

Configuration is stored in `ansible` folder.

Fill `ssl` folders with certificates.
Fill `.vault_password.txt` at root with ansible vault password used.

```sh
uv run task ansible:<openbao|generate_certs>
```

