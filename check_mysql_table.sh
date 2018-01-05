#!/bin/bash
#

PATH=/usr/local/bin:/usr/bin:/bin:$PATH
DBHOST=localhost
LOGFILE=/var/log/mysqlcheck.log
TYPE1=
TYPE2=
CORRUPT=no
DBNAMES="all"
DBEXCLUDE=""

touch $LOGFILE
exec 6>&1
exec > $LOGFILE
echo -n "Check Table MySQL: "
date
echo "---------------------------------------------------------"; echo; echo

if test $DBNAMES = "all" ; then
DBNAMES="`mysql --batch -N -e "show databases"`"
for i in $DBEXCLUDE
do
DBNAMES=`echo $DBNAMES | sed "s/\b$i\b//g"`
done
fi

for i in $DBNAMES
do
echo "Database check:"
echo -n "SHOW DATABASES LIKE '$i'" | mysql -t $i; echo

DBTABLES="`mysql $i --batch -N -e "show table status;" | gawk 'BEGIN {ORS=", " } $2 == "MyISAM" || $2 == "InnoDB"{print "\`" $1 "\`"}' | sed 's/, $//'`"

if [ ! "$DBTABLES" ]
then
echo "no tables $i database ..."; echo; echo
else
echo "CHECK TABLE $DBTABLES $TYPE1 $TYPE2" | mysql $i; echo; echo
fi
done
1>&6 6>&-

for i in `cat $LOGFILE`
do
if test $i = "warning" ; then
CORRUPT=yes
elif test $i = "error" ; then
CORRUPT=yes
fi
done
