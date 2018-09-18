--------------------------------------------------------------------------------------------------------------
What is mysqlmymonlite.sh  ? 
--------------------------------------------------------------------------------------------------------------
* http://mysqlmymon.com

mysqlmymonlite.sh is lite version of extensive featured mysqlmymon.sh - MySQL 
and system monitoring script written by George Liu (eva2000) vbtechsupport.com 
for quick stats check for apache, nginx and mysql stats for CentOS WHM/Cpanel,
CentOS and Debian 6.x systems. 

mysqlmymon.sh is the big brother script to mysqlmymonlite.sh which is much more
feature extensive and used for my private paid consults I do - it produces alot more 
detailed info for stats analysis but alot of the info is not suited to sharing in public.
So I stripped down mysqlmymon.sh to create mysqlmymonlite.sh with aim of 
providing as much stats output as possible without revealing any private server 
sensitive information as possible. 

Thus mysqlmymonlite.sh was born and is used mainly for vBulletin server 
optimisation requests on public forums providing nginx, apache, mysql, cpu, memory,
disk usage stats and general overview of server status in order to understand a 
vB client's server environment and loads. All this info takes less than <12 seconds 
to gather once the script is run.
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
How to use ?
--------------------------------------------------------------------------------------------------------------

1. Download zip file which contains all 3 versions of the 
script for either:

    a). CentOS or
    b). CentOS WHM/Cpanel or
    c). Debian 6.x systems 

--------------------------------------------------------------------------------------------------------------
2. Pick the appropriate folder's version of the script depending on your flavour of 
Linux - either CentOS version, CentOS WHM/Cpanel version or Debian 6.x version.

Edit mysqlmymonlite.sh variables. There's 2 ways of doing this as of v0.4.0 onwards.

1. Use and upload to your server the config.ini. This optional separate config.ini, you can use to define all variables needed to setup mysqlmymonlite.sh. This makes upgrading mysqlmymonlite.sh easier (if there's no config.ini changes), as you can just overwrite old mysqlmymonlite.sh with new version without having to re-setup your settings as they would be in config.ini. Place config.ini in same directory that mysqlmymonlite.sh is located.

2. Second method is to not upload config.ini (delete it from the directory in which mysqlmymonlite.sh is), and just edit the mysqlmymonlite.sh settings within the file

    MYCNF='/etc/my.cnf'
    USER='mysqlrootuser'
    PASS='yourmysqlrootpassword'

change USER to your mysql root user name and 
PASS to mysql root user's password

optional change

    MASKDB='y'

to

    MASKDB='n'

to unhide actual database names from output, if you post on public forums
you can leave at MASKDB='y'

optional change

   By default PER TABLE DATABASE details is disabled as of v0.3.1 to reduce total 
   text output. You can re-enable per table out put by setting 

   SHOWPERTABLE='n'

to

   SHOWPERTABLE='y'

--------------------------------------------------------------------------------------------------------------
3. Upload to web server as ASCII file and as root user in 
SSH2 telnet go to directory you placed mysqlmymonlite.sh

i.e.  if mysqlmymonlite.sh was placed at /root/mysqlmymonlite.sh

type the following in SSH2 telnet as root user:

    cd /root
    chmod +x mysqlmymonlite.sh

run it

    cd /root
    ./mysqlmymonlite.sh run 2>/dev/null > mysqlmymonlite_stats.txt

or

    cd /root
    bash mysqlmymonlite.sh run 2>/dev/null > mysqlmymonlite_stats.txt

or to specify a different directory for txt file output

    cd /root
    ./mysqlmymonlite.sh run 2>/dev/null > /home/username/mysqlmymonstats/mysqlmymonlite_stats.txt

or

    cd /root
    bash mysqlmymonlite.sh run 2>/dev/null > /home/username/mysqlmymonstats/mysqlmymonlite_stats.txt

You'll end up with a text file at /root/mysqlmymonlite_stats.txt if you changed 
to /root directory above or if you specified a different directory for saving to it would
be at /home/username/mysqlmymonstats/mysqlmymonlite_stats.txt

Of course /home/username/mysqlmymonstats directory needs to exist before hand.

--------------------------------------------------------------------------------------------------------------
4. Optional usage methods including 

    a). cron job email sending of stats or 
    b). saving a timestamped text file of stats every hour etc

You can also run mysqlmymonlite.sh as a cron job emailing you stats every hour or
whatever interval you set the cron job to. You may want to setup email filter to properly
label and organise emailed stats for your server.

Example usage where emailaddress is your email address you want to set:

