# Getting started

Install git and clone the project
```sh
apt install -y git
git clone https://github.com/M0NsTeRRR/homelabv3-infra.git
```

!!! warning
    This guide assumes the following :

    * You have configured an SSH agent with your SSH keys
    * You have ghcr.io configured with a github token (needed for OCI helm chart) with Public Repositories (read-only) access (`cat ~/github_token.txt | docker login ghcr.io -u m0nsterrr --password-stdin`)
