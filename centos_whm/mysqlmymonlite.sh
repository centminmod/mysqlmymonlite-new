#!/bin/bash
#######################################################
# Copyright (C) 2011-2018
# Program: mysqlmymonlite.sh
# Lite version of extensive featured mysqlmymon.sh
# MySQL and system monitoring script 
# by George Liu (eva2000) centminmod.com
# Updated: October 25, 2018 AEST
MYSQLMYMONVER='0.5.7 WHM'
MYSQLMYMONURL='mysqlmymon.com'
#######################################################
# Usage is free just keep the credits intact
#######################################################
# NO SUPPORT PROVIDED, script is provided as is
# To understand mysqlreport, mysqltuner.pl,
# read their respective documentation
#######################################################
# Command options below:
#######################################################
# ./mysqlmymonlite.sh --help
# ./mysqlmymonlite.sh check
# ./mysqlmymonlite.sh run
# ./mysqlmymonlite.sh mysql
# ./mysqlmymonlite.sh vmstat
# ./mysqlmymonlite.sh showcreate
# ./mysqlmymonlite.sh showindex
# ./mysqlmymonlite.sh vbshowtables
# ./mysqlmymonlite.sh dblist
# ./mysqlmymonlite.sh mysqlreport
# ./mysqlmymonlite.sh mysqlfullreport
# ./mysqlmymonlite.sh mysqltuner
# ./mysqlmymonlite.sh psmem
#######################################################
# Create mysqlusername/password with following privileges
# GRANT ALL PRIVILEGES ON *.* TO 'userinfo'@'localhost' IDENTIFIED BY 'enteryourpassword';
#######################################################
# Edit variables below
#######################################################

DT=`date +"%d%m%y-%H%M%S"`

MYCNF='/etc/my.cnf'
USER='root'
PASS=''

# path to .my.cnf which may contain your mysql root username &
# password details. When MYSQLEXTRA='y' enabled, it will instead of
# passing the password on the command line will use --defaults-extra-file
# method and read the mysql root user and password from the MYSQLEXTRA_FILE
# which defaults to /root/.my.cnf which is default location for cpanel based
# servers and usually has the file prepopulated with mysql root user/pass
# 
# This prevents the following warning message from appearing when using 
# MySQL 5.6 server:
# 
##  Warning: Using a password on the command line interface can be insecure.
# 
# Used for the variable further below
# MYSQLDEFAULTS_EXTRAFILE="--defaults-extra-file=${MYSQLEXTRA_FILE}"
# 
# Using this option requires running script as root user as mysqltuner.pl
# looks into the user's relative home directory for ~/.my.cnf which for root
# is /root. If you run as a non-root named user i.e. /home/username, then
# mysqltuner.pl looks for /home/username/.my.cnf so need to change the
# MYSQLEXTRA_FILE=/home/username/.my.cnf and set root user/password appropriately
MYSQLEXTRA='y'
MYSQLEXTRA_FILE='/root/.my.cnf'

# change from localhost if your have a remote 
# mysql server with dedicated ip address
# if you set MYSQLHOST to remote server ip please set
# FORCEMEM and FORCESWAP values below in megabytes
# which relate to how much memory and swap space your
# remote MySQL server has i.e. 512MB & 512MB
MYSQLHOST='localhost'
FORCEMEM='512'
FORCESWAP='512'
# change from n to y if this server is dedicated
# mysql server with no apache, nginx, php installed
MYSQLSERVERONLY='n'
# change from n to y if this server is dedicated web only server
# with no mysql, php etc
WEBONLY='n'

# MySQL database per table details output setting to 'y' will show per database 
# table's name, storage engine type, number of table rows, index and data and 
# total size per table
# if you have alot of databases/tables ALOT of text will be outputted
SHOWPERTABLE='n'

# If set to yes = 'y', per database table list has
# database name partially masked to protect privacy
MASKDB='y'

# If you use nginx web server and have an non-standard path to where your
# nginx.conf is located, you can define it in this variable to override the scripts
# detection for nginx.conf path i.e. /etc/nginx/nginx.conf or /usr/local/nginx/nginx.conf
NGINXCONFPATHOVERRIDE=''
#######################################################
# Excludb databases list from per Table listing
# You can hide all other database names from having
# their database table names listed leaving just
# your vBulletin databasenames to display the per
# Table listing which is needed for optimisation
# tuning to see which tables are innodb or myisam
# to see their index and data sizes per table
#######################################################
# to get a full list of database names type:
# ./mysqlmymonlite.sh dblist
# single spacing between each databasename
#######################################################
EXCLUDEDB="test information_schema mysql cphulkd eximstats horde leechprotect roundcube"

if [ -f ./config.ini ]; then
source "./config.ini"
fi
#######################################################
# DO NOT EDIT BELOW THIS SECTION
#######################################################
makechk() {
if [[ ! -f /usr/bin/make ]]; then
	yum -q -y install make
fi
}

if [ -f /scripts/perlmods ]; then
  if [[ -z "$(/scripts/perlmods -l | grep 'Devel::CheckLib')" ]]; then
    makechk
    echo "----------------------------------------------------------"
    echo "Detected missing perl Devel::CheckLib module"
    echo "Installing missing perl module..."
    echo "----------------------------------------------------------"
    echo "perl -MCPAN -e 'install Devel::CheckLib'"
    perl -MCPAN -e 'install Devel::CheckLib'
  fi
  if [[ -z "$(/scripts/perlmods -l | grep 'DBD::mysql')" ]]; then
    makechk
    echo "----------------------------------------------------------"
    echo "Detected missing perl DBD::mysql module"
    echo "Installing missing perl module..."
    echo "----------------------------------------------------------"
    echo "perl -MCPAN -e 'install DBD::mysql'"
    perl -MCPAN -e 'install DBD::mysql'
    #/scripts/perlinstaller --force DBD::mysql
    echo "----------------------------------------------------------"
    echo "Installation complete. Exiting script..."
    echo "Please re-run $0 again"
    exit
    echo "----------------------------------------------------------"
  fi
fi

if [ -f /usr/local/cpanel/scripts/perlmods ]; then
  if [[ -z "$(/usr/local/cpanel/scripts/perlmods -l | grep 'Devel::CheckLib')" ]]; then
    makechk
    echo "----------------------------------------------------------"
    echo "Detected missing perl Devel::CheckLib module"
    echo "Installing missing perl module..."
    echo "----------------------------------------------------------"
    echo "perl -MCPAN -e 'install Devel::CheckLib'"
    perl -MCPAN -e 'install Devel::CheckLib'
  fi
  if [[ -z "$(/usr/local/cpanel/scripts/perlmods -l | grep 'DBD::mysql')" ]]; then
    makechk
    echo "----------------------------------------------------------"
    echo "Detected missing perl DBD::mysql module"
    echo "Installing missing perl module..."
    echo "----------------------------------------------------------"
    echo "perl -MCPAN -e 'install DBD::mysql'"
    perl -MCPAN -e 'install DBD::mysql'
    #/usr/local/cpanel/scripts/perlinstaller --force DBD::mysql
    echo "----------------------------------------------------------"
    echo "Installation complete. Exiting script..."
    echo "Please re-run $0 again"
    exit
    echo "----------------------------------------------------------"
  fi
fi
if [[ "$WEBONLY" = [nN] ]]; then
	MYSQLADMIN="$(which mysqladmin)"
	MYSQLCLI="$(which mysql)"
fi

GREP="grep"
EGREP="egrep"
AWK="$(which awk)"
TR="$(which tr)"
CPANELVER=`cat /usr/local/cpanel/version`

SRCDIR='/root'
MYSQLREPORTPATH="${SRCDIR}/mysqlreport"
MYSQLREPORTFILE="${SRCDIR}/mysqlinfo.txt"

if [[ "$MYSQLEXTRA_FILE" = 'echo ~/.my.cnf' ]]; then
	MYSQLDEFAULTS_EXTRAFILE="--defaults-extra-file=${MYSQLEXTRA_FILE}"
else
	if [ -f "$(echo ~/.my.cnf)" ]; then
		MYSQLEXTRA_FILE=$(echo ~/.my.cnf)
		MYSQLDEFAULTS_EXTRAFILE="--defaults-extra-file=${MYSQLEXTRA_FILE}"
	else
		echo
		echo " $(echo ~/.my.cnf) does not exist"
		echo " if running $0 as non-root named user,"
		echo " you need to setup "$(echo ~/.my.cnf)""
		echo " with contents of:"
echo "
[client]
user="root"
password=yourmysql_rootpassword"
		echo
		echo
exit
	fi
fi

