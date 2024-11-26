## with devcontainer <small>recommended</small>

1. Follow [DevContainer documentation](https://code.visualstudio.com/docs/devcontainers/containers) to install it
2. Build the container

!!! info

    * Every files ending in `.crt` in `ssl` folders are copied to `/usr/local/share/ca-certificates` inside
    the devcontainer to validate PKI
    * Every files in `~/.kube` of your current user will be copied to `/home/vscode/.kube` and exported to `$KUBECONFIG`

## with binaries

1. Install (versions are pinned in configuration files)

    * [Uv](https://docs.astral.sh/uv/getting-started/installation/)
    * [Packer](https://developer.hashicorp.com/packer/install)
    * [Terraform](https://developer.hashicorp.com/terraform/install)
    * [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
    * [Kubectl](https://kubernetes.io/docs/tasks/tools/)
    * [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
    * [Helm](https://helm.sh/docs/intro/install/)

2. Setup python

    ```sh
    uv --sync-extras
    ```

    !!! info

        Don't forget to source python environment when opening a new shell before doing anything

3. Install root ca certificates on your machine

    ```sh
    sudo cp ssl/*.crt /usr/local/share/ca-certificates
    sudo update-ca-certificates
    ```

4. Init packer plugins

    ```sh
    cd packer
    packer init templates/ubuntu
    ```

5. Init terraform plugins

    ```sh
    cd terraform/prod
    terragrunt run-all init
    ```
