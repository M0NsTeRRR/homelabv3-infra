set working-directory := '..'

namespace := 'kaniop'
domain := 'sso.unicornafk.fr'
admin_secret := 'kanidm-admin-passwords'

# Apply all users (injects SSH keys from flatcar/ssh_pub_keys/<name>.pub if present)
apply-users:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in users/*.yaml; do
      name=$(basename "$f" .yaml)
      pubkey_file="flatcar/ssh_pub_keys/${name}.pub"
      if [ -f "$pubkey_file" ]; then
        SSH_KEY=$(cat "$pubkey_file") yq e '.spec.sshPublicKeys.default = env(SSH_KEY)' "$f" | kubectl apply -f -
      else
        kubectl apply -f "$f"
      fi
    done

# Send a credential reset token to a Kanidm user (local=true prints the token instead)
reset-password user local='false':
    #!/usr/bin/env bash
    set -euo pipefail
    admin=$(kubectl get secret {{ admin_secret }} -n {{ namespace }} -o jsonpath='{.data.IDM_ADMIN_USERNAME}' | base64 -d)
    export KANIDM_PASSWORD=$(kubectl get secret {{ admin_secret }} -n {{ namespace }} -o jsonpath='{.data.IDM_ADMIN_PASSWORD}' | base64 -d)
    kanidm login --name "$admin" --url https://{{ domain }}
    if [ "{{ local }}" = "true" ]; then
      kanidm person credential create-reset-token {{ user }} --name "$admin" --url https://{{ domain }}
    else
      kanidm person credential send-reset-token {{ user }} --name "$admin" --url https://{{ domain }}
    fi
