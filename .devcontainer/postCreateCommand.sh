#!/bin/bash

# install python packages
uv sync --all-extras

# install minijinja-cli
cargo install minijinja-cli

# Setup bash completion
task --completion bash >> /home/vscode/.bashrc
minijinja-cli --generate-completion bash >> /home/vscode/.bashrc

# setup packer
packer init packer/templates/ubuntu

# setup ansible
uv run ansible-galaxy install -r ansible/requirements.yml

# install helm plugins
helm plugin install https://github.com/databus23/helm-diff

# nixos fix
# see https://github.com/microsoft/vscode-remote-release/issues/11024
git config --global gpg.program "/usr/bin/gpg"

# source venv
source .venv/bin/activate