if [[ "$WEBONLY" = [nN] ]]; then
	if [[ "$MYSQLEXTRA" = [yY] ]]; then
		MYSQLADMINOPT="$MYSQLDEFAULTS_EXTRAFILE -h $MYSQLHOST"
		MYSQLREPORTOPT="--host $MYSQLHOST"
			if [[ "$MYSQLHOST" == 'localhost' || "$MYSQLHOST" == '127.0.0.1' ]]; then
			MYSQLTUNEROPT=""
			else
			MYSQLTUNEROPT="--host $MYSQLHOST --forcemem $FORCEMEM --forceswap $FORCESWAP"
			fi
	else
		if [ -z $PASS ]; then
		MYSQLADMINOPT="-h $MYSQLHOST"
		MYSQLREPORTOPT="--host $MYSQLHOST"
			if [[ "$MYSQLHOST" == 'localhost' || "$MYSQLHOST" == '127.0.0.1' ]]; then
			MYSQLTUNEROPT=''
			else
			MYSQLTUNEROPT="--host $MYSQLHOST --forcemem $FORCEMEM --forceswap $FORCESWAP"
			fi
		else
		MYSQLADMINOPT="-u$USER -p$PASS -h $MYSQLHOST"
		MYSQLREPORTOPT="--user $USER --pass $PASS --host $MYSQLHOST"
			if [[ "$MYSQLHOST" == 'localhost' || "$MYSQLHOST" == '127.0.0.1' ]]; then
			MYSQLTUNEROPT="--user $USER --pass $PASS"
			else
			MYSQLTUNEROPT="--user $USER --pass $PASS --host $MYSQLHOST --forcemem $FORCEMEM --forceswap $FORCESWAP"
			fi
		fi
	fi # MYSQLEXTRA
fi
#######################################################
## Litespeed & OpenLitespeed check

# MYSQLSERVERONLY
if [ "$MYSQLSERVERONLY" == 'n' ]; then

if [ -f /usr/local/lsws/VERSION ]; then
LSVER=`cat /usr/local/lsws/VERSION`
fi

if [ -f /usr/local/lsws/conf/httpd_config.xml ]; then
LITESPEEDPHPSUEXEC=`awk '/phpSuExec/' /usr/local/lsws/conf/httpd_config.xml`
fi

LITESPEEDCHECK=`ps ax | grep -Ev '(^httpd|apache)' | grep -E '(lshttpd|lscgid)' | grep -Ev grep`
OPENLITESPEEDCHECK=`ps ax | grep -Ev '(^httpd|apache)' | grep -E '(lshttpd|lscgid)' | grep openlitespeed | grep -Ev grep`

if [[ ! -z "$LITESPEEDCHECK" || ! -z "$OPENLITESPEEDCHECK" ]]; then

	if [ -s /usr/local/lsws/fcgi-bin/lsphp5 ]; then
	LSPHPBIN='/usr/local/lsws/fcgi-bin/lsphp5'
	fi

fi # LITESPEEDCHECK

#######################################################
## APACHE

# awk equivalent
# ps ax | awk '/httpd/, /apache/' | awk '!/awk/'
APACHECHECK=`ps ax | $GREP -Ev '(grep|lshttpd|lscgid|domlogs)' | $GREP -E '(httpd|apache)'`

if [ ! -z "$APACHECHECK" ]; then

#APACHECTL="$(which httpd)"
#APACHECTL="$(which apachectl)"
APACHECTL='/usr/local/apache/bin/apachectl'

if [ ! -f /usr/bin/elinks ]; then
yum -y -q install elinks
fi

HTTPDFULLSTATUS=`$APACHECTL fullstatus | $EGREP '(Server Version|Server Built|Current Time|Restart Time|Parent Server Generation|Server Uptime|Total accesses|CPU Usage|requests/sec -|requests currently being processed)'`

HTTPD_ROOT=`$APACHECTL -V | awk '/HTTPD_ROOT/' | $TR '"' ' ' | sed -e 's/ -D HTTPD_ROOT=//' | $TR -d ' '`
SERVER_CONFIG_FILE=`$APACHECTL -V | awk '/SERVER_CONFIG_FILE/' | $TR '"' ' ' | sed -e 's/ -D SERVER_CONFIG_FILE=//' | $TR -d ' '`
HTTPDCONF="${HTTPD_ROOT}/${SERVER_CONFIG_FILE}"
HTTPD_ERRORLOG=`$APACHECTL -V | awk '/DEFAULT_ERRORLOG/' | $TR '"' ' ' | sed -e 's/ -D DEFAULT_ERRORLOG=//' | $TR -d ' '`
HTTPD_ERRORLOGPATH="${HTTPD_ROOT}/${HTTPD_ERRORLOG}"

HTTPDMPMCHECK=`awk '/httpd-mpm.conf/' $HTTPDCONF | awk '{ print $1 }'`
	if [ ! -z "$HTTPDMPMCHECK" ]; then
	HTTPDMPMCONF="${HTTPD_ROOT}/`awk '/httpd-mpm.conf/ { print $2 }' $HTTPDCONF`"
	fi
fi

NGINXCHECK=$(ps ax | awk '/nginx/' | awk '!/awk/')
if [ ! -z "$NGINXCHECK" ]; then
  NGINX=$(which nginx)
  NGINXCONFPATH=$($NGINX -t 2>&1 | awk '/nginx: configuration file/ {print $4}')
  if [ ! -z "$NGINXCONFPATHOVERRIDE" ]; then
    NGINXCONFPATH="$NGINXCONFPATHOVERRIDE"
  fi
  NGINXSETTINGS=$($EGREP '(^user|^worker_processes|^worker_priority|^worker_rlimit_nofile|^timer_resolution|^pcre_jit|^worker_connections|^accept_mutex|^multi_accept|^accept_mutex_delay|map_hash|server_names_hash|variables_hash|tcp_|^limit_|sendfile|server_tokens|keepalive_|lingering_|gzip|client_|connection_pool_size|directio|large_client|types_hash|server_names_hash|open_file|open_log|^include|^#include)' $NGINXCONFPATH | $EGREP -Ev '(rewrite|auth_|gzip_ratio)')
fi

fi # MYSQLSERVERONLY

if [[ "$WEBONLY" = [nN] ]]; then
DB=databasename #replace $dbname with $DB for only one database output
DATADIRL=`$MYSQLADMIN $MYSQLADMINOPT var | $AWK '/datadir/ { print $4}'`
DU=`du -s $DATADIRL | $AWK '{ print $1 }'`
ERRORLOG=`$MYSQLADMIN $MYSQLADMINOPT var | $AWK '/log_error/ { print $4}'`
INNODBCHECK=`$MYSQLADMIN $MYSQLADMINOPT var | $AWK '/have_innodb/ { print $4}'`
PSCHEMACHECK=`$MYSQLADMIN $MYSQLADMINOPT var | tr -s ' ' | $AWK '/performance_schema / {print $4}'`
SLOWLOGCHECK=`$MYSQLADMIN $MYSQLADMINOPT var | $AWK '/slow_query_log_file/ { print $4}'`
MYSQLCONNS=`$MYSQLADMIN $MYSQLADMINOPT processlist |wc -l`
#MYSQLVER='5.5.13'
#MYSQLVER=`$MYSQLADMIN $MYSQLADMINOPT var | $AWK '/version/' | $EGREP -Ev '(version_bdb|version_comment|version_compile_machine|version_compile_os|innodb_version|protocol_version|slave_type_conversions|Ssl_version)' | $AWK '{ print $4}' | cut -c1-5`

MYSQLVER=$($MYSQLCLI $MYSQLADMINOPT -N -t -e "select version();" | grep -Ev '+--' | awk '{ print substr ($2, 0, 6) }')

MYSQLUPTIME=`$MYSQLADMIN $MYSQLADMINOPT ext | awk '/Uptime|Uptime_since_flush_status/ { print $2,$4 }'`
MYSQLUPTIMEFORMAT=`$MYSQLADMIN $MYSQLADMINOPT ver | $AWK '/Uptime/ { print $2, $3, $4, $5, $6, $7, $8, $9 }'`
#MYSQLPID=`pidof mysqld`
DATABASES=`$MYSQLCLI $MYSQLADMINOPT -e 'show databases;' | $GREP -Ev '(Database|information_schema)'`
ALLDATABASES=`$MYSQLCLI $MYSQLADMINOPT -e 'show databases;' | $GREP -Ev '(Database|information_schema)' | sed ':a;N;$!ba;s/\n/ /g'`
fi
VIRTUALCORES=`$GREP -c ^processor /proc/cpuinfo`
PHYSICALCPUS=`$GREP 'physical id' /proc/cpuinfo | sort -u | wc -l`
CPUCORES=`$GREP 'cpu cores' /proc/cpuinfo | head -n 1 | cut -d: -f2`
CPUSPEED=`$AWK -F: '/cpu MHz/{print $2}' /proc/cpuinfo | sort | uniq -c`
CPUMODEL=`$AWK -F: '/model name/{print $2}' /proc/cpuinfo | sort | uniq -c`
CPUCACHE=`$AWK -F: '/cache size/{print $2}' /proc/cpuinfo | sort | uniq -c`

LS="$(which ls)"
LSOPT="-Alh"

if [[ "$WEBONLY" = [nN] ]]; then
# MySQL version check for supported features
MYSQLVERC="5.1"
MYSQLVERNOW=$(echo $MYSQLVER | awk '{print substr ($1, 0, 3)}')
VERCOMPARE=`expr $MYSQLVERNOW \> $MYSQLVERC`
fi

if [ "$VERCOMPARE" == "1" ]; then

MYSQLSTART=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT FROM_UNIXTIME(UNIX_TIMESTAMP() - variable_value) AS server_start FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE variable_name='Uptime';" | $EGREP -Ev '+--|server_start'`

fi

#######################################################
#ARCH_OVERRIDE='i386'
MACHINE_TYPE=`uname -m` # Used to detect if OS is 64bit or not.
#######################################################

if [ "${ARCH_OVERRIDE}" != '' ]
then
    ARCH=${ARCH_OVERRIDE}
else
    if [ ${MACHINE_TYPE} == 'x86_64' ];
    then
        ARCH='x86_64'
    else
        ARCH='i386'
    fi
fi

#######################################################
function funct_quickmysqlinfo {

if [[ "$WEBONLY" = [nN] ]]; then
if [ ! -f $MYSQLREPORTPATH ]; then
cd $SRCDIR

if [ -s mysqlreport ]; then
  echo ""
  else
  
  wget -q -c http://mysqlmymon.com/mysqlreport/mysqlreport
fi

chmod +x mysqlreport
fi

if [ -f $MYSQLREPORTPATH ]; then

$MYSQLREPORTPATH $MYSQLREPORTOPT 2> /dev/null > $MYSQLREPORTFILE

awk '/Max used/ {print "Max Used Connections:      "$3 "/" $5, "("$7 "%)"}' $MYSQLREPORTFILE
awk '/Buffer used/ {print "Key Buffer Used:           "$3 "/" $5, "("$7 "%)"}' $MYSQLREPORTFILE
awk '/  Current/ {print "Current Key Buffer Usage:  "$2, "("$4 "%)"}' $MYSQLREPORTFILE
if [ "${INNODBCHECK}" = 'YES' ]; then
awk '/^Usage/ {print "InnoDB Buffer Pool:        " $2 "/" $4, "("$6 "%)"}' $MYSQLREPORTFILE
fi
awk '/Memory usage/ {print "Query Cache:               "$3 "/" $5, "("$7 "%)"}' $MYSQLREPORTFILE
awk '/Waited/ {print "Table Locks Waited:        "$2 " Rate: " $3, "("$5 "%)"}' $MYSQLREPORTFILE

echo "--------------------"
$MYSQLADMIN $MYSQLADMINOPT var ext | awk '/query_cache_limit/ {print "Query Cache Limit (bytes):",$4}; /query_cache_min_res_unit/ {print "Query Cache Min Unit (bytes):",$4}; /query_cache_size/ {qcachesize = $4} END {print "Query Cache Size (bytes):",qcachesize};  /Qcache_free_memory/ {qcachefree = $4} END {print "Query Cache Free Mem (bytes):",qcachefree} ; { qcacheused =(qcachesize-qcachefree)} END {print "Query Cache Used Mem (bytes):",qcacheused}; /Qcache_queries_in_cache/ $4 != 0 || $4=1 {qcachequeries = $4} END {print "Queries in Query Cache:",qcachequeries}; qcachequieries > 0 || qcachequieries=1 {avgqsize =qcacheused/qcachequieries} END {print "Query Cache Avg Size (bytes):",avgqsize}'

rm -rf $MYSQLREPORTFILE

fi
fi

}


function funct_setup {

if [[ "$WEBONLY" = [nN] ]]; then
$MYSQLCLI -e "GRANT ALL PRIVILEGES ON *.* TO 'vbuserinfo'@'localhost' IDENTIFIED BY 'enteryourpassword';"
$MYSQLCLI -e "flush privileges;"
fi

}

function funct_help {

echo "install mysqlmymonlite.sh at $SRCDIR"
echo "chmod +x mysqlmymonlite.sh"
echo ""
echo "./mysqlmymonlite.sh --help"
echo "./mysqlmymonlite.sh check"
echo "./mysqlmymonlite.sh run"
echo "./mysqlmymonlite.sh mysql"
echo "./mysqlmymonlite.sh vmstat"
echo "./mysqlmymonlite.sh showcreate"
echo "./mysqlmymonlite.sh showindex"
echo "./mysqlmymonlite.sh vbshowtables"
echo "./mysqlmymonlite.sh dblist"
echo "./mysqlmymonlite.sh mysqlreport"
echo "./mysqlmymonlite.sh mysqlfullreport"
echo "./mysqlmymonlite.sh mysqltuner"
echo "./mysqlmymonlite.sh psmem"
echo "./mysqlmymonlite.sh pschema"

}

function whichcheck {

WHICHCHECK="$(which which 2>/dev/null)"

if [ ! -z $WHICHCHECK ]; then

# echo "which command exists"

echo

else

echo "which command not found"
echo ""
echo "installing which via YUM"
echo "yum -y -q install which"
yum -y -q install which

echo ""
echo ""
echo "Exiting script... please rerun $0"

exit

fi

}

smemstats() {

if [ ! -f /usr/bin/smem ]; then
	cd /usr/local/src
	wget http://www.selenic.com/smem/download/smem-1.4.tar.gz
	tar xzf smem-1.4.tar.gz 
	cd smem-1.4
	cp smem /usr/bin
	chmod 0700 /usr/bin/smem
	rm -rf ../smem-1.4*
	yum -q -y install python-matplotlib
else
	echo "smem -uk"
	smem -uk
	echo
	echo "smem -t -p"
	smem -t -p
	echo
	echo "smem -wk"
	smem -wk
	echo
fi

}

function funct_mysqlbug {

if [[ "$WEBONLY" = [nN] ]]; then
if [ -s /usr/bin/mysqlbug ]; then

MYSQLCOMPILE=`$EGREP '(^COMP_CALL_INFO|^CONFIGURE_LINE)' /usr/bin/mysqlbug`

echo ""
echo "-------------------"
echo "MySQL compile info:"
echo "-------------------"
echo "$MYSQLCOMPILE"
echo ""
        fi
fi

}

# MYSQLSERVERONLY
if [ "$MYSQLSERVERONLY" == 'n' ]; then

function funct_checkhttpd {

if [ -z "$APACHECHECK" ]; then
    APACHEON='offline'
else 
    APACHEON='online'
fi

}

function funct_nginxcheck {

if [ "${NGINXCHECK}" ]; then
echo ""
echo "---------------"
echo "You are running Nginx"
echo "---------------"
echo ""
$NGINX -V
echo ""
echo "$NGINXSETTINGS"

fi

}

fi # MYSQLSERVERONLY

function funct_check {

#Program paths
VMSTATPATH=`which vmstat`

echo "---------------"
echo $MYCNF
echo $DATADIRL
echo $ERRORLOG
echo $SLOWLOGCHECK
echo "---------------"
echo $SARPATH
echo $VMSTATPATH
echo "---------------"

# MYSQLSERVERONLY
if [ "$MYSQLSERVERONLY" == 'n' ]; then

echo ""

funct_checkhttpd

echo "---------------"
echo "Apache status: ${APACHEON}"
echo "---------------"

echo "httpd.conf located at: ${HTTPDCONF}"
echo "Apache error_log path: ${HTTPD_ERRORLOGPATH}"

if [ "${HTTPDMPMCHECK}" == "#Include" ]; then

echo "httpd-mpm.conf is not used"

elif [ "${HTTPDMPMCHECK}" == "Include" ]; then

	echo "httpd-mpm.conf is used"
	echo "httpd-mpm.conf located at: ${HTTPDMPMCONF}"

fi

if [ "${APACHEON}" == "online" ]; then

funct_httpdinfo

fi


funct_nginxcheck

fi # MYSQLSERVERONLY

echo ""

if [[ "$WEBONLY" = [nN] ]]; then
if [ "$VERCOMPARE" == "1" ]; then

MYSQLSTART=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT FROM_UNIXTIME(UNIX_TIMESTAMP() - variable_value) AS server_start FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE variable_name='Uptime';" | $EGREP -Ev '+--|server_start'`

echo "---------------"
echo "$MYSQLVER"
echo "MySQL server was started $MYSQLSTART"
echo "---------------"

funct_mysqlbug

else

echo "---------------"
echo "$MYSQLVER < $MYSQLVERC"
echo "---------------"

funct_mysqlbug
        fi
fi

}

