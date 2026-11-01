# Setup openbao
[working-directory: '../ansible']
openbao:
    ansible-playbook deploy_infra.yml --limit openbao

# Setup generate_certs
[working-directory: '../ansible']
generate_certs:
    uv run ansible-playbook playbooks/generate-certs.yml
