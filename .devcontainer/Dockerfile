FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN sudo apt update && sudo apt install -y \
    # missing package for mkdocs imaging
    libcairo2 libcairo2-dev

COPY ssl/*.crt /usr/local/share/ca-certificates/
RUN sudo update-ca-certificates

# Set REQUESTS_CA_BUNDLE for python script
RUN echo 'export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"' >> /etc/bash.bashrc
RUN echo 'alias k=kubectl' >> /etc/bash.bashrc
