FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set kubeconfig in bashrc
RUN echo 'export KUBECONFIG=$(for YAML in $(find ${HOME}/.kube -maxdepth 1 -type f -name '\''*'\'') ; do echo -n ":${YAML}"; done)' >> /etc/bash.bashrc