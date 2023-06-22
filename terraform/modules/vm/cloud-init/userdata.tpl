#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}
package_update: true
package_upgrade: true