# Truenas

## What is Truenas ?

[Truenas](https://www.truenas.com/) is a family of network-attached storage (NAS) products produced by iXsystems, incorporating both FOSS, as well as commercial offerings.

## ACME DNS Challenge with vault PKI and PDNS

1) Install acme.sh
2) Create Truenas API Key
3) Install CA certificate in Truenas
4) export below variables

```bash
# PDNS
export PDNS_Url=<TO_REPLACE>
export PDNS_ServerId=localhost
export PDNS_Token=<TO_REPLACE>
export PDNS_Ttl=60
# PKI CA
export CA_CERT_PATH=/etc/ssl/certs/ca-certificates.crt
# Truenas
export DEPLOY_TRUENAS_APIKEY=<TO_REPLACE>
export DEPLOY_TRUENAS_SCHEME=https
```

5) Register ACME server `./acme.sh --set-default-ca --server <vault_acme_url>` (in my case `https://vault.unicornafk.fr:8200/v1/pki/acme/directory`)
6) Register DNS issuer `./acme.sh --issue --dns dns_pdns -d <truenas_fqdn> --ca-bundle ../ca.crt --dnssleep 30 --insecure --deploy --deploy-hook truenas`
7) Setup systemd timer unit
