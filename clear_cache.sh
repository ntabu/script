#!/bin/bash

if [ ! -z $1 ] ; then
        case "$1" in
                -h|--help) echo "Usage ./clear_cache.sh [HOST|URI]"; echo "For example HOST : exemple.com"; echo "For example URI : /accueil"; exit 1 ;;
                *) HOST=$1;;
        esac ;
else
        echo "Usage ./clear_cache.sh [HOST|URI] argument"; echo "For example HOST : exemple.com" ; echo "For example URI : /accueil"; exit 1 ;
fi
if [ $1 == "HOST" ] ; then
        if [ ! -z $2 ] ; then
                ## possibilite d'ajout de plusieurs cache varnish
                echo "ban req.http.host ~ \"$2\"" | nc -q 1 <ip_1> 6082
                echo "ban req.http.host ~ \"$2\"" | nc -q 1 <ip_2> 6082
                echo "$2 cleared"
        else
                echo "Usage ./clear_cache.sh HOST argument" ; echo "For example HOST : exemple.com"; exit 1 ;
        fi
else
        if [ $1 == "URI" ] ; then
                if [ ! -z $2 ] ; then
                        echo "ban.url $2" | nc -q 1 <ip_1> 6082
                        echo "ban.url $2" | nc -q 1 <ip_2> 6082
                        echo "$2 cleared"
                else
                        echo "Usage ./clear_cache.sh URI argument"; echo "For example URI : /accueil" ; exit 1 ;
                fi
        else
                echo "Usage ./clear_cache.sh [HOST|ALL|URI] argument"; echo "For example HOST : exemple.com" ; echo "For example URI : /accueil"; exit 1 ;
        fi
fi
