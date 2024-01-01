#!/bin/bash

# Set kubeconfig in bashrc
echo 'export KUBECONFIG=$(for YAML in $(find ${HOME}/.kube -maxdepth 1 -type f -name '\''*'\'') ; do echo -n ":${YAML}"; done)' >> /etc/bash.bashrc

# install PKI
sudo cp ssl/unicornafk.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# install python packages
pip install '.[ansible,terraform,octodns,documentation]'

# setup packer
packer init packer/templates/ubuntu

# setup ansible
ansible-galaxy install -r ansible/requirements.yml