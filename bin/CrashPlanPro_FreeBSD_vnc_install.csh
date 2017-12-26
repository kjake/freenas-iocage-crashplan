#/bin/csh

make -C /usr/ports/devel/py-xdg install BATCH=yes
mkdir -p /root/.config/openbox
fetch --no-verify-peer https://raw.githubusercontent.com/gfjardim/docker-containers/master/crashplan/files/root/.config/openbox/rc.xml -o /root/.config/openbox/rc.xml

echo '#\!/bin/bash \
/usr/local/bin/xsetroot -solid black -cursor_name left_ptr \
if [ -e /opt/startapp.sh ]; then \
  /opt/startapp.sh & \
fi' > /root/.config/openbox/autostart.sh

mkdir /opt

echo '# Load default values if empty \
VNC_PORT=${TCP_PORT_4239:-4239} \
WEB_PORT=${TCP_PORT_4280:-4280} \
BACKUP_PORT=${TCP_PORT_4242:-4242} \
SERVICE_PORT=${TCP_PORT_4243:-4243} \
VNC_CREDENTIALS=/root/.vnc_passwd \
APP_NAME="CrashPlan ${CP_VERSION}" \
if [[ -n $VNC_CREDENTIALS ]]; then \
  VNC_SECURITY="SecurityTypes TLSVnc,VncAuth -PasswordFile ${VNC_CREDENTIALS}" \
else \
  VNC_SECURITY="SecurityTypes None" \
fi' > /opt/default-values.sh

echo '#\!/bin/bash \
umask 0000 \
TARGETDIR=/usr/local/share/crashplan \
export SWT_GTK3=0 \
. ${TARGETDIR}/install.vars \
. ${TARGETDIR}/bin/run.conf \
cd ${TARGETDIR} \
i=0 \
until [ "$(service crashplan status)" == "running" ]; do \
  sleep 1 \
  let i+=1 \
  if [ $i -gt 10 ]; then \
    break \
  fi \
done \
${JAVACOMMON} ${GUI_JAVA_OPTS} -classpath "./lib/com.backup42.desktop.jar:./lang:./skin" com.backup42.desktop.CPDesktop \
              > ${TARGETDIR}/log/desktop_output.log 2> ${TARGETDIR}/log/desktop_error.log &' > /opt/startapp.sh

echo '#\!/bin/bash \
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin \
export HOME=/root \
export DISPLAY=:1 \
rm -f /tmp/.X1-lock \
. /opt/default-values.sh \
/usr/local/bin/Xvnc :1 \\
           -depth 24 \\
           -rfbwait 30000 \\
           -${VNC_SECURITY} \\
           -rfbport ${VNC_PORT} \\
           -bs \\
           -ac \\
           -pn \\
           -fp /usr/local/share/fonts/misc/,/usr/local/share/fonts/75dpi/,/usr/local/share/fonts/100dpi/ \\
           -dpi 100 \\
           -desktop ${APP_NAME} & \
sleep 5 \
/usr/local/bin/openbox-session & \
/usr/local/libexec/novnc/utils/launch.sh --listen $WEB_PORT --vnc localhost:$VNC_PORT &' > /opt/vnc-session.sh

mkdir -p /usr/local/etc/rc.d/
echo '#\!/bin/sh \
# PROVIDE: vnc \
# REQUIRE: DAEMON \
. /etc/rc.subr \
name="vnc" \
rcvar=${name}_enable \
command="/opt/vnc-session.sh" \
stop_cmd="vnc_stop" \
vnc_stop() \
{ \
    pkill Xvnc \
    pkill openbox \
    pkill -f websockify \
} \
load_rc_config ${name} \
run_rc_command "$1"' > /usr/local/etc/rc.d/vnc

mkdir -p /opt/vncpasswd
fetch --no-verify-peer https://github.com/trinitronx/vncpasswd.py/archive/master.tar.gz -o - | tar -zx --strip=1 -C /opt/vncpasswd -f -

chmod +x /usr/local/etc/rc.d/*
chmod +x /opt/*.sh
chmod +x /usr/local/libexec/novnc/utils/launch.sh
chmod +x /root/.config/openbox/autostart.sh

/opt/vncpasswd/vncpasswd.py -f "/root/.vnc_passwd" -e "crashplan"
