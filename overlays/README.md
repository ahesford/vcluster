# Per-Node Overlays

This directory contains the necessary pieces of node configuration overlays. A
runit core-service, `03-aa-overlays.sh`, will look for a subdirectory (or at
least one file) in `/etc/overlays` with a name that matches the MAC address,
represented by `${macaddr}`, of the machine. Each archive matching the glob
`/etc/overlays/${macaddr}.*` will be unpacked, if possible, by calling

    tar -xf "${file}" -C /etc

to expand the contents into `/etc` on the running system. Any failure to expand
a file will print a warning but otherwise continue with the boot. Next, if a
directory `/etc/overlays/${macaddr}` exists, its contents will be copied into
the corresponding path in `/etc`.

## Installation

Copy the core service to be executed by runit at boot:

    cp 03-aa-overlays.sh /etc/runit/core-services

Make the overlay directory and copy the master configuration to it:

    mkdir -p /etc/overlays
    read -r _macaddr < /sys/class/net/eth0/address
    cp -r master "/etc/overlays/${_macaddr}"

For every other client machine in the cluster, create a new subdirectory
`/etc/overlays/${_cltmac}`, where `${_cltmac}` is the MAC address of the client
in the same format as `/sys/class/net/eth0/address`, and add custom
configuration overrides in those subdirectories. You should at least assign a
unique hostname to each client, unless your DHCP server will do so.

## Customization

The file `master/exports` defines exports for specific clients in the
`172.23.199.0/24` subnet. Adjust the addresses in this file to suit your
network and client node configuration. The exports expose paths `/srv/nfs`,
`/srv/nfs/root` and `/srv/nfs/home`; the root and home filesystems should be
bind-mounted at these locations. The `master/rc.local` override will perform
the necessary bind mounts.

The links in `master/runit/runsvdir/default` enable the `dnsmasq` server and
NFS server components necessary to serve boot files over TFTP and allow NFS
cients to mount common filesystems. Additional links can be made in
corresponding paths for any node overlay to enable services on a per-node
basis.

The file `master/fstab` defines a mount of the EFI system partition by UUID;
this UUID should be replaced with the value reported by

    lsblk -n -o uuid ${esp_blkdev}

for a device node `${esp_blkdev}` that refers to your specific EFI system
partition.
