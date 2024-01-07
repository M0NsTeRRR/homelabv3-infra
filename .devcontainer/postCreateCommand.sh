#!/bin/bash

# missing package for mkdocs imaging
sudo apt update
sudo apt install -y libcairo2 libcairo2-dev

# Set kubeconfig in bashrc
echo 'export KUBECONFIG=$(for YAML in $(find ${HOME}/.kube -maxdepth 1 -type f -name '\''*'\'') ; do echo -n ":${YAML}"; done)' >> /home/vscode/.zshrc

# Set REQUESTS_CA_BUNDLE for python script
echo 'export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"' >> /home/vscode/.zshrc

# install PKI
sudo cp ssl/*.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# install python packages
pip install '.[ansible,terraform,octodns,documentation]'

# setup packer
packer init packer/templates/ubuntu

# setup ansible
ansible-galaxy install -r ansible/requirements.yml
