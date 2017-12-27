#!/bin/sh

iocage stop crashplan
iocage destroy -f crashplan
echo '{"pkgs":["bash","linux_base-c7","linux-c7-xorg-libs","linux-c7-gtk2","linux-c7-nss","tigervnc","xauth","openbox","xorg-fonts-75dpi","xorg-fonts-100dpi","xsetroot","novnc","websockify","python","py27-numpy"]}' > /tmp/pkg.json
iocage create --name "crashplan" -p /tmp/pkg.json -r 11.1-RELEASE ip4_addr="vnet0|[CRASHPLAN_IP]/24" vnet="on" allow_raw_sockets="1" defaultrouter="[DEFAULT_GW_IP]" boot="on" host_hostname="crashplan" mount_linprocfs="1" allow_mount_tmpfs="1"
rm /tmp/pkg.json
mkdir -p /mnt/[non_iocage_dset]/crashplan/cache
mkdir -p /mnt/[non_iocage_dset]/crashplan/id
mkdir -p /mnt/[non_iocage_dset]/crashplan/log
mkdir -p /mnt/[non_iocage_dset]/crashplan/conf
mkdir -p /mnt/[non_iocage_dset]/crashplan/bin
iocage fstab -a crashplan /mnt/[non_iocage_dset]/crashplan/cache /usr/local/share/crashplan/cache nullfs rw 0 0
iocage fstab -a crashplan /mnt/[non_iocage_dset]/crashplan/id /var/lib/crashplan nullfs rw 0 0
iocage fstab -a crashplan /mnt/[non_iocage_dset]/crashplan/log /usr/local/share/crashplan/log nullfs rw 0 0
iocage fstab -a crashplan /mnt/[non_iocage_dset]/crashplan/conf /usr/local/share/crashplan/conf nullfs rw 0 0
iocage fstab -a crashplan /mnt/[non_iocage_dset]/crashplan/bin /usr/local/share/crashplan/bin nullfs rw 0 0
mkdir -p /mnt/[non_iocage_dset]/portsnap/ports
mkdir -p /mnt/[non_iocage_dset]/portsnap/db
iocage fstab -a crashplan /mnt/[non_iocage_dset]/portsnap/ports /usr/ports nullfs rw 0 0
iocage fstab -a crashplan /mnt/[non_iocage_dset]/portsnap/db /var/db/portsnap nullfs rw 0 0
iocage fstab -a crashplan tmpfs /lib/init/rw tmpfs rw,mode=777 0 0
iocage fstab -a crashplan linproc /proc linprocfs rw 0 0
iocage fstab -a crashplan /mnt/dset/to/expose /path/to/backup nullfs rw 0 0
iocage fstab -a crashplan /mnt/dset/to/expose /path/to/backup nullfs rw 0 0
iocage fstab -a crashplan /mnt/dset/to/expose /path/to/backup nullfs rw 0 0
iocage exec crashplan ln -s /usr/local/bin/bash /bin/bash
iocage exec crashplan sysrc -f /etc/rc.conf linux_enable="YES"
iocage restart crashplan
iocage exec crashplan csh /usr/local/share/crashplan/bin/CrashPlanPro_FreeBSD_install.csh
iocage exec crashplan csh /usr/local/share/crashplan/bin/CrashPlanPro_FreeBSD_vnc_install.csh
iocage exec crashplan sysrc -f /etc/rc.conf crashplan_enable="YES"
iocage exec crashplan sysrc -f /etc/rc.conf vnc_enable="YES"
iocage restart crashplan
