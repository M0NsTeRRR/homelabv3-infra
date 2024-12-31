# Truenas

## What is Truenas ?

[Truenas](https://www.truenas.com/) is a family of network-attached storage (NAS) products produced by iXsystems, incorporating both FOSS, as well as commercial offerings.

## ACME DNS Challenge with vault PKI and PDNS

1. Create a dataset (home directories can't execute scripts see [here](https://ixsystems.atlassian.net/browse/NAS-127825))
2. Select an user and create an API Key for it
3. Connect to truenas through SSH with your user and execute every action with it (do not use root) and move inside your new dataset
4. Clone acme.sh `git clone https://github.com/acmesh-official/acme.sh .acme.sh`
5. Create an env file `/home/<user>/.acme.sh.env` with the below contents

```bash
# PDNS
PDNS_Url=<TO_REPLACE>
PDNS_ServerId=localhost
PDNS_Token=<TO_REPLACE>
PDNS_Ttl=60
# PKI CA
CA_CERT_PATH=/etc/ssl/certs/ca-certificates.crt
# Truenas
DEPLOY_TRUENAS_APIKEY=<TO_REPLACE>
DEPLOY_TRUENAS_SCHEME=https
```

6. Change your current directory to acme.sh project `cd .acme.sh`
7. Register ACME server `./acme.sh --set-default-ca --server <vault_acme_url> --home /home/admin` (in my case `https://vault.unicornafk.fr:8200/v1/pki/acme/directory`)
8. Register DNS issuer `./acme.sh --issue --insecure --dns dns_pdns -d <truenas_fqdn> --dnssleep 30 --home /home/admin`
9. Deploy the certificate `./acme.sh -d <truenas_fqdn> --insecure --deploy --deploy-hook truenas --home /home/admin`
10. Setup cron through the webui

- Description: ACME.Sh renew certificates
- User: `<user>`
- Schedule: Daily
- Command: `. /home/<user>/.acme.sh.env && "<dataset path>/.acme.sh"/acme.sh --issue --dns dns_pdns -d <truenas_fqdn> --dnssleep 30 --insecure --deploy --deploy-hook truenas --ca-bundle /home/admin/ca.crt --home /home/admin`

12. If you want to check if your cron is successfull run it and check the log with

```bash
cat /var/log/syslog | grep -w 'cron'
```

!! info "sudo is broken https://ixsystems.atlassian.net/browse/NAS-131540"
