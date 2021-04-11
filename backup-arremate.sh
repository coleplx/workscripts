#!/bin/bash
# ./backup-arremate.sh
#
# - Backups every 30 minutes
# - Keep the last 5 backups from each day
# - Remove everything older than 7 days

BKPDIR="/home/backups"
DATABASES="teste"

# Check and remove older backups from yesterday (anything exceeding the last 5)
for old in $(ls -1 "$BKPDIR" | grep $(date -d "yesterday" '+%Y-%m-%d') | tail +6); do
  rm -f "$BKPDIR/$old"
done

# Backup databases
for db in $DATABASES; do
  mysqldump -u root $db | gzip > /home/backups/${db}_$(date '+%Y-%m-%d_%H:%M:%S').sql.gz
done

# Check and remove older backups from today (anything exceeding the last 5)
for old in $(ls -1 "$BKPDIR" | grep $(date '+%Y-%m-%d') | tail +6); do
  rm -f "$BKPDIR/$old"
done

# Remove backups from last week
find "$BKPDIR" -mtime +7 -delete
