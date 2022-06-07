#!/usr/bin/env bash

auth="<password>"
purgeban="BAN"
purgeuri="/*"
host="<hostname>"
uri="<uri>"

init() {
  FRONT_LIST=('<ip_hostname1>' '<ip_hostname2>')
  URI_LIST=('<uri1>' '<uri2>' '<uri3>')
}

main() {
  init

  for front in "${FRONT_LIST[@]}"; do
    echo $front
         ssh -t tma_www@$front "cachetool opcache:reset --fcgi=/var/run/php-drupal.sock"
  done

  for purge in "${URI_LIST[@]}"; do
    echo $purge
        curl \
        -H "x-purge-method: ${purgeban}" \
        -H "x-purge-auth: ${auth}" \
        -H "x-purge-host: $purge" \
        -H "x-purge-uri: ${purgeuri}" \
        -H "Host: ${host}" \
        http://${uri}
 done
}

main "@"