for using mail command send stats every hour:

 0 * * * * /root/mysqlmymonlite.sh run 2>/dev/null | mail -s "`hostname` Monitoring Stats: `date`" emailaddress

for using mutt send stats every hour:

 0 * * * * /root/mysqlmymonlite.sh run 2>/dev/null | mutt -s "`hostname` Monitoring Stats: `date`" emailaddress

Or save to timestamped text file every hour to directory at /home/username/mysqlmymonstats

 0 * * * * /root/mysqlmymonlite.sh run 2>/dev/null > /home/username/mysqlmymonstats/stats_mysqlmymonlite_`date +"\%d\%m\%y-\%H\%M\%S"`.txt

Of course /home/username/mysqlmymonstats directory needs to exist before hand.

--------------------------------------------------------------------------------------------------------------
5. EXCLUDEDB option
This option reduces the amount of output text by excluding database names from the PER TABLE output for each database name. Usually for vB optimisation requests, I prefer all database tables for entire server to be viewable but for servers with many non-vB database names, it can be a lengthy list so you can reduce that output via EXCLUDEDB option in mysqlmymonlite.sh script.

By default 3 databases are excluded from PER TABLE display:

1. test 
2. information_schema 
3. mysql

For WHM/Cpanel mysqlmymonlite.sh additional database names have been added to EXCLUDEDB list

1. cphulkd 
2. eximstats 
3. horde 
4. leechprotect 
5. roundcube

To add additional databases to be excluded, edit your EXCLUDEDB option and add the additional database names separated by a single space. Not sure what all your database names are ? Don't worry mysqlmymonlite.sh can easily output the entire list by dblist option

run in ssh2 telnet the script with dblist option

	./mysqlmymonlite.sh dblist

you'll get a list of single space separated database names located on your server to add to EXCLUDEDB list. Just remove your vBulletin database names from the EXCLUDEDB list, so I can see PER TABLE output for vBulletin database names.

There's only one downside, is that if other non-vBulletin database tables are InnoDB storage engine based, I wouldn't be able to see which tables are if that non-vBulletin database is added to EXCLUDEDB list.

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
EXCLUDEDB="test information_schema mysql"

--------------------------------------------------------------------------------------------------------------
6. Custom command option

Added in mysqlmymonlite.sh v0.3.8, allows you to add your own custom SSH bash shell commands to be outputted when you run custom option: 

	./mysqlmymonlite.sh custom

This option allows you to create a separate includes file name it incopt.inc and place it in same direct mysqlmymonlite.sh is located in. You can add your own custom SSH bash shell commands to this incopt.inc file to further extend mysqlmymonlite.sh's functionality and usefulness. 

example #1 if you want to add iostats output to mysqlmymonlite.sh

---------
step 1. 
create incopt.inc file in same directory as mysqlmymonlite.sh
---------
step 2. 
---------
edit incopt.inc and add the iostats command, you may need to know a bit about bash shell scripting if you want to format the output properly. In this example, i added to incopt.inc 3 lines of code to first new line space with empty echo, the echo the command line i want to run (title), and then the actual command you would normally run in SSH telnet.

	echo ""
	echo "iostat -x 10 5"
	iostat -x 10 5
---------
step 3. 
---------
run the custom command

	./mysqlmymonlite.sh custom

output would be as follows:

iostat -x 10 5
Linux 2.6.32-220.7.1.el6.x86_64  05/08/2012      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.14    0.00    0.14    0.03    0.00   99.69

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.08     1.98    0.21    0.37     8.09    18.42    46.01     0.01   12.47   1.67   0.10
scd0              0.00     0.00    0.00    0.00     0.00     0.00     8.00     0.00    0.43   0.43   0.00
dm-0              0.00     0.00    0.28    2.31     8.03    18.42    10.22     0.47  181.06   0.37   0.10
dm-1              0.00     0.00    0.00    0.00     0.02     0.00     8.00     0.00    2.73   1.66   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.00    0.00    0.00    0.00    0.00  100.00

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.70    0.10    0.30     1.60     7.20    22.00     0.00    1.75   1.75   0.07
scd0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-0              0.00     0.00    0.00    0.90     0.00     7.20     8.00     0.00    0.11   0.11   0.01
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.00    0.00    0.00    0.00    0.00  100.00

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
scd0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.00    0.00    0.00    0.00    0.00  100.00

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
scd0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.05    0.00    0.10    0.00    0.00   99.85

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.10    0.00    0.60     0.00     5.60     9.33     0.00    0.67   0.17   0.01
scd0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
dm-0              0.00     0.00    0.00    0.70     0.00     5.60     8.00     0.00    0.71   0.14   0.01
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00