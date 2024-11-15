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
    cd {{ argocd_dir }}/infra/gateway-api-crds && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/monitoring/prometheus-operator-crds && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/cilium && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/metallb-system && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/external-secrets && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/ingress-internal && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/ingress-external && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/backup/external-snapshotter && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/storage/rook-ceph && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/storage/rook-ceph-cluster && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/cert-manager && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}/infra/trust-manager && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }} && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit kubernetes_master\[0\] --tags vault
    cd {{ argocd_dir }}infra/cert-manager-scaleway && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}infra/external-dns-internal && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ argocd_dir }}infra/external-dns-external && kubectl kustomize --enable-helm | kubectl create -f -
    cd {{ ansible_dir }} && ansible-playbook deploy_infra.yml --limit kubernetes_master\[0\] --tags argocd
