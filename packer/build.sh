#!/usr/bin/env bash
export PACKER_CACHE_DIR=packer_cache

set -e

ssh_fullname="ludovic ortega"
ssh_username=lortega
ssh_password=ludovic
proxmox_node=server1
host_ip="192.168.30.21"
ssh_autorized_key=$(<../ssh_pub_keys/${ssh_username}.pub)

proxmox_url='https://server1.unicornafk.fr:8006/api2/json'
proxmox_username='root@pam'

read -sp 'Proxmox password: ' proxmox_password
printf "\n"

packer build \
  -var "host_ip=$host_ip" \
  -var "proxmox_url=$proxmox_url" \
  -var "proxmox_username=$proxmox_username" \
  -var "proxmox_password=$proxmox_password" \
  -var "proxmox_node=$proxmox_node" \
  -var "ssh_fullname=$ssh_fullname" \
  -var "ssh_username=$ssh_username" \
  -var "ssh_password=$ssh_password" \
  -var "ssh_password_encrypted=$(mkpasswd -m sha-512 --rounds=4096 $ssh_password)" \
  -var "ssh_autorized_key=$ssh_autorized_key" \
  -timestamp-ui \
  templates/ubuntu
