#!/bin/bash
# debug-server.sh
#
#
#

# Check if mysql is running
if ! pgrep mysqld > /dev/null; then
  echo "MySQL is NOT running!"
  echo "=================================="
fi

# Check if mysql was killed by oom-killer
MYSQL_OOM=$(cat /var/log/syslog /var/log/syslog.1 | grep oom | grep mysql | wc -l)
if $MYSQL_OOM > 0; then
  echo "MEMORY STARVATION: MySQL was killed $MYSQL_OOM times by OOM-KILLER."
  echo "Advice: Check if the apps are using any cache mechanism."
  echo "Using CDN and disabling PageSpeed may help reduce memory usage."
  if $MYSQL_OOM > 5; then
    echo "MySQL was killed more then 5 times recently."
    echo "UPGRADE RECOMMENDED"
  fi
  echo "=================================="
fi

# Check if PHP is starving
if cez --psphp | grep "$(date +%Y-%m)" > /dev/null; then
  echo "PHP STARVATION: At least one site needed more resources this month (app profile)."
  echo "Advice: Run command \"cez --psphp\" and manually check for RECENT alerts."
  echo "=================================="
fi

# Check for common hacked cron
if cat /var/log/syslog /var/log/syslog.1 | grep CRON | grep -i apikey > /dev/null; then
  echo "URGENT: I found at least one CRON with known dangerous fake-plugin 'apikey' running!"
  echo "Log samples: "
  cat /var/log/syslog /var/log/syslog.1 | grep CRON | grep -i apikey
  echo "=================================="
fi
