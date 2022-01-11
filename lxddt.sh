#!/bin/bash
# ./lxddt.sh

MAX_RUNNING_LXC=$(grep LXD_META_NUMBER_OF_RUNNING_CONTAINERS /var/log/syslog{.1,} | tail -1 | rev | cut -d' ' -f1 | rev)
CURRENT_RUNNING_LXC=$(ps aux | grep '[l]xc monitor' | wc -l)


LAST_LIVE_CONTAINER_NAME=$(cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep -v '\-staging\-' | tail -n1 | grep -o instance=.* | cut -d'=' -f2 | cut -d' ' -f1)
LAST_LIVE_CONTAINER_TIME=$(cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep "$LAST_LIVE_CONTAINER_NAME" | tail -n1 | cut -d' ' -f1 | egrep -o '[0-9]+:[0-9]+')

echo ""
echo "Time now: $(date '+%H:%M') UTC"
echo ""
echo "Running / Max"
echo "    $CURRENT_RUNNING_LXC / $MAX_RUNNING_LXC"
echo ""
echo "Last live container started:
$LAST_LIVE_CONTAINER_NAME @ $LAST_LIVE_CONTAINER_TIME UTC"
echo ""
