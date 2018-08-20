#! /bin/bash

MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
DIRECTORY_BACKUPS=/backups/archives/dump_bdd

databases=`$MYSQL -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  $MYSQLDUMP --force --opt --databases $db | gzip > "$DIRECTORY_BACKUPS/$db.gz"                                                                                      
done

