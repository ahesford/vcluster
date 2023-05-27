# A Simple Method for Void Linux Clustering

There are several methods for constructing and managing small-scale,
heterogenous ("Beowulf") computing clusters. [Warewulf](https://warewulf.org/)
is an end-to-end suite that facilitates the management of node images,
provisioning of nodes (including custom, per-node configuration overlays), and
control of TFTP, DHCP and NFS servers. Originally a suite of Perl scripts that
provided a front end to a database, Warefulf is now written in Go and uses a
simpler flat-file backing store. The server-control components rely exclusively
on the `systemctl` command in systemd, but could be trivially patched to
support runit as well.

After considering bringing Warewulf to Void, I concluded that most of its major
utility can be realized with a much simpler approach. One of my requirements
for a small cluster is that the master node run essentially the same image as
the others, and this wouldn't be possible with Warewulf without some special
accommodations. To satisfy this requirement, all nodes can mount a root
filesystem image as the lower tree of an
[overlay filesystem](https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html)
that uses memory-backed
[tmpfs](https://www.kernel.org/doc/html/latest/filesystems/tmpfs.html)
as its upper tree. The master node can mount the lower tree from a locally
attached ZFS pool; all other nodes can mount the lower tree from an NFS export
on the master. For home directories, the master will again mount and export
local storage for the other nodes to access. The master then runs a PXE server
that will provide kernels and an appropriate initramfs image to all others.

The most heavily customized node will be the master, because it should run
services and use local filesystems that will not be used on other nodes. For
other nodes, customization is generally limited to assigning unique hostnames
to each, although more extensive per-node customization is possible. A simple
override system allows the replacement common files with customized variants
early in the boot process. The replacement system provides all of the
flexibility necessary to assign unique roles to individual nodes as needed.

## Contents

The subdirectories of this repository provide sample configurations and scripts
that should be deployed on the master node. Each directory contains a dedicated
README that describes how to install and use the components therein. The
subsystems that must be modified for clustering are:

- `initcpio`: I prefer the use of `mkinitcpio` to `dracut` both because
  `mkinitcpio` is generally simpler to configure and because `dracut` is
  increasingly hostile to systems that do not use systemd or attempt to include
  it in initramfs images. This subdirectory contains the pieces necessary to
  configure `mkinitcpio` to produce initramfs images for both the master node
  and the client nodes.

- `overlays` provides the components necessary to implement early-boot
  configuration overlays on a per-node basis. 

- `tftp` provides instruction and a simple PXELINUX configuration that can be
  used to serve the client kernel and initramfs to diskless nodes.
