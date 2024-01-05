## with devcontainer <small>recommended</small>

Just rebuild the container

## with binaries

1. Update binaries

2. Update python packages

    ```sh
    source venv/bin/activate
    python3 -m pip install --upgrade pip
    pip install --upgrade '.[ansible,terraform,octodns,documentation]'
    ```

3. Update packer plugins

    ```sh
    cd packer
    packer init --upgrade templates/ubuntu
    ```

4. Update terraform plugins

    ```sh
    cd terraform/prod
    terragrunt run-all init --upgrade
    ```
