#! /bin/bash

OUTDIR=`date +%Y-%m-%d`
mkdir -p /var/www/dump_sql/$OUTDIR
DATABASES=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v -e Database -e _schema -e mysql`
for DB_NAME in $DATABASES; do
    mysqldump --single-transaction $DB_NAME  > /var/www/dump_sql/$OUTDIR/$DB_NAME.sql
done
