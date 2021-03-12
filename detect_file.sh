#!/bin/bash
 
file=$(find /etc/ssl/ -mindepth 1 -maxdepth 1 -name "my_certif.pem" -mmin -60)
 
if [ -n "$file" ] ; then
        echo "OK"
else
        echo "KO"
fi
