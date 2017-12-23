# freenas-iocage-crashplan

Currently installs CrashPlan PRO 4.9.0 build 33 and TigerVNC with noVNC HTML5 viewer!

For this to work, you need to run `sysrc linux_enable="YES"` on your FreeNAS system, and reboot for the OS to load the linux compatibility kernel modules.  This is also done within the Jail, but it won't work unless you do it on the main OS too.

The jail mounts `crashplan/bin`, `crashplan/conf`, `crashplan/id`, `crashplan/cache` and `crashplan/log` outside of the jail for persistent storage of the Crashplan files.
The jail also mounts `portsnap/ports` and `portsnap/db` outside of the jail for persistent storage of the Ports files; useful when you're building things over multiple jails.

The default VNC password is 'crashplan' - change it before installation at the very bottom of /CrashPlanPro_FreeBSD_vnc_install.csh/ or after using `iocage exec crashplan /opt/vncpasswd/vncpasswd.py -f "/root/.vnc_passwd" -e "NewPa55worD"`. There is not yet an easy restart handler for VNC.

Steps for use:
1. Decide where the persistant storage paths will go and update the paths within `crashplan_jail.sh` 
1. Place all of the files with in the `bin` directory of this repo within the `crashplan/bin` directory before you run the main jail script.
1. Run `crashplan_jail.sh`
1. VNC will be available at http://[CRASHPLAN_IP]:4280/vnc.html?host=[CRASHPLAN_IP]&port=4280
