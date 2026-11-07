# IncusOS

## What is IncusOS ?

[IncusOS](https://linuxcontainers.org/incus-os/) is an immutable OS solely designed around safely and reliably running Incus. Incus is a next-generation system container, application container, and virtual machine manager.

## Install IncusOS

1. Go to the [IncusOS image downloader](https://incusos-customizer.linuxcontainers.org/ui/).
2. In installation target `Wipe the target drive` must be checked.
3. In target drive identifier, put `wwn`
4. In application configuration `Apply default configuration` must be checked **only** for server1.
5. In TLS client certificate copy the output of `incus remote get-client-certificate`
6. In the advanced settings, paste the network configuration from `incusos/serverX/network.yaml` (where `X` represents the server number).
7. Download the ISO.
8. [Configure the BIOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/installation/physical/).
9. Boot from the ISO.
10. Install and reboot
11. [Connect to IncusOS](https://linuxcontainers.org/incus-os/docs/main/getting-started/access/#connecting-to-incusos)

## Post install setup

Add each server as a remote **and retrieve its encryption recovery key** in `OS` > `System` > `Security`.
```fish
incus remote add server1 server1.unicornafk.fr
incus remote add server2 server2.unicornafk.fr
incus remote add server3 server3.unicornafk.fr
```

!!! warning
    Do **not** create networks, storage volumes, profiles or instances on a server before it has joined the cluster.
    A joining server must be empty: it cannot have preexisting networks, storage pools, volumes, profiles or instances.
    Otherwise `incus cluster join` fails. Create everything **after** the cluster is formed.

## Create the cluster

`just incus bootstrap`

It creates the cluster `homelab` and theses ressources.

### Join server2 and server3

The join asks for the member-specific configuration: for the `local` storage pool use `local/incus` as value for `source` and `zfs.pool_name`, and for the `prod` and `lab` networks use `enp3s0` as `parent`.
Once joined, the recipe removes the node remote.

If a previous attempt left a `cluster.https_address` on a server, it can be reset with a reinstall (see [Wipe a drive](#wipe-a-drive)).

## Usage

### Task

Use `just --list flatcar` to find the Flatcar recipes for deploying the base VM infrastructure.

Once the cluster is formed, run `just flatcar add-image` and `just flatcar add-profile` once, then `just flatcar deploy`. Each node gets its own `flatcar-<node>` volume holding its EFI files and ignition.

### Update the flatcar nodes

The flatcar nodes are not updated in place: each VM is replaced with a fresh one built from the new ignition, and its data disk (rook-ceph) is kept.

1. Download and import the new image:
    ```fish
    just flatcar add-image
    ```
2. Replace the nodes:
    ```fish
    # all nodes, one at a time
    just flatcar replace

    # or a single node
    just flatcar replace-node k8s-1
    ```

For each node, `replace-node` checks that the three nodes are `Ready` and Ceph is `HEALTH_OK`, drains and deletes the node, deletes the VM and its `flatcar-<node>` volume, deploys the new VM, then waits for the node to be `Ready` and Ceph to be `HEALTH_OK` again before moving on.

## Tips

### List hardware ressources

```fish
incus query /1.0/resources
```

### Wipe a drive

```fish
incus admin os system storage wipe-drive -d '{"id":"/dev/disk/by-id/<disk-id>"}'
```
