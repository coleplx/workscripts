#!/bin/bash
# logsize-fix.sh

LOG_SIZE=$(grep innodb_log_file_size /etc/mysql/my.cnf  | awk '{print $3}' | egrep -o [0-9]+)
NEW_LOG_SIZE=$(echo $LOG_SIZE 10 | awk '{print $1 + $2}')
SITE_PATH=$(cat /etc/nginx/sites/*.conf  |grep 'root /www/' | head -n1 | cut -d'/' -f3)

# Change innodb_log_file_size
sed -i "s/innodb_log_file_size.*/innodb_log_file_size = ${NEW_LOG_SIZE}M/g" /etc/mysql/my.cnf
sed -i 's/#innodb_log_file_size/innodb_log_file_size/g' /etc/mysql/my.cnf
mysql --defaults-file=/etc/mysql/debian.cnf -e 'SET GLOBAL innodb_fast_shutdown = 0;'

# Make sure mysql isn't running
systemctl stop mariadb mysql
kill -9 $(pgrep -f mysql); kill -9 $(pgrep -f mariadb)

# Backup the ib_logfile
mv /var/lib/mysql/ib_logfile* /www/$SITE_PATH/private/

# fix the legacy mysql systemd wrapper and start mysql again
systemctl disable mysql
systemctl enable mariadb
systemctl start mariadb
