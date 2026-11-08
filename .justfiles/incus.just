set working-directory := '..'

import 'common.just'

domain := 'unicornafk.fr'
bootstrap_node := 'server1'
bootstrap_address := '192.168.40.11'
nic := 'enp3s0'
ca_cert := 'ssl/unicornafk.crt'
acme_ca_url := 'https://openbao.unicornafk.fr:8200/v1/pki/acme/directory'
acme_email := 'admin@unicornafk.fr'
acme_domains := 'server.unicornafk.fr,server1.unicornafk.fr,server2.unicornafk.fr,server3.unicornafk.fr'
oidc_client_id := 'incus'
oidc_issuer := 'https://sso.unicornafk.fr/oauth2/openid/incus'

# Bootstrap the Incus cluster from the first node (installed with the default configuration)
bootstrap: (custom-ca bootstrap_node) && configure networks list
    incus config set {{ bootstrap_node }}: cluster.https_address={{ bootstrap_address }}:8443
    incus cluster enable {{ bootstrap_node }}: {{ bootstrap_node }}.{{ domain }}
    -incus remote remove {{ cluster }}
    incus remote add {{ cluster }} {{ bootstrap_node }}.{{ domain }}:8443 --auth-type tls --accept-certificate
    -incus remote switch local
    incus remote remove {{ bootstrap_node }}

# Join a node to the cluster (add it first with `incus remote add <node> <node>.unicornafk.fr`)
[arg('node', pattern='server[0-9]+')]
join node: (custom-ca node) && list
    @echo "Answers expected: local pool source and zfs.pool_name = local/incus, network parent = {{ nic }}"
    incus cluster join {{ cluster }}: {{ node }}:
    incus remote remove {{ node }}

# Install the custom CA on an IncusOS server (remote name, before it joins), replaces its custom_ca_certs
# Start from the current config: `edit` replaces everything and would drop encryption_recovery_keys
# The server is rebooted because the running Incus daemon only reads the system CAs at startup
custom-ca remote:
    incus admin os system security show {{ remote }}: 2>/dev/null | yq '{"config": .config} | .config.custom_ca_certs = [load_str("{{ ca_cert }}")]' | incus admin os system security edit {{ remote }}:
    incus admin os system reboot {{ remote }}: --force
    @sleep 15
    @until incus admin os system security show {{ remote }}: >/dev/null 2>&1; do echo "Waiting for {{ remote }} to come back..."; sleep 5; done

# Configure ACME and OIDC on the cluster (cluster wide settings)
configure:
    incus config set {{ cluster }}: \
        acme.agree_tos=true \
        acme.ca_url={{ acme_ca_url }} \
        acme.domain={{ acme_domains }} \
        acme.email={{ acme_email }} \
        oidc.claim=sub \
        oidc.client.id={{ oidc_client_id }} \
        oidc.issuer={{ oidc_issuer }} \
        oidc.scopes=openid,profile,email

# Create the prod and lab networks, joining members are prompted for their parent during the join
networks:
    incus network create {{ cluster }}:prod --target {{ bootstrap_node }}.{{ domain }} parent={{ nic }}
    incus network create {{ cluster }}:lab --target {{ bootstrap_node }}.{{ domain }} parent={{ nic }}
    incus network create {{ cluster }}:prod --type=physical vlan=10
    incus network create {{ cluster }}:lab --type=physical vlan=20

# List cluster members
list:
    incus cluster list {{ cluster }}:
