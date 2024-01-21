#!/bin/bash

# missing package for mkdocs imaging
sudo apt update
sudo apt install -y libcairo2 libcairo2-dev

# install PKI
sudo cp ssl/*.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# install python packages
pip install '.[ansible,terraform,octodns,documentation]'

# setup packer
packer init packer/templates/ubuntu

# setup ansible
ansible-galaxy install -r ansible/requirements.yml

# use default context
kubectl config use-context default