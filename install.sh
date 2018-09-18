#/bin/bash
#############################################
# mysqlmymonlite.sh installer
# written by George Liu (eva2000) centminmod.com
#############################################
INSTALLDIR='/root/tools'
FILENAME='mysqlmymonlite.zip'
DOWNLOAD="http://mysqlmymon.com/download/${FILENAME}"

#############################################
if [ -f /etc/debian_version ]; then
	DEBIAN='y'
else
	DEBIAN='n'
fi

if [ -f /etc/redhat-release ]; then
	CENTOS='y'
else
	CENTOS='n'
fi

if [ -f /usr/local/cpanel/version ]; then
	CPANEL='y'
else
	CPANEL='n'
fi

if [[ ! -f /usr/bin/wget ]]; then
	if [[ "$CENTOS" = 'y' ]]; then
		yum -q -y install wget
	elif [[ "$DEBIAN" = 'y' ]]; then
		apt-get --yes --quiet install wget
	fi
fi

if [[ ! -f /usr/bin/unzip ]]; then
	if [[ "$CENTOS" = 'y' ]]; then
		yum -q -y install unzip
	elif [[ "$DEBIAN" = 'y' ]]; then
		apt-get --yes --quiet unzip
	fi
fi
#############################################
# functions

######################
installscript() {
if [ ! -d "${INSTALLDIR}" ]; then
mkdir -p ${INSTALLDIR}
fi

cd ${INSTALLDIR}

        echo "Download ${FILENAME} ..."
if [ -s ${FILENAME} ]; then
  echo "${FILENAME} found, skipping download..."
  else
  echo "Error: ${FILENAME} not found !!! Download now......"
        wget -cnv $DOWNLOAD --tries=3 
ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
	echo "Error: ${FILENAME} download failed."
	exit $ERROR
else 
         echo "Download done."
#echo ""
	fi
fi

unzip -o ${FILENAME} 

ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
	echo "Error: ${FILENAME} extraction failed."
	exit $ERROR
else 
         echo "${FILENAME} valid file."
echo ""
	fi

if [[ "$CENTOS" = 'y' && "$CPANEL" = 'n' && "$DEBIAN" = 'n' ]]; then
	mv -f centos/mysqlmymonlite.sh .
fi

if [[ "$CENTOS" = 'y' && "$CPANEL" = 'y' && "$DEBIAN" = 'n' ]]; then
	mv -f centos_whm/mysqlmymonlite.sh .
fi

if [[ "$CENTOS" = 'n' && "$CPANEL" = 'n' && "$DEBIAN" = 'y' ]]; then
	mv -f debian/mysqlmymonlite.sh .
fi

# cleanup
echo ""
echo "Clean up other files, but leave readme.txt"
echo ""
rm -rf mysqlmymonlite.zip centos centos_whm debian changelog*
chmod 0700 mysqlmymonlite.sh
}

######################
removescript() {
# remove old files
echo ""
echo "Removing mysqlmymonlite.sh"
echo ""
cd ${INSTALLDIR}
rm -rf mysqlmymonlite.sh readme.txt 
rm -rf /root/mysqlreport 
rm -rf /root/mysqltuner
}

######################
updatescript() {

# remove old files
echo ""
echo "Updating mysqlmymonlite.sh to latest version"
echo ""
cd ${INSTALLDIR}
rm -rf mysqlmymonlite.sh readme.txt 
rm -rf /root/mysqlreport 
rm -rf /root/mysqltuner
installscript
}

######################
usemsg() {
echo "-----------------------------------------------"
echo "If you have MySQL root user's password set, you"
echo "need to edit ${INSTALLDIR}/mysqlmymonlite.sh and"

echo "set MySQL root user's password variable."
echo ""
echo "You can find the how to use mysqlmymonlite.sh"
echo "Youtube video on http://mysqlmymon.com/ at"
echo "http://mysqlmymon.com/#video best viewed in"
echo "Full Screen HD mode"
echo "-----------------------------------------------"
echo "To view all options type: "
echo "${INSTALLDIR}/mysqlmymonlite.sh"
echo ""
echo "To run main option type: "
echo "${INSTALLDIR}/mysqlmymonlite.sh run"
echo "-----------------------------------------------"
}

######################

#############################################
case "$1" in
install)
	installscript
	usemsg
;;
update)
	updatescript
;;
remove)
	removescript
;;
*)
	echo "$0 install"
	echo "$0 update"
	echo "$0 remove"
;;
esac
exit