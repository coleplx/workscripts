#!/bin/bash
# logsize-fix.sh

LOG_SIZE=$(grep innodb_log_file_size /etc/mysql/my.cnf  | awk '{print $3}' | egrep -o [0-9]+)
NEW_LOG_SIZE=$(echo $LOG_SIZE 10 | awk '{print $1 + $2}')
SITE_PATH=$(cat /etc/nginx/sites/*.conf  |grep 'root /www/' | head -n1 | cut -d'/' -f3)

# Change innodb_log_file_size
sed -i "s/innodb_log_file_size = 50M/innodb_log_file_size = ${NEW_LOG_SIZE}M/" /etc/mysql/my.cnf
sed -i 's/#innodb_log_file_size/innodb_log_file_size/' /etc/mysql/my.cnf
mysql --defaults-file=/etc/mysql/debian.cnf -e 'SET GLOBAL innodb_fast_shutdown = 0;'
systemctl stop mariadb
mv /var/lib/mysql/ib_logfile* /www/$SITE_PATH/private/

# fix the legacy mysql systemd wrapper
systemctl enable mariadb
systemctl start mariadb
