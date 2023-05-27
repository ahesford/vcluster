# Configurations for `mkinitcpio`

This directory contains configurations for the nodes of a simple Void cluster.
All nodes share a comman root filesystem, then mount a
[tmpfs(5)](https://man.voidlinux.org/tmpfs.5) overlay atop that for local,
ephemeral changes. One node, the master, contains a disk that holds and serves
the underlying filesystem via NFSv4. The initramfs image that will be booted by
the master is configured with `mkinitcpio.conf`, while the client nodes will
boot a TFTP-served initramfs image configured with `mkinitcpio.net.conf`.
Because most of the configuration is common between both images, the client
configuration just sources the master and overrides the unique parts.

> NOTE: The `rc.local.hook` may be important unless your DHCP server is
> configured to assign a unique hostname to each client, and your DHCP client
> is properly configured to honor that hostname. Otherwise, every node that
> boots the client image will inherit the same NFSv4 client ID. Eventually,
> this may cause the NFS server to detect conflicting IDs and refuse to
> communicate with one or more clients. The `rc.local.hook` script that runs
> within the client initramfs will identify each client's MAC address, make
> sure the NFSv4 kernel module is loaded, and set each client ID to an MD5 sum
> of the MAC address. This should ensure that each client connects to the NFS
> server with a unique ID.

## Installation

Copy the configuration files to `/etc`:

    cp mkinitcpio.conf mkinitcpio.net.conf /etc

Copy the custom initramfs hook script where the configuration expects it:

    mkdir -p /etc/initcpio
    cp rc.local.hook /etc/initcpio

If desired, install a Void kernel post-install hook to easily update the client
image when reconfiguring the kernel:

    cp kernel-hook.tftp.sh /etc/kernel/post-install/25-tftpboot

## Dependencies

The `mkinitcpio` configurations depend on two non-standard modules:

1. [mkinitcpio-overlayfs](https://github.com/ahesford/mkinitcpio-overlayfs)
2. [mkinitcpio-rclocal](https://github.com/ahesford/mkinitcpio-rclocal)

The easiest way to install these hooks is to add them to `/etc/initcpio`:

    git clone https://github.com/ahesford/mkinitcpio-overlayfs
    mkdir -p /etc/initcpio/hooks /etc/initcpio/install
    cp mkinitcpio-overlayfs/mkinitcpio-overlayfs.hook /etc/initcpio/hooks/overlayfs
    cp mkinitcpio-overlayfs/mkinitcpio-overlayfs.install /etc/initcpio/install/overlayfs

for `mkinitcpio-overlayfs`, and

    git clone https://github.com/ahesford/mkinitcpio-rclocal
    mkdir -p /etc/initcpio/hooks /etc/initcpio/install
    cp mkinitcpio-rclocal/rclocal_hook /etc/initcpio/hooks/rclocal
    cp mkinitcpio-rclocal/rclocal_install /etc/initcpio/install/rclocal

Default configurations of `mkinitcpio` should recognize the hooks so installed.
