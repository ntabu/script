#!/bin/bash

SQL="SELECT CONCAT(table_schema,'.',table_name) FROM information_schema.tables WHERE"
SQL="${SQL} table_schema NOT IN ('information_schema','mysql','performance_schema')"
for DBTB in `mysql -ANe"${SQL}"`
do
    echo ALTER TABLE "${DBTB};"
    SQL="ALTER TABLE ${DBTB} ENGINE=InnoDB;"
    mysql -ANe"${SQL}"
done
