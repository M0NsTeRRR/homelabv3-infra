# snmp-exporter

[SNMP Exporter](https://github.com/prometheus/snmp_exporter) this exporter is the recommended way to expose SNMP data in a format which Prometheus can ingest.

## How to generate snmp-exporter configuration ?

SNMP v3 must be enabled and configured on all devices.

Download the mib files :

- [Mikrotik mib](https://mikrotik.com/download)
- [Brocade](https://support.ruckuswireless.com/software)
- Qnap : Go to Control Panel > Network & File Services > SNMP and Under SNMP MIB, click Download.

Don't forget to change in the following configuration :

- `<snmp_exporter_username>`
- `<snmp_exporter_pass>`
- `<snmp_exporter_private>`

``` title="snmp-generator.yml" linenums="1"
--8<-- "docs/guide/snmp-exporter/snmp-generator.yml"
```

Follow instructions step from [snmp-exporter documentation](https://github.com/prometheus/snmp_exporter/tree/main/generator#snmp-exporter-config-generator)

Configure snmp-exporter config to use the appropriate crendentials
