#!/bin/sh
JAIL_IP=192.168.123.123
TANK_PATH=/mnt/nas
JAIL_PATH=${TANK_PATH}/jails
JAIL_NAME=crashplan
DEFAULT_GW_IP=192.168.123.1

iocage stop ${JAIL_NAME}
iocage destroy -f ${JAIL_NAME}
echo '{"pkgs":["bash","linux_base-c7","linux-c7-alsa-lib","linux-c7-openssl-libs","linux-c7-dbus-libs","linux-c7-dbus-glib","linux-c7-cups-libs","linux-c7-xorg-libs","linux-c7-gtk2","linux-c7-nss","tigervnc","xauth","openbox","xorg-fonts-75dpi","xorg-fonts-100dpi","xsetroot","novnc","websockify","python","py27-numpy"]}' > /tmp/pkg.json
iocage create --name "crashplan" -p /tmp/pkg.json -r 11.1-RELEASE ip4_addr="vnet0|${JAIL_IP}/24" vnet="on" allow_raw_sockets="1" defaultrouter="${DEFAULT_GW_IP}" boot="on" host_hostname="${JAIL_NAME}" mount_linprocfs="1" allow_mount_tmpfs="1"
rm /tmp/pkg.json
mkdir -p ${JAIL_PATH}/${JAIL_NAME}/cache
mkdir -p ${JAIL_PATH}/${JAIL_NAME}/id
mkdir -p ${JAIL_PATH}/${JAIL_NAME}/log
mkdir -p ${JAIL_PATH}/${JAIL_NAME}/conf
mkdir -p ${JAIL_PATH}/${JAIL_NAME}/bin
mkdir -p ${JAIL_PATH}/portsnap/ports
mkdir -p ${JAIL_PATH}/portsnap/db

#NAS Paths to export for CrashPlan to see for backup
iocage fstab -a ${JAIL_NAME} ${TANK_PATH}/shared/Music /export/Music nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${TANK_PATH}/shared/Documents /export/Documents nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${TANK_PATH}/shared/Pictures /export/Pictures nullfs rw 0 0

#CrashPlan Paths
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/${JAIL_NAME}/cache /usr/local/share/${JAIL_NAME}/cache nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/${JAIL_NAME}/id /var/lib/crashplan nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/${JAIL_NAME}/log /usr/local/share/${JAIL_NAME}/log nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/${JAIL_NAME}/conf /usr/local/share/${JAIL_NAME}/conf nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/${JAIL_NAME}/bin /usr/local/share/${JAIL_NAME}/bin nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/portsnap/ports /usr/ports nullfs rw 0 0
iocage fstab -a ${JAIL_NAME} ${JAIL_PATH}/portsnap/db /var/db/portsnap nullfs rw 0 0

#BSD Ports
iocage fstab -a ${JAIL_NAME} tmpfs /lib/init/rw tmpfs rw,mode=777 0 0
iocage fstab -a ${JAIL_NAME} linproc /proc linprocfs rw 0 0

iocage exec ${JAIL_NAME} ln -s /usr/local/bin/bash /bin/bash
iocage exec ${JAIL_NAME} sysrc -f /etc/rc.conf linux_enable="YES"
iocage restart ${JAIL_NAME}
iocage exec ${JAIL_NAME} csh /usr/local/share/${JAIL_NAME}/bin/CrashPlanPro_FreeBSD_install.csh
iocage exec ${JAIL_NAME} csh /usr/local/share/${JAIL_NAME}/bin/CrashPlanPro_FreeBSD_vnc_install.csh
iocage exec ${JAIL_NAME} sysrc -f /etc/rc.conf ${JAIL_NAME}_enable="YES"
iocage exec ${JAIL_NAME} sysrc -f /etc/rc.conf vnc_enable="YES"
iocage restart ${JAIL_NAME}
