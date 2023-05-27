# TFTP Configuration

The master node will use PXELINUX from `syslinux` to provide a kernel and
initramfs to diskless clients. Make sure that the Void `syslinux` package is
installed:

    xbps-install -S syslinux

Create and populate a root for the TFTP server, as configured in the
`dnsmasq.conf` overlay on the master node:

    mkdir -p /srv/tftp/pxelinux.cfg
    cp pxelinux.cfg /srv/tftp/pxelinux.cfg/default

    cp /usr/lib/syslinux/ldlinux.c32 /srv/tftp
    cp /usr/lib/syslinux/lpxelinux.0 /srv/tftp

    cp /usr/lib/syslinux/efi64/ldlinux.e64 /srv/tftp
    cp /usr/lib/syslinux/efi64/syslinux.efi /srv/tftp

> NOTE: although these instructions describe copying EFI loaders into
> `/srv/tftp`, the PXELINUX loader has only been tested with legacy BIOS
> booting. Booting `x86_64` UEFI via PXELINUX may require additional steps or
> alternative configurations that are not described here.

## Customization

The file `pxelinux.cfg`, installed as `/srv/tftp/pxelinux.cfg/default`,
specifies an `nfsroot` host of `172.23.199.225`. Change this IP address to that
of your master node.
