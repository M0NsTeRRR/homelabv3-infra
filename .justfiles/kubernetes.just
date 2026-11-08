set working-directory := '../kubernetes'

# Bootstrap kubernetes cluster
bootstrap: update-openbao-certs init-flux-pgp-keys init-homelab-ca
    helmfile template -f bootstrap/crds.yaml -q | yq ea -r -e 'select(.kind == "CustomResourceDefinition")' | kubectl apply --server-side --force-conflicts -f -
    helmfile sync -f bootstrap/apps.yaml --hide-notes

# Update openbao certificates
update-openbao-certs:
    kubectl create namespace openbao --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n openbao create secret generic openbao-server-tls \
      --from-file=openbao.crt=../ssl/homelab/openbao.unicornafk.fr/openbao.unicornafk.fr-fullchain.crt \
      --from-file=openbao.key=../ssl/homelab/openbao.unicornafk.fr/openbao.unicornafk.fr.key \
      --dry-run=client -o yaml | kubectl apply -f -

# Update flux PGP public keys
init-flux-pgp-keys:
    kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n flux-system create secret generic pgp-public-keys \
      --from-file=../kubernetes/apps/flux-system/flux-instance/app/ressources/M0NsTeRRR.asc \
      --from-file=../kubernetes/apps/flux-system/flux-instance/app/ressources/github-web-flow.asc \
      --dry-run=client -o yaml | kubectl apply -f -

# Seed homelab-ca ConfigMap (flux-operator mounts it before trust-manager exists; trust-manager takes over later)
init-homelab-ca:
    kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n flux-system create configmap homelab-ca \
      --from-file=ca.crt=../ssl/unicornafk.crt \
      --dry-run=client -o yaml | kubectl apply -f -

# Init openbao
configure-openbao:
    cd ../ansible && uv run ansible-playbook deploy_infra.yml --limit kubernetes

# Prune pods in Failed, Pending, or Succeeded state
prune-pods:
    for phase in Failed Pending Succeeded; do \
      kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
    done
