FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set kubeconfig in bashrc
RUN echo 'export KUBECONFIG=$(for YAML in $(find ${HOME}/.kube -maxdepth 1 -type f -name '\''*'\'') ; do echo -n ":${YAML}"; done)' >> /etc/bash.bashrc

# Set REQUESTS_CA_BUNDLE for python script
RUN echo 'export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"' >> /etc/bash.bashrc
RUN echo 'alias k=kubectl' >> /etc/bash.bashrc
