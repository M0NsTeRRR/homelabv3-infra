#!/bin/bash

# install python packages
uv sync --all-extras

# Setup bash completion
task --completion bash >> /home/vscode/.bashrc

# setup packer
packer init packer/templates/ubuntu

# setup ansible
ansible-galaxy install -r ansible/requirements.yml

# install helm plugins
helm plugin install https://github.com/databus23/helm-diff

# source venv
source .venv/bin/activate