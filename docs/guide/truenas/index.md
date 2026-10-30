# Truenas

## What is Truenas ?

[Truenas](https://www.truenas.com/) is a family of network-attached storage (NAS) products produced by iXsystems, incorporating both FOSS, as well as commercial offerings.

## ACME DNS Challenge with OpenBao PKI and MikroTik DNS

TrueNAS only supports the `DNS-01` challenge and has no MikroTik authenticator. The built-in `shell` authenticator is used with a small script that creates and removes the `_acme-challenge` TXT record through the RouterOS REST API.


1. Connect to truenas through SSH with your user (do not use root)
2. Create the credentials file `/home/admin/.acme-mikrotik` with `chmod 600`. The file is sourced by the shell, quote the password with single quotes if it contains special characters

    ```bash
    MIKROTIK_USER=<TO_REPLACE>
    MIKROTIK_PASS=<TO_REPLACE>
    ```

3. Create the script `/mnt/ssd-sata/scripts/acme-mikrotik.sh`, owned by the authenticator user with `chmod 700`

    ```sh
    #!/bin/sh
    # Called by the TrueNAS shell authenticator:
    # script set|unset <domain> <validation_name> <validation_content>
    set -eu
    ACTION="$1"; NAME="$3"; VALUE="${4:-}"
    . /home/admin/.acme-mikrotik
    HOST="https://r1.unicornafk.fr"

    api() {
      esc=$(printf '%s:%s' "$MIKROTIK_USER" "$MIKROTIK_PASS" | sed 's/\\/\\\\/g; s/"/\\"/g')
      printf 'user = "%s"\n' "$esc" |
        curl -fsS -m 15 -K - -H 'content-type: application/json' "$@"
    }

    case "$ACTION" in
      set)
        body=$(jq -n --arg n "$NAME" --arg t "$VALUE" '{name:$n,type:"TXT",text:$t,ttl:"1m"}')
        api -X PUT "$HOST/rest/ip/dns/static" -d "$body" >/dev/null ;;
      unset)
        list=$(api "$HOST/rest/ip/dns/static?name=$NAME&type=TXT")
        ids=$(printf '%s' "$list" | jq -r --arg t "$VALUE" '.[] | select(.text == $t) | .".id"')
        for id in $ids; do api -X DELETE "$HOST/rest/ip/dns/static/$id" >/dev/null; done ;;
      *) echo "unknown action: $ACTION" >&2; exit 2 ;;
    esac
    ```

4. Test the script by hand, the TXT record must appear on the router and then disappear

    ```bash
    N=_acme-challenge.test.unicornafk.fr
    /mnt/ssd-sata/scripts/acme-mikrotik.sh set x $N test
    dig +short TXT $N @r1.unicornafk.fr
    /mnt/ssd-sata/scripts/acme-mikrotik.sh unset x $N test
    ```

5. Create the ACME DNS authenticator: `Credentials` > `Certificates` > `ACME DNS-Authenticators` > `Add`
    - Name: `mikrotik-r1`
    - Authenticator: `shell`
    - Script: `/mnt/ssd-sata/scripts/acme-mikrotik.sh`
    - User: the user that owns the script
    - Timeout: `60`
    - Delay (propagation): `10`

6. Create the CSR: `Credentials` > `Certificates` > `Certificate Signing Requests` > `Add CSR`
    - Identifier: `nas-acme-csr`
    - Key Type: `EC` with the curve `SECP384R1`
    - Digest Algorithm: `SHA384`
    - Common Name: `nas.unicornafk.fr`
    - Subject Alternative Name: `nas.unicornafk.fr` (the Common Name alone is not enough)

7. Create the ACME certificate from the CSR: in `Certificate Signing Requests`, open the actions of `nas-acme-csr` > `Create ACME Certificate`
    - Identifier: `nas-acme`
    - Accept the `Terms of Service`
    - ACME Directory URI: `https://openbao.unicornafk.fr:8200/v1/pki/acme/directory`
    - Renew Certificate Days: `10` (TrueNAS renews the certificate by itself this many days before the expiration)
    - Authenticator: `mikrotik-r1` for `nas.unicornafk.fr`

    !! info "`nas-acme` also appears in the CSR list"

        The UI lists every entry that keeps a CSR in `Certificate Signing Requests`. `nas-acme` is the signed certificate (it is also in `Certificates`), do not delete it. `nas-acme-csr` can be deleted once the certificate is issued
