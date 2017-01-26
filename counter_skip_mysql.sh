#!/bin/bash
log=/var/log/bdd1.log
while true; do
    status=$(mysql --execute="show slave status\G"|grep "Seconds_Behind_Master:"|awk '{print $2}')
    if [ $status == "NULL" ]; then
        mysql --execute="show slave status\G" |  sed -n '/Last_Error:/,/Skip/p' | tee -a $log
        mysql --execute="stop slave; set global sql_slave_skip_counter=1; start slave;"
    fi
done

