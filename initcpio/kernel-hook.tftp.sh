#!/bin/sh
#
# Kernel post-install hook for mkinitcpio.
#
# Arguments passed to this script: $1 pkgname, $2 version.
#
PKGNAME="$1"
VERSION="$2"

[ -x usr/bin/mkinitcpio ] || exit 0
[ -e etc/mkinitcpio.net.conf ] || exit 0

[ -d srv/tftp ] || exit 0

[ -e boot/vmlinuz-${VERSION} ] || exit 0

cp boot/vmlinuz-${VERSION} srv/tftp/vmlinuz-cluster
chmod 0644 srv/tftp/vmlinuz-cluster

usr/bin/mkinitcpio -c etc/mkinitcpio.net.conf -g srv/tftp/initramfs-cluster.img -k ${VERSION}
chmod 0644 srv/tftp/initramfs-cluster.img
