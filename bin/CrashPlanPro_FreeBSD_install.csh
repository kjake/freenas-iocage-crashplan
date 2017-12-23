#!/bin/csh

set CRASHPLAN_LOC=/usr/local/share/crashplan
set CRASHPLANPRO_VERSION=4.9.0
set CRASHPLANPRO_VERSION_SUFFIX=1436674888490_33
set CRASHPLANPRO_PKG=CrashPlanPRO_${CRASHPLANPRO_VERSION}_${CRASHPLANPRO_VERSION_SUFFIX}_Linux.tgz
mkdir -p $CRASHPLAN_LOC
fetch --no-verify-peer https://web-lbm-msp.crashplanpro.com/client/installers/$CRASHPLANPRO_PKG -o $CRASHPLAN_LOC/$CRASHPLANPRO_PKG
tar -C $CRASHPLAN_LOC/ -xf $CRASHPLAN_LOC/$CRASHPLANPRO_PKG
set JAVA_PKG=`cat $CRASHPLAN_LOC/crashplan-install/install.defaults | grep I586 | cut -d'=' -f2 | cut -d/ -f7`
fetch --no-verify-peer `cat $CRASHPLAN_LOC/crashplan-install/install.defaults | grep I586 | cut -d'=' -f2` -o $CRASHPLAN_LOC/$JAVA_PKG
mkdir -p $CRASHPLAN_LOC/linux-sun-jre1.8.0
tar -C $CRASHPLAN_LOC/linux-sun-jre1.8.0 -xf $CRASHPLAN_LOC/$JAVA_PKG
cd $CRASHPLAN_LOC && /bin/cat $CRASHPLAN_LOC/crashplan-install/CrashPlanPRO_${CRASHPLANPRO_VERSION}.cpi | /usr/bin/gzip -nf -9 -d -c - | /usr/bin/cpio -i --no-preserve-owner
install -l rs $CRASHPLAN_LOC/conf $CRASHPLAN_LOC/lang
install -m 555 $CRASHPLAN_LOC/crashplan-install/scripts/CrashPlanDesktop $CRASHPLAN_LOC/bin/
install -m 555 $CRASHPLAN_LOC/crashplan-install/scripts/CrashPlanEngine $CRASHPLAN_LOC/bin/
cp -f $CRASHPLAN_LOC/crashplan-install/scripts/run.conf $CRASHPLAN_LOC/bin/
echo > $CRASHPLAN_LOC/install.vars
echo "TARGETDIR=${CRASHPLAN_LOC}" >> $CRASHPLAN_LOC/install.vars
echo "BINSDIR=${CRASHPLAN_LOC}/bin" >> $CRASHPLAN_LOC/install.vars
echo "JAVACOMMON=${CRASHPLAN_LOC}/linux-sun-jre1.8.0/jre/bin/java" >> $CRASHPLAN_LOC/install.vars
echo "LOGDIR=/var/log/crashplan" >> $CRASHPLAN_LOC/install.vars
/bin/cat $CRASHPLAN_LOC/crashplan-install/install.defaults >> $CRASHPLAN_LOC/install.vars
sed -i .backup 's/<orgType>CONSUMER<\/orgType>/<orgType>BUSINESS<\/orgType>/g; s/central.crashplan.com/central.crashplanpro.com/g' $CRASHPLAN_LOC/conf/default.service.xml $CRASHPLAN_LOC/conf/my.service.xml
mkdir -p /usr/local/etc/rc.d
cp $CRASHPLAN_LOC/bin/crashplan /usr/local/etc/rc.d/crashplan
chmod +x /usr/local/etc/rc.d/crashplan
patch -st $CRASHPLAN_LOC/bin/CrashPlanEngine < $CRASHPLAN_LOC/bin/patch-scripts_CrashPlanEngine
rm -r $CRASHPLAN_LOC/crashplan-install
rm $CRASHPLAN_LOC/$CRASHPLANPRO_PKG
rm $CRASHPLAN_LOC/$JAVA_PKG
