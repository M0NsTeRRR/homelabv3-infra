#!/usr/bin/env bash
export PACKER_CACHE_DIR=packer_cache

set -e

ssh_fullname="ludovic ortega"
ssh_username=lortega
ssh_password=ludovic
host_ip="192.168.30.21"
ssh_autorized_key=$(<../ssh_pub_keys/${ssh_username}.pub)

echo -e "Please enter your choice: \n1) VM\n2) Raspberry Pi\n"
while :
do
  read CHOICE
  case $CHOICE in
	1)
    vcenter_server='vcenter.unicornafk.fr'
    vcenter_username='administrator@unicornafk.fr'

    read -sp 'Vcenter password: ' vcenter_password
    printf "\n"

    packer build \
      -var "host_ip=$host_ip" \
      -var "vcenter_server=$vcenter_server" \
      -var "vcenter_username=$vcenter_username" \
      -var "vcenter_password=$vcenter_password" \
      -var "ssh_fullname=$ssh_fullname" \
      -var "ssh_username=$ssh_username" \
      -var "ssh_password=$ssh_password" \
      -var "ssh_password_encrypted=$(mkpasswd -m sha-512 --rounds=4096 $ssh_password)" \
      -var "ssh_autorized_key=$ssh_autorized_key" \
      -timestamp-ui \
      templates/ubuntu
		break
		;;
	2)
    read -sp 'VM new password: ' ssh_new_password
    printf "\n"

    packer build \
      -var "fullname=$ssh_fullname" \
      -var "username=$ssh_username" \
      -var "password=$ssh_new_password" \
      -timestamp-ui \
      templates/raspi
		break
		;;
  *)
    break
    ;;
  esac
done