function funct_phpinfo {

echo ""
echo "----------------------------------"
echo "CPANEL WEB SERVER & PHP Info:"
echo "----------------------------------"
echo "WHM / Cpanel version: $CPANELVER"
echo ""
echo "WHM's PHP Handler config:"
echo "/usr/local/cpanel/bin/rebuild_phpconf --current"
/usr/local/cpanel/bin/rebuild_phpconf --current
echo ""

php -v
echo ""
php -i | awk '/System/' | sed -e "s/`hostname`/yourserverhostname/g"
php -i | awk '/Build Date/' | head -n 1 && echo ""
php -i | awk '/configure/' && echo ""
php -i | awk '/php.ini|API/' | sed -e 's/=>/|/g' && echo ""

php -i | $EGREP '(display_errors|error_log|extension_dir|file_uploads|magic_quotes_gpc|log_errors|magic_quotes_sybase|max_execution_time|memory_limit|open_basedir|post_max_size|realpath_cache_size|realpath_cache_ttl|safe_mode|sendmail_path|upload_max_filesize|upload_tmp_dir)' | sed -e 's/=>/|/g' && echo ""

php -i | $EGREP '(^cURL|^GD|^FreeType|^GIF Read|^GIF Create|^JPEG Support|^libJPEG Version|^PNG Support|^libPNG Version|^WBMP Support|^XBN Support|^libXML|^PCRE|^Soap|^ZLib)' | sed -e 's/=>/|/g' && echo ""

php -i | awk '/APC|apc|xcache/' | sed -e 's/=>/|/g' && echo ""
php -i | $GREP -A30 'Opcode Caching' && echo ""
php -i | $GREP -B1 -A5 '^igbinary version' && echo ""
php -i | $GREP -A10 'imagick module' && echo "" 
php -i | $GREP -A15 'memcache support' && echo ""
php -i | $GREP -A15 'memcached support' && echo "" 
php -i | $GREP 'pcntl support' && echo "" 
php -i | $GREP -A5 'PCRE (Perl Compatible Regular Expressions) Support' && echo "" 
php -i | $GREP -A1 'PDO support' && echo "" 
php -i | $GREP -A1 'PDO Driver for MySQL' && echo "" 
php -i | $GREP -A1 'PDO Driver for SQLite 3.x' && echo "" 
php -i | $GREP -A18 'Phar: PHP Archive support' && echo "" 

php -i | $EGREP '(^suhosin.get.max_vars|^suhosin.post.max_vars|^suhosin.post.max_value_length|^suhosin.request.max_vars|^suhosin.request.max_value_length|^suhosin.executor.disable_eval|^suhosin.cookie.encrypt|^suhosin.memory_limit|^suhosin.get.max_value_length|^suhosin.upload.disallow_binary|^suhosin.upload.disallow_elf|^suhosin.upload.max_uploads|^suhosin.upload.remove_binary|^suhosin.upload.verification_script)' | sed -e 's/=>/|/g' && echo ""
php -i | $EGREP '(Apache Version|Max Requests|Timeouts|Loaded Modules)' | sed -e 's/=>/|/g' && echo ""

}

function funct_lsphpinfo {

echo ""
echo "------------------------------------------------"
echo "Litespeed Server & LSAPI PHP Info:"
echo "------------------------------------------------"
echo "Litespeed web server version: $LSVER"
echo "WHM / Cpanel version: $CPANELVER"
echo ""
echo "LSPHP phpSuExec status: "
echo "$LITESPEEDPHPSUEXEC"
echo ""
echo "WHM's PHP Handler config:"
echo "/usr/local/cpanel/bin/rebuild_phpconf --current"
echo ""
/usr/local/cpanel/bin/rebuild_phpconf --current
echo ""

$LSPHPBIN -v
echo ""
$LSPHPBIN -i | awk '/System/' | sed -e "s/`hostname`/yourserverhostname/g"
$LSPHPBIN -i | awk '/Build Date/' | head -n 1 && echo ""
$LSPHPBIN -i | awk '/configure/' && echo ""
$LSPHPBIN -i | awk '/php.ini|API/' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(display_errors|error_log|extension_dir|file_uploads|magic_quotes_gpc|log_errors|magic_quotes_sybase|max_execution_time|memory_limit|open_basedir|post_max_size|realpath_cache_size|realpath_cache_ttl|safe_mode|sendmail_path|upload_max_filesize|upload_tmp_dir)' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(^cURL|^GD|^FreeType|^GIF Read|^GIF Create|^JPEG Support|^libJPEG Version|^PNG Support|^libPNG Version|^WBMP Support|^XBN Support|^libXML|^PCRE|^Soap|^ZLib)' | sed -e 's/=>/|/g' && echo ""
$LSPHPBIN -i | awk '/APC|apc|xcache|memcache/' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(^suhosin.get.max_vars|^suhosin.post.max_vars|^suhosin.post.max_value_length|^suhosin.request.max_vars|^suhosin.request.max_value_length|^suhosin.executor.disable_eval|^suhosin.cookie.encrypt|^suhosin.memory_limit|^suhosin.get.max_value_length|^suhosin.upload.disallow_binary|^suhosin.upload.disallow_elf|^suhosin.upload.max_uploads|^suhosin.upload.remove_binary|^suhosin.upload.verification_script)' | sed -e 's/=>/|/g' && echo ""
$LSPHPBIN -i | $EGREP '(Apache Version|Max Requests|Timeouts|Loaded Modules)' | sed -e 's/=>/|/g' && echo ""

}

funct_olsphpinfo() {

echo ""
echo "-----------------------------------------------------"
echo "OpenLiteSpeed Server & LSAPI PHP Info:"
echo "-----------------------------------------------------"
echo "OpenLiteSpeed web server version: $LSVER"
echo ""

$LSPHPBIN -v
echo ""
$LSPHPBIN -i | awk '/System/' | sed -e "s/`hostname`/yourserverhostname/g"
$LSPHPBIN -i | awk '/Build Date/' | head -n 1 && echo ""
$LSPHPBIN -i | awk '/configure/' && echo ""
$LSPHPBIN -i | awk '/php.ini|API/' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(display_errors|error_log|extension_dir|file_uploads|magic_quotes_gpc|log_errors|magic_quotes_sybase|max_execution_time|memory_limit|open_basedir|post_max_size|realpath_cache_size|realpath_cache_ttl|safe_mode|sendmail_path|upload_max_filesize|upload_tmp_dir)' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(^cURL|^GD|^FreeType|^GIF Read|^GIF Create|^JPEG Support|^libJPEG Version|^PNG Support|^libPNG Version|^WBMP Support|^XBN Support|^libXML|^PCRE|^Soap|^ZLib)' | sed -e 's/=>/|/g' && echo ""
$LSPHPBIN -i | awk '/APC|apc|xcache|memcache/' | sed -e 's/=>/|/g' && echo ""

$LSPHPBIN -i | $EGREP '(^suhosin.get.max_vars|^suhosin.post.max_vars|^suhosin.post.max_value_length|^suhosin.request.max_vars|^suhosin.request.max_value_length|^suhosin.executor.disable_eval|^suhosin.cookie.encrypt|^suhosin.memory_limit|^suhosin.get.max_value_length|^suhosin.upload.disallow_binary|^suhosin.upload.disallow_elf|^suhosin.upload.max_uploads|^suhosin.upload.remove_binary|^suhosin.upload.verification_script)' | sed -e 's/=>/|/g' && echo ""
$LSPHPBIN -i | $EGREP '(Apache Version|Max Requests|Timeouts|Loaded Modules)' | sed -e 's/=>/|/g' && echo ""

}

function funct_httpdinfo {

echo ""

echo "$HTTPDFULLSTATUS" && echo ""
$APACHECTL -V && echo ""
$APACHECTL -M && echo ""
$APACHECTL -l && echo ""

if [ -s $HTTPDCONF ]; then

echo ""
echo "-------------------------------"
echo "From $HTTPDCONF"
echo "-------------------------------"
$GREP '^Timeout' $HTTPDCONF
$GREP '^KeepAlive' $HTTPDCONF | head -n 1
$GREP '^MaxKeepAliveRequests' $HTTPDCONF
$GREP '^KeepAliveTimeout' $HTTPDCONF
echo ""
$EGREP '(^<IfModule prefork.c>|^StartServers|^MinSpareServers|^MaxSpareServers|^ServerLimit|^MaxClients|^MaxRequestsPerChild|^</IfModule>|^<IfModule worker.c>|^MaxClients|^MinSpareThreads|^MaxSpareThreads|^ThreadsPerChild)' $HTTPDCONF | uniq
echo ""

fi

if [ ! -z $HTTPDMPMCONF ]; then

echo ""
echo "-------------------------------"
echo "From $HTTPDMPMCONF"
echo "-------------------------------"
awk '/^Timeout/; /^KeepAlive/; /^MaxKeepAliveRequests/; /^KeepAliveTimeout/' $HTTPDMPMCONF
echo ""
$EGREP '(^<IfModule prefork.c>|^StartServers|^MinSpareServers|^MaxSpareServers|^ServerLimit|^MaxClients|^MaxRequestsPerChild|^</IfModule>|^<IfModule worker.c>|^MaxClients|^MinSpareThreads|^^MaxSpareThreads|^ThreadsPerChild)' $HTTPDMPMCONF | uniq
echo ""

fi

}

