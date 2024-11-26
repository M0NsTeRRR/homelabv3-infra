ansible_dir := "ansible"
argocd_dir := "argocd"

[group('ansible')]
ansible_dhcp:
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit dhcp

[group('ansible')]
ansible_dns:
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit dns

[group('ansible')]
ansible_status:
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit status

[group('ansible')]
ansible_vpn:
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit vpn

[group('ansible')]
ansible_kubernetes:
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit kubernetes --skip-tags vault --skip-tags argocd

[group('kubernetes')]
kubernetes_base:
    cd {{ argocd_dir }}/infra/gateway-api-crds && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/monitoring/prometheus-operator-crds && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/cilium && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/metallb-system && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/external-secrets && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/ingress-internal && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/ingress-external && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/backup/external-snapshotter && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/storage/rook-ceph && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/storage/rook-ceph-cluster && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/cert-manager && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/trust-manager && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}/infra/vault && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit kubernetes_master\[0\] --tags vault
    cd {{ argocd_dir }}infra/cert-manager-scaleway && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}infra/external-dns-internal && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ argocd_dir }}infra/external-dns-external && kustomize build --enable-helm | kubectl apply --server-side -f -
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit kubernetes_master\[0\] --tags argocd
