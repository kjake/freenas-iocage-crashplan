# Crashplan Pro Jail for FreeNAS

### I won't be updating this for CrashPlan 6+ because the system now heavily relies on Gnome/Linux components/libraries.  I have cancelled my plan with CrashPlan and shutdown my Jail even though 4.9 will continue to work; I don't want to support terrible software any longer.

Currently installs CrashPlan PRO 4.9.0 build 33 and TigerVNC with noVNC HTML5 viewer!

For this to work, you need to enable Linux Binary Compatibility on your FreeNAS system, and reboot for the OS to load the linux compatibility kernel modules. This is also done within the Jail, but it won't work unless you do it on the main OS too. 

The default VNC password is 'crashplan'.

This Jail makes use of VNET emulated/virtual network interfaces rather than sharing your main interface; this is needed for proper port forwarding situations, but may not be required as this Jail is tested more.

### Persistent Storage
The jail mounts _crashplan/bin_, _crashplan/conf_, _crashplan/id_, _crashplan/cache_ and _crashplan/log_ outside of the jail for persistent storage of the Crashplan files.
The jail also mounts _portsnap/ports_ and _portsnap/db_ outside of the jail for persistent storage of the Ports files; useful when you're building things over multiple jails.

_These persistent jail mounts are technically optional as the installation or OS will create them as needed, but they will become part of the jail and lost if the jail is destroyed, resulting in a complete re-configure of CrashPlan on the next build of the jail. If you chose to not use persistent jail mounts, remove them from the crashplan_jail.sh before running and only mount your path(s) that you want to backup._

### Tip
If the Desktop application complains about not being able to connect to the back end service, this is likely a DNS resolution issue - the Desktop app tries to connect to the hostname of the jail instead of the IP address. Register a DNS record at your router and things should work - an _/etc/hosts_ entry should too.

### Steps For Use
1. FreeNAS Changes, System->Tunables -> Add Tunable:
   1. Variable "linux_enable", Value "YES", type "rc.conf".<sup>[1](#linux_enable)</sup>
   1. Variable "ifconfig_bridge0", Value "addm [NET_INTERFACE_NAME] up", type "rc.conf".<sup>[2](#vnet)</sup>
   1. Variable "net.inet.ip.forwarding", Value "1", type "Sysctl".<sup>[2](#vnet)</sup>
   1. Variable "net.link.bridge.pfil_onlyip", Value "0", type "Sysctl".<sup>[2](#vnet)</sup>
   1. Variable "net.link.bridge.pfil_bridge", Value "0", type "Sysctl".<sup>[2](#vnet)</sup>
   1. Variable "net.link.bridge.pfil_member", Value "0", type "Sysctl".<sup>[2](#vnet)</sup>
1. Reboot FreeNAS for these changes to take.
1. Optional: Change the VNC password value located at the very bottom of _CrashPlanPro_FreeBSD_vnc_install.csh_.
1. Decide where the persistant storage paths will go and update the paths within _crashplan_jail.sh_ 
1. Update the IPs within _crashplan_jail.sh_ (CRASHPLAN_IP and DEFAULT_GW_IP)
1. Place all of the files with in the _bin_ directory of this repo within the _crashplan/bin_ directory before you run the main jail script.
1. Put _crashplan_jail.sh_ somewhere accessible on your FreeNAS system and run it.
1. VNC will be available at http://[CRASHPLAN_IP]:4280/vnc_auto.html

### Common Tasks
- Disable VNC auto-start:
  - Run `iocage exec crashplan sysrc -f /etc/rc.conf vnc_enable="NO"`
- Manually start VNC: 
  - Run `iocage exec crashplan service vnc start`
- Restart VNC:
  - Run `iocage exec crashplan service vnc restart`
- Restart CrashPlan back-end:
  - Run `iocage exec crashplan service crashplan restart`
- Restart entire jail:
  - Run `iocage restart crashplan`
- Change VNC password:
  - Run `iocage exec crashplan /opt/vncpasswd/vncpasswd.py -f "/root/.vnc_passwd" -e "NewPa55worD"`
- Stuck Backup / High CPU:
  - Maybe lack of memory. Edit _bin/run.conf_ and modify the SRV_JAVA_OPTS to have a higher Xmx value, like 2048m instead of 1024m.
  
##### Footnotes
###### <a name="linux_enable">1</a>: https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/linuxemu-lbc-install.html
###### <a name="vnet">2</a>: https://iocage.readthedocs.io/en/latest/networking.html#vimage-vnet