function funct_topprocesses {

echo ""
echo "----------------------------"
echo "HTTPD / MySQL processes"
echo "----------------------------"
echo ""

if [[ "$WEBONLY" = [nN] ]]; then
echo "Number of open MySQL connections: $MYSQLCONNS"
fi
echo ""

if [[ "$WEBONLY" = [nN] ]]; then
if ps ax | $GREP -v $GREP | $GREP mysql >/dev/null
then
ps auxwww | $GREP mysql | $GREP -v $GREP | $GREP -v mysqlmymonlite | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12 $13, $14, $15, $16, $17}'
echo ""
        fi
fi

if ps ax | $GREP -v $GREP | $GREP httpd >/dev/null
then
ps auxwww | $GREP httpd | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP nginx >/dev/null
then
ps auxwww | $GREP nginx | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP php-fpm >/dev/null
then
ps auxwww | $GREP php-fpm | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP varnish >/dev/null
then
ps auxwww | $GREP varnish | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16, $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $30 $31 $32 $33 $34 $35 $36 $37}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP litespeed >/dev/null
then
ps auxwww | $GREP litespeed | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP memcached >/dev/null
then
ps auxwww | $GREP memcached | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP searchd >/dev/null
then
ps auxwww | $GREP searchd | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP heartbeat >/dev/null
then
ps auxwww | $GREP heartbeat | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}'
echo ""
fi

if ps ax | $GREP -v $GREP | $GREP buagent >/dev/null
then
ps auxwww | $GREP buagent | $GREP -v $GREP | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}'
echo ""
fi

echo "----------------------------"
echo "Top 5 Memory Consuming Process"
echo "----------------------------"
echo ""

ps auxw | sort -nr -k 4 | head -5 | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12 $13, $14, $15, $16, $17}'

echo ""
echo "----------------------------"
echo "Top 5 CPU Consuming Process"
echo "----------------------------"
echo ""

ps auxw | sort -nr -k 3 | head -5 | $AWK '{ print $1, $2, $3, $4, $5, $6, $10, $11, $12 $13, $14, $15, $16, $17}'

}

function funct_reportstart {

echo "-------------------------------------------------------------"
echo "System MySQL monitoring stats"
echo "mysqlmymonlite.sh - $MYSQLMYMONVER $MYSQLMYMONURL"
echo "compiled by George Liu (eva2000) centminmod.com"
echo "-------------------------------------------------------------"
echo ""
echo "Report Generated:"
echo $(date)

}

function funct_mysqluptime {

if [[ "$WEBONLY" = [nN] ]]; then
echo ""
echo "----------------------------"
echo "MySQL Uptime:"
echo "----------------------------"
echo "MySQL server was started $MYSQLSTART"
echo "Uptime: $MYSQLUPTIMEFORMAT"
echo "$MYSQLUPTIME"
echo ""
funct_quickmysqlinfo
fi

}

function funct_topmemory {

echo ""
echo "----------------------------"
echo "TOP stats"
echo "----------------------------"
echo ""

if [ -s /usr/bin/mpstat ]; then
mpstat -P ALL 2 2 | sed -e "s/\(`hostname`\)/\(yourserverhostname\)/g"
echo ""
fi
top -b -n 1

echo ""
free -ml

echo ""
cat /proc/meminfo

echo ""
funct_psmem

echo ""
smemstats

}

function funct_serverdiskusage {

echo ""
echo "----------------------------"
echo "Server Disk Usage"
echo "----------------------------"
df -Th

}

function funct_mysqldiskusage {

if [[ "$WEBONLY" = [nN] ]]; then
echo ""
echo "----------------------------"
echo "MySQL datadir disk usage"
echo "----------------------------"
echo "$DATADIRL uses $DU kilobytes of disk space"
fi

}

function funct_mysqlengineusage {

if [[ "$WEBONLY" = [nN] ]]; then
echo ""
echo "----------------------------"
echo "Total Server MyISAM and InnoDB Size"
echo "----------------------------"
$MYSQLCLI $MYSQLADMINOPT -e "select round(sum(innodb_data_size + innodb_index_size) / (innodb_data_free + sum(innodb_data_size + innodb_index_size))) * 100  as 'innodb_tablespace_utilization_perc'
, (data_size + index_size) / gb as total_size_gb
, index_size / gb as index_size_gb
, data_size / gb as data_size_gb
, sum(innodb_index_size + innodb_data_size) / pow(1024,3) as innodb_total_size_gb
, innodb_data_size / pow(1024,3) as innodb_data_size_gb
, innodb_index_size / pow(1024,3) as innodb_index_size_gb
, sum(myisam_index_size + myisam_data_size) / pow(1024,3) as myisam_total_size_gb
, myisam_data_size / pow(1024,3) as myisam_data_size_gb
, myisam_index_size / pow(1024,3) as myisam_index_size_gb
, index_size / (data_size + index_size) * 100 as perc_index
, data_size / (data_size + index_size) * 100 as perc_data
, innodb_index_size / (innodb_data_size + innodb_index_size) * 100 as innodb_perc_index
, innodb_data_size / (innodb_data_size + innodb_index_size) * 100 as innodb_perc_data
, myisam_index_size / (myisam_data_size + myisam_index_size) * 100 as myisam_perc_index
, myisam_data_size / (myisam_data_size + myisam_index_size) * 100 as myisam_perc_data
, innodb_index_size / index_size * 100 as innodb_perc_total_index
, innodb_data_size / data_size * 100 as innodb_perc_total_data
, myisam_index_size / index_size * 100 as myisam_perc_total_index
, myisam_data_size / data_size * 100 as myisam_perc_total_data
from ( select sum(data_length) data_size,
	sum(index_length) index_size,
	sum(if(engine = 'innodb', data_length, 0)) as innodb_data_size,
	sum(if(engine = 'innodb', index_length, 0)) as innodb_index_size,
	sum(if(engine = 'myisam', data_length, 0)) as myisam_data_size,
	sum(if(engine = 'myisam', index_length, 0)) as myisam_index_size,
	sum(if(engine = 'innodb', data_free, 0)) as innodb_data_free,
	pow(1024, 3) gb from information_schema.tables )
a\G"
fi

}

function funct_mysqlfullreport {

if [[ "$WEBONLY" = [nN] ]]; then
funct_reportstart

funct_mysqluptime

funct_topmemory

funct_serverdiskusage

funct_mysqldiskusage

funct_mysqlreportoutput
echo ""
echo "----------------------------"
echo "MySQL settings"
echo "----------------------------"

cat $MYCNF
echo "---"
#$MYSQLADMIN $MYSQLADMINOPT var ext proc | $TR -s ' ' | sed -e "s/`hostname`/yourserverhostname/g"


if [ "${INNODBCHECK}" = 'YES' ]
then

echo ""
echo "----------------------------"
echo "INNODB Status"
echo "----------------------------"

	$MYSQLCLI $MYSQLADMINOPT -e 'show engine innodb status\G'
fi

echo ""
echo "----------------------------"
echo "MySQL Error Log"
echo "----------------------------"
#echo "tail -15 $ERRORLOG"
echo ""

if [ -z "$ERRORLOG" ]; then
echo "MySQL error log not set"
elif [[ $ERRORLOG != '|' ]]; then
tail -15 $ERRORLOG | sed -e "s/`hostname`/yourserverhostname/g"
else
echo "MySQL error log not set"
fi

funct_mysqlengineusage

echo ""
echo "Report Complete:"
echo $(date)
echo "----------------------------"
fi

}

function funct_mysqlreport {

if [[ "$WEBONLY" = [nN] ]]; then
funct_reportstart

funct_mysqlreportoutput
echo ""
echo "Report Complete:"
echo $(date)
echo "----------------------------"
fi

}

function funct_mysqltuner {

if [[ "$WEBONLY" = [nN] ]]; then
funct_reportstart

echo ""
echo "-------------------------------------------------"
echo "mysqltuner output"
echo "-------------------------------------------------"

cd $SRCDIR

if [ -s mysqltuner.pl ]; then
  echo "mysqltuner.pl [found]"
  else
  
  wget -q -c http://mysqlmymon.com/mysqltuner/mysqltuner.txt -O mysqltuner.pl --tries=3
fi

chmod +x mysqltuner.pl

$SRCDIR/mysqltuner.pl $MYSQLTUNEROPT

echo ""
echo "Report Complete:"
echo $(date)
echo "----------------------------"
fi
}

