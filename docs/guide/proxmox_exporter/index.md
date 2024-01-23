# proxmox-exporter

[Proxmox Exporter](https://github.com/prometheus-pve/prometheus-pve-exporter) this is an exporter that exposes information gathered from Proxmox VE node for use by the Prometheus monitoring system.

## How to reate a superivision user ?

1. Login to a proxmox node through web ui.
2. Go to Datacenter > Permissions > Users
3. Create an user
4. Go to Datacenter > Permissions
5. Assign to the new user the `PVEAuditor` role

Configure proxmox-exporter config to use the appropriate crendentials
