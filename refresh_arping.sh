#!/bin/bash

if [ ! -x /sbin/ip ] ; then
        apt-get install iproute -y
fi
if [ ! -x /bin/grep ] ; then
        apt-get install grep -y
fi

GW=`/sbin/ip route list | /bin/grep default | /usr/bin/awk '{print $3}'`
DEV=`/sbin/ip route list | /bin/grep default | /usr/bin/awk '{print $5}'`

if [ ! -x /usr/sbin/arping ] ; then
        apt-get install arping -y
fi

for ip in `/sbin/ip address list $DEV | /bin/grep "inet " | /usr/bin/awk '{print $2}' | /usr/bin/cut -d'/' -f1` ; do
        /usr/sbin/arping -S $ip -c 1 -u -i $DEV $GW &> /dev/null
done