function funct_runmin {

funct_reportstart

funct_mysqluptime

funct_cpuinfo

funct_topmemory

funct_serverdiskusage

funct_mysqldiskusage

echo ""
echo "----------------------------"
echo "ulimit -aH"
echo "----------------------------"
ulimit -aH

echo ""
echo "----------------------------------------------------------"
echo "tail -15 /etc/security/limits.conf"
echo "----------------------------------------------------------"
tail -15 /etc/security/limits.conf

if [[ "$WEBONLY" = [nN] ]]; then
if [ -f /etc/security/limits.d/91-mysql.conf ]; then
echo ""
echo "----------------------------------------------------------"
echo "cat /etc/security/limits.d/91-mysql.conf"
echo "----------------------------------------------------------"
cat /etc/security/limits.d/91-mysql.conf
fi

echo ""
echo "----------------------------------------------------------"
echo "mysqld process limits: "
echo "cat /proc/`pidof mysqld`/limits"
echo "----------------------------------------------------------"
cat /proc/`pidof mysqld`/limits
fi

# MYSQLSERVERONLY
if [ "$MYSQLSERVERONLY" == 'n' ]; then

funct_phpinfo

funct_checkhttpd

if [ "${APACHEON}" == "online" ]; then

funct_httpdinfo

fi

funct_nginxcheck

if [[ ! -z "$LITESPEEDCHECK" && -z "$OPENLITESPEEDCHECK" ]]; then
	funct_litespeedstats
	echo ""
	funct_lsphpinfo
elif  [ "$OPENLITESPEEDCHECK" ]; then
	funct_litespeedstats
	echo ""
	funct_olsphpinfo
fi

fi # MYSQLSERVERONLY

if [[ "$WEBONLY" = [nN] ]]; then
funct_mysqlreportoutput

funct_mysqlengineusage


if [[ "$SHOWPERTABLE" = [yY] ]]; then
echo ""
echo "----------------------------"
echo "Table Index Size"
echo "----------------------------"

for dbname in $DATABASES; do

DBIDXSIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(index_length)/(1024*1024), 2), ' MB') AS 'Total Index Size' FROM information_schema.TABLES WHERE table_schema LIKE '$dbname';" | $EGREP -Ev '(+-|Total Index Size)'`

if [[ "$MASKDB" = [yY] ]]; then

echo "------------------------------"
echo "$(echo $dbname | sed 's/\(.\{1\}\).\{1\}/**\1/g') Index Size = $DBIDXSIZE"
echo "------------------------------"

else

echo "------------------------------"
echo "$dbname Index Size = $DBIDXSIZE"
echo "------------------------------"

fi
done

echo ""
echo "----------------------------"
echo "Table Data Size"
echo "----------------------------"
for dbname in $DATABASES; do
DBDATASIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(data_length)/(1024*1024), 2), ' MB') AS 'Total Data Size'
FROM information_schema.TABLES WHERE table_schema LIKE '$dbname';" | $EGREP -Ev '(+-|Total Data Size)'`
if [[ "$MASKDB" = [yY] ]]; then

echo "------------------------------"
echo "$(echo $dbname | sed 's/\(.\{1\}\).\{1\}/**\1/g') Data Size = $DBDATASIZE"
echo "------------------------------"

else

echo "------------------------------"
echo "$dbname Data Size = $DBDATASIZE"
echo "------------------------------"

fi
done

echo ""
echo "----------------------------"
echo "Database per Table Size"
echo "----------------------------"
fi
#################################
for dbnamed in $DATABASES
do
skipdb=-1
    if [ "$EXCLUDEDB" != "" ];
    then
        for i in $EXCLUDEDB
        do
            [ "$dbnamed" == "$i" ] && skipdb=1 || :
        done
    fi
#################################

if [ "$skipdb" == "-1" ]; then

if [[ "$SHOWPERTABLE" = [yY] ]]; then
if [[ "$MASKDB" = [yY] ]]; then

echo ""
echo "----------------------"
echo "$(echo $dbnamed | sed 's/\(.\{1\}\).\{1\}/**\1/g') per Table Size"
echo "----------------------"

else

echo ""
echo "----------------------"
echo "$dbnamed per Table Size"
echo "----------------------"

fi
fi

if [[ "$SHOWPERTABLE" = [yY] ]]; then
if [[ "$MASKDB" = [yY] ]]; then

$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$dbnamed';" | sed -e "s/$dbnamed/$(echo $dbnamed | sed 's/\(.\{1\}\).\{1\}/**\1/g')/g"

else

$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$dbnamed';"

fi
fi

fi
done

echo ""
echo "----------------------------"
echo "MySQL settings"
echo "----------------------------"

cat $MYCNF
echo "---"
$MYSQLADMIN $MYSQLADMINOPT var ext proc | $TR -s ' ' | sed -e "s/`hostname`/yourserverhostname/g"


if [ "${INNODBCHECK}" = 'YES' ]
then

if [ "$VERCOMPARE" == "1" ]; then
echo ""
echo "------------------------------------"
echo "INNODB Buffer Pool Stats"
echo "------------------------------------"

	$MYSQLCLI $MYSQLADMINOPT -e 'select * from information_schema.innodb_buffer_pool_stats\G' 2>/dev/null

fi

echo ""
echo "----------------------------"
echo "INNODB Status"
echo "----------------------------"

	$MYSQLCLI $MYSQLADMINOPT -e 'show engine innodb status\G'
fi

echo ""
echo "----------------------------"
echo "MySQL Error Log"
echo "----------------------------"
#echo "tail -15 $ERRORLOG"
echo ""

if [ -z "$ERRORLOG" ]; then
echo "MySQL error log not set"
elif [[ $ERRORLOG != '|' ]]; then
tail -15 $ERRORLOG | sed -e "s/`hostname`/yourserverhostname/g"
else
echo "MySQL error log not set"
fi

echo ""
echo "Report Complete:"
echo $(date)
echo "----------------------------"
fi
}

function funct_installepelrepo {

rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/${ARCH}/epel-release-5-4.noarch.rpm

}

function funct_install_lshw {

if [ ! -s /usr/sbin/lshw ]; then

	if [ -s /etc/redhat-release ]; then

	funct_installepelrepo
	yum -y -q install lshw

	elif [ -s /etc/issue ]; then

	apt-get install lshw

	fi

fi

}

function funct_cpuinfo {

echo ""
echo "----------------------------"
echo "Hardware Info:"
echo "----------------------------"
if [ -z ${CPUCORES} ]; then
CPUCORES='1'
fi

if [ -z ${PHYSICALCPUS} ]; then
PHYSICALCPUS='1'
fi

CPUCORES=$((${CPUCORES} * ${PHYSICALCPUS}));
	if [ ${CPUCORES} -gt 0 -a ${CPUCORES} -lt ${VIRTUALCORES} ]; then 
	HT=yes; 
	else HT=no; 
fi

echo "Processors" "physical = ${PHYSICALCPUS}, cores = ${CPUCORES}, virtual = ${VIRTUALCORES}, hyperthreading = ${HT}"
echo "$CPUSPEED"
echo "$CPUMODEL"
echo "$CPUCACHE"
echo ""

}

function funct_lshw {

echo ""

lshw -short -sanitize

echo ""

lshw -businfo -sanitize

}

function funct_cleanup {

$MYSQLCLI -e "drop user 'vbuserinfo'@'localhost';"
$MYSQLCLI -e "flush privileges;"

}

function funct_mysql {

if [[ "$WEBONLY" = [nN] ]]; then
echo ""
echo "----------------------------"
echo "MySQL Uptime:"
echo "----------------------------"
echo "MySQL server was started $MYSQLSTART"
echo "Uptime: $MYSQLUPTIMEFORMAT"
echo "$MYSQLUPTIME"
echo ""
funct_quickmysqlinfo

echo ""
echo "----------------------------"
echo "Server Disk Usage"
echo "----------------------------"
df -Th

echo ""
echo "----------------------------"
echo "MySQL datadir disk usage"
echo "----------------------------"
echo "$DATADIRL uses $DU kilobytes of disk space"

funct_mysqlreportoutput

funct_mysqlengineusage

if [[ "$SHOWPERTABLE" = [yY] ]]; then
echo ""
echo "----------------------------"
echo "Table Index Size"
echo "----------------------------"

for dbname in $DATABASES; do

DBIDXSIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(index_length)/(1024*1024), 2), ' MB') AS 'Total Index Size' FROM information_schema.TABLES WHERE table_schema LIKE '$dbname';" | $EGREP -Ev '(+-|Total Index Size)'`

if [[ "$MASKDB" = [yY] ]]; then

echo "------------------------------"
echo "$(echo $dbname | sed 's/\(.\{1\}\).\{1\}/**\1/g') Index Size = $DBIDXSIZE"
echo "------------------------------"

else

echo "------------------------------"
echo "$dbname Index Size = $DBIDXSIZE"
echo "------------------------------"

fi
done

echo ""
echo "----------------------------"
echo "Table Data Size"
echo "----------------------------"
for dbname in $DATABASES; do
DBDATASIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(data_length)/(1024*1024), 2), ' MB') AS 'Total Data Size'
FROM information_schema.TABLES WHERE table_schema LIKE '$dbname';" | $EGREP -Ev '(+-|Total Data Size)'`
if [[ "$MASKDB" = [yY] ]]; then

echo "------------------------------"
echo "$(echo $dbname | sed 's/\(.\{1\}\).\{1\}/**\1/g') Data Size = $DBDATASIZE"
echo "------------------------------"

else

echo "------------------------------"
echo "$dbname Data Size = $DBDATASIZE"
echo "------------------------------"

fi
done

echo ""
echo "----------------------------"
echo "$DB per Table Size"
echo "----------------------------"
fi
#################################
for dbnamed in $DATABASES
do
skipdb=-1
    if [ "$EXCLUDEDB" != "" ];
    then
        for i in $EXCLUDEDB
        do
            [ "$dbnamed" == "$i" ] && skipdb=1 || :
        done
    fi
#################################

if [ "$skipdb" == "-1" ]; then

if [[ "$SHOWPERTABLE" = [yY] ]]; then
if [[ "$MASKDB" = [yY] ]]; then

echo ""
echo "----------------------"
echo "$(echo $dbnamed | sed 's/\(.\{1\}\).\{1\}/**\1/g') per Table Size"
echo "----------------------"

else

echo ""
echo "----------------------"
echo "$dbnamed per Table Size"
echo "----------------------"

fi
fi

if [[ "$SHOWPERTABLE" = [yY] ]]; then
if [[ "$MASKDB" = [yY] ]]; then

$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$dbnamed';" | sed -e "s/$dbnamed/$(echo $dbnamed | sed 's/\(.\{1\}\).\{1\}/**\1/g')/g"

else

$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$dbnamed';"

fi
fi

fi
done

echo ""
echo "----------------------------"
echo "MySQL settings"
echo "----------------------------"

cat $MYCNF
echo "---"
$MYSQLADMIN $MYSQLADMINOPT var ext proc | $TR -s ' ' | sed -e "s/`hostname`/yourserverhostname/g"
echo ""
echo "---"
$MYSQLADMIN $MYSQLADMINOPT proc -i 3 -c 5


if [ "${INNODBCHECK}" = 'YES' ]
then

echo ""
echo "----------------------------"
echo "INNODB Status"
echo "----------------------------"

	$MYSQLCLI $MYSQLADMINOPT -e 'show engine innodb status\G'
fi

echo ""
echo "----------------------------"
echo "MySQL Error Log"
echo "----------------------------"
echo "tail -50 $ERRORLOG"
echo ""

if [ -z "$ERRORLOG" ]; then
echo "MySQL error log not set"
elif [[ $ERRORLOG != '|' ]]; then
tail -50 $ERRORLOG | sed -e "s/`hostname`/yourserverhostname/g"
else
echo "MySQL error log not set"
fi

echo ""
echo "Report Complete:"
echo $(date)
echo "----------------------------"
fi
}

function funct_vmstat {

echo ""
echo "----------------------------"
echo "vmstat"
echo "----------------------------"
echo $(date)
echo ""

vmstat 1 10

}

#########################################################

function funct_askdbname {

read -ep "What is your mysql database name ? " mysqldbname

echo ""

}

function funct_showtablescreate {

echo ""

read -ep "Do you want to display all ${mysqldbname} tables' schema (how table was created) ? [y/n] " showcreatetables

if [[ "${showcreatetables}" = [yY] ]];
then

echo ""
read -ep "Do you want save output to text file ? Answering no will output only to screen. [y/n] " savetologfile

	if [[ "${savetologfile}" = [yY] ]];
	then

echo ""
read -ep "Enter directory path where you want to save the text file i.e. /home/username " textdir

if [ ! -d ${textdir} ]; then

echo "${textdir} doesn't exist, please create it or double check you entered right path" 

exit

else

TABLENAME=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT table_name FROM information_schema.tables WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(table_name|+---)'`

for mysqldbtablename in $TABLENAME; do
TEXTFILE="$textdir/$mysqldbname-$mysqldbtablename-showcreate.txt"
echo "saving to: $TEXTFILE"
$MYSQLCLI $MYSQLADMINOPT -e "SHOW CREATE TABLE ${mysqldbtablename}\G;" $mysqldbname > $TEXTFILE
done

echo ""
echo "*******************************************************"
echo "$mysqldbname table schema saved at: $textdir"
echo "*******************************************************"
$LS $LSOPT $textdir | $AWK '{ printf "%-4s%-4s%-8s%-6s %s\n", $6, $7, $8, $5, $9 }' | $GREP $mysqldbname

fi

	else

TABLENAME=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT table_name FROM information_schema.tables WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(table_name|+---)'`

for mysqldbtablename in $TABLENAME; do
$MYSQLCLI $MYSQLADMINOPT -e "SHOW CREATE TABLE $mysqldbtablename\G;" $mysqldbname
done

	fi

fi

}

#########################################################

function funct_showtableindexes {

echo ""

read -ep "Do you want to display all ${mysqldbname} tables' indexes ? [y/n]" showindexestables

if [[ "${showindexestables}" = [yY] ]];
then

echo ""
read -ep "Do you want save output to text file ? Answering no will output only to screen. [y/n]" savetologfile

	if [[ "${savetologfile}" = [yY] ]];
	then

echo ""
read -ep "Enter directory path where you want to save the text file i.e. /home/username " textdir

if [ ! -d ${textdir} ]; then

echo "${textdir} doesn't exist, please create it or double check you entered right path" 

exit

else

TABLENAME=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT table_name FROM information_schema.tables WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(table_name|+---)'`

for mysqldbtablename in $TABLENAME; do
TEXTFILE="$textdir/$mysqldbname-$mysqldbtablename-indexes.txt"
echo "saving to: $TEXTFILE"
$MYSQLCLI $MYSQLADMINOPT -t -e "SHOW INDEXES FROM ${mysqldbtablename};" $mysqldbname > $TEXTFILE
done

echo ""
echo "*******************************************************"
echo "$mysqldbname table index list saved at: $textdir"
echo "*******************************************************"
$LS $LSOPT $textdir | $AWK '{ printf "%-4s%-4s%-8s%-6s %s\n", $6, $7, $8, $5, $9 }' | $GREP $mysqldbname

fi

	else

TABLENAME=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT table_name FROM information_schema.tables WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(table_name|+---)'`

for mysqldbtablename in $TABLENAME; do
$MYSQLCLI $MYSQLADMINOPT -e "SHOW INDEXES FROM $mysqldbtablename;" $mysqldbname
done

	fi

fi

}

#########################################################

function funct_vbshowtables {

echo ""
read -ep "Do you want to continue with display all ${mysqldbname} tables info ? [y/n]" vbshowtablescheck

if [[ "${vbshowtablescheck}" = [yY] ]];
then

echo ""
read -ep "Do you want save output to text file ? Answering no will output only to screen. [y/n]" savetologfile

	if [[ "${savetologfile}" = [yY] ]];
	then

echo ""
read -ep "Enter directory path where you want to save the text file i.e. /home/username " textdir

if [ ! -d ${textdir} ]; then

echo "${textdir} doesn't exist, please create it or double check you entered right path" 

exit

else

TEXTFILE="$textdir/$mysqldbname-$DT.txt"
echo "saving to: $TEXTFILE"

VBDBDATASIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(data_length)/(1024*1024), 2), ' MB') AS 'Total Data Size'
FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(+-|Total Data Size)'`

VBDBIDXSIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(index_length)/(1024*1024), 2), ' MB') AS 'Total Index Size' FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(+-|Total Index Size)'`

VBPERTABLEINFO=`$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';"`

cat >$TEXTFILE<<EOF
----------------------------
MySQL datadir disk usage
----------------------------
$DATADIRL uses $DU kilobytes of disk space

------------------------------
$mysqldbname Index Size = $VBDBIDXSIZE
------------------------------
$mysqldbname Data Size = $VBDBDATASIZE
------------------------------

----------------------
$mysqldbname per Table Size"
----------------------
$VBPERTABLEINFO

EOF

echo ""
echo "*******************************************************"
echo "$mysqldbname database table info saved at: $textdir"
echo "*******************************************************"
$LS $LSOPT $textdir | $AWK '{ printf "%-4s%-4s%-8s%-6s %s\n", $6, $7, $8, $5, $9 }' | $GREP $mysqldbname

fi

	else

echo ""
echo "----------------------------"
echo "MySQL datadir disk usage"
echo "----------------------------"
echo "$DATADIRL uses $DU kilobytes of disk space"
echo ""

VBDBIDXSIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(index_length)/(1024*1024), 2), ' MB') AS 'Total Index Size' FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(+-|Total Index Size)'`
echo "------------------------------"
echo "$mysqldbname Index Size = $VBDBIDXSIZE"
echo "------------------------------"


VBDBDATASIZE=`$MYSQLCLI $MYSQLADMINOPT -e "SELECT CONCAT(ROUND(SUM(data_length)/(1024*1024), 2), ' MB') AS 'Total Data Size'
FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';" | $EGREP -Ev '(+-|Total Data Size)'`
echo "------------------------------"
echo "$mysqldbname Data Size = $VBDBDATASIZE"
echo "------------------------------"

echo ""
echo "----------------------"
echo "$mysqldbname per Table Size"
echo "----------------------"
$MYSQLCLI $MYSQLADMINOPT -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total'FROM information_schema.TABLES WHERE table_schema LIKE '$mysqldbname';"


	fi

fi


}

function funct_mysqlreportoutput {

echo ""
echo "----------------------------"
echo "mysqlreport output"
echo "----------------------------"

cd $SRCDIR

if [ -s mysqlreport ]; then
  echo ""
  else
  
  wget -q -c http://mysqlmymon.com/mysqlreport/mysqlreport
fi

chmod +x mysqlreport

$SRCDIR/mysqlreport $MYSQLREPORTOPT 2>/dev/null

}

function funct_psmem {

if [ -s ps_mem.py ]; then
  echo "--------------------------"
  echo "ps_mem.py output:"
  echo "http://www.pixelbeat.org/scripts/ps_mem.py"
  echo "--------------------------"
  else
  echo
#  echo "Error: ps_mem.py not found!!!download now......"
  wget -q -c http://mysqlmymon.com/psmem/ps_mem.py --tries=3
fi

python ps_mem.py

}

function funct_litespeedstats {

if [ ! -z "$LITESPEEDCHECK" ]; then

echo ""
if [[ ! -z "$LITESPEEDCHECK" && -z "$OPENLITESPEEDCHECK" ]]; then
	echo "--------------------------------------------"
	echo "Litespeed Web server stats"
	echo "--------------------------------------------"
elif  [ "$OPENLITESPEEDCHECK" ]; then
	echo "--------------------------------------------"
	echo "OpenLiteSpeed Web server stats"
	echo "--------------------------------------------"
fi

RTREPORT=`ls -a /tmp/lshttpd | awk '/rtreport/'`

for i in $RTREPORT; do

echo $i

cd /tmp/lshttpd

echo "-------------------------------------------------------------"
cat $i | awk '/VERSION/; /UPTIME/; /BPS/ { print $1,$2,$3,$4 "\n"$5,$6,$7,$8}; /^MAXCONN/ {print $1,$2,$5,$6,$7,$8,$9,$10 "\n"$3,$4,$11,$12,$13,$14}' 

#cat $i | awk '/REQ_RATE \[/ {a+=$4;b+=$6;c+=$8;d+=$10;e+=$12;aa=$1;bb=$3;cc=$5;dd=$7;ee=$9;ff=$11} END{ print aa,bb,a,cc,b,dd,c"\n"ee,d,ff,e}'

cat $i | awk 'NR==4, /REQ_RATE \[/ { print $1,$3,$4,$5,$6,$7,$8 "\n"$1,$9,$10,$11,$12}'


cat $i | awk '/lsphp5/ {print $4, $5,$6,$7,$8,$9,$10"\n"$4,$11,$12,$13,$14"\n"$4,$15,$16,$17,$18,$19,$20}'
echo "-------------------------------------------------------------"

done

fi

}
#########################################################

perfschema() {

MYSQLVER=$(echo $MYSQLVER| cut -c1,2,3)

if [ "$MYSQLVER" == '5.5' ]; then

if [ "$PSCHEMACHECK" == 'ON' ]; then

echo "---------------------------------------"
echo "Process List"
$MYSQLCLI $MYSQLADMINOPT -e "select * from performance_schema.threads ORDER BY THREAD_ID;"
echo ""

echo "---------------------------------------"
echo "PERFORMANCE_SCHEMA Var status"
$MYSQLCLI $MYSQLADMINOPT -e "SHOW VARIABLES LIKE 'perf%';"
echo ""

echo "---------------------------------------"
echo "PERFORMANCE_SCHEMA Status"
$MYSQLCLI $MYSQLADMINOPT -e "SHOW STATUS LIKE 'perf%';"
echo ""

echo "---------------------------------------"
echo "PERFORMANCE_SCHEMA Engine status"
$MYSQLCLI $MYSQLADMINOPT -e "show engine PERFORMANCE_SCHEMA status;"
echo ""

echo "---------------------------------------"
echo "PERFORMANCE_SCHEMA setup_instruments"
$MYSQLCLI $MYSQLADMINOPT -e "select * from performance_schema.setup_instruments;"
echo ""

echo "---------------------------------------"
echo "PERFORMANCE_SCHEMA setup_timers"
$MYSQLCLI $MYSQLADMINOPT -e "select * from performance_schema.performance_timers; select * from performance_schema.setup_timers;"
echo ""

if [ "${INNODBCHECK}" = 'YES' ]; then
echo "---------------------------------------"
echo "InnoDB Engine Mutex List"
$MYSQLCLI $MYSQLADMINOPT -e "show engine innodb mutex;"
echo ""
fi

echo "---------------------------------------"
echo "Event Waits Summary - All"
$MYSQLCLI $MYSQLADMINOPT -e "SELECT EVENT_NAME, SUM_TIMER_WAIT/1000000000 WAIT_MS, COUNT_STAR FROM performance_schema.events_waits_summary_by_thread_by_event_name ORDER BY SUM_TIMER_WAIT DESC, COUNT_STAR DESC LIMIT 30;"
echo ""

echo "---------------------------------------"
echo "Event Waits Summary - wait/io/file only"
$MYSQLCLI $MYSQLADMINOPT -e "SELECT EVENT_NAME, SUM_TIMER_WAIT/1000000000 WAIT_MS, COUNT_STAR FROM performance_schema.events_waits_summary_by_thread_by_event_name where event_name like 'wait/io/file/%' ORDER BY SUM_TIMER_WAIT DESC, COUNT_STAR DESC LIMIT 30;"
echo ""

echo "---------------------------------------"
echo "Disk I/O + Data"
$MYSQLCLI $MYSQLADMINOPT -e "SELECT event_name, count_star, ROUND(sum_timer_wait/1000000000000, 2) total_sec, ROUND(min_timer_wait/1000000, 2) min_usec, ROUND(avg_timer_wait/1000000, 2) avg_usec, ROUND(max_timer_wait/1000000, 2) max_usec, count_read, ROUND(sum_number_of_bytes_read/1024/1024, 2) read_mb, count_write, ROUND(sum_number_of_bytes_write/1024/1024, 2) write_mb FROM performance_schema.events_waits_summary_global_by_event_name JOIN performance_schema.file_summary_by_event_name USING (event_name) WHERE event_name LIKE 'wait/io/file/%' ORDER BY sum_timer_wait DESC LIMIT 20;"
echo ""

echo "---------------------------------------"
echo "Current Event Waits"
$MYSQLCLI $MYSQLADMINOPT -e "SELECT THREAD_ID,EVENT_ID,EVENT_NAME,SOURCE,TIMER_WAIT,SPINS,OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE, NESTING_EVENT_ID,OPERATION,NUMBER_OF_BYTES FROM performance_schema.events_waits_current ORDER BY EVENT_ID;"
echo ""

echo "---------------------------------------"
echo "Event Waits History"
$MYSQLCLI $MYSQLADMINOPT -e "SELECT THREAD_ID,EVENT_ID,EVENT_NAME,SOURCE,TIMER_WAIT,SPINS,OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE, NESTING_EVENT_ID,OPERATION,NUMBER_OF_BYTES FROM performance_schema.events_waits_history ORDER BY EVENT_ID;"
echo ""


else

echo ""
echo "!!! PERFORMANCE_SCHEMA not enabled. Please enable it first"

fi

else

echo ""
echo "PERFORMANCE_SCHEMA only supported in MySQL 5.5 and higher"
fi

}

#########################################################

if [ -z $1 ]; then

echo "please see help for all options available"
echo "./mysqlmymonlite.sh --help"
echo ""

funct_help

fi

#########################################################


case "$1" in
setup)

funct_setup

;;
--help)

funct_help

;;
check)

whichcheck
funct_check

;;
run)

whichcheck
funct_runmin

;;
mysql)

whichcheck
funct_mysql

;;
vmstat)

whichcheck
funct_vmstat

;;
hwinfo)

whichcheck
funct_cpuinfo

;;
showcreate)

if [[ "$WEBONLY" = [nN] ]]; then
whichcheck
funct_askdbname
funct_showtablescreate
fi

;;
showindex)

if [[ "$WEBONLY" = [nN] ]]; then
whichcheck
funct_askdbname
funct_showtableindexes
fi

;;
vbshowtables)

if [[ "$WEBONLY" = [nN] ]]; then
whichcheck
funct_askdbname
funct_vbshowtables
fi

;;
dblist)

if [[ "$WEBONLY" = [nN] ]]; then
whichcheck
echo "$ALLDATABASES"
fi

;;
mysqlreport)

whichcheck
funct_mysqlreport

;;
mysqlfullreport)

whichcheck
funct_mysqlfullreport

;;
mysqltuner)

whichcheck
funct_mysqltuner

;;
psmem)

whichcheck
funct_psmem

;;
litespeedstats)

whichcheck
funct_litespeedstats

;;
pschema)

if [[ "$WEBONLY" = [nN] ]]; then
whichcheck
funct_reportstart
perfschema
fi

;;
custom)
if [ -f ./incopt.inc ]; then
source "./incopt.inc"
else
echo "incopt.inc file not found in same directory as $0"
echo "make sure you create incopt.inc file in same directory as $0"
fi
;;
esac
exit