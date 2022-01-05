#!/bin/bash
# ./lxcmigration.sh
RUNNING_CONTAINERS=$(ps aux | grep 'lxc monito[r]' | rev | cut -d' ' -f1 | rev)
DISK_USAGE=$(zfs list)

for container in $(echo "$RUNNING_CONTAINERS" | grep -v '\-staging\-'); do
  CONTAINER_DISK=$(echo "$DISK_USAGE" | grep $container | awk '{print $2}')
  # If disk usage is less than 1gb, we can consider it = 0 (easier to calculate)
  if [ $(echo $CONTAINER_DISK | egrep "(M|K)") ]; then
    CONTAINER_DISK=0
  else
    CONTAINER_DISK=$(echo "$CONTAINER_DISK" | egrep -o [0-9.]+ | cut -d'.' -f1)
  fi

  if [ $CONTAINER_DISK -lt 7 ]; then
    CONTAINER_MEMORY=$(cat /sys/fs/cgroup/memory/lxc.payload.${container}/memory.usage_in_bytes | awk '{print $1 / 1024 / 1024 / 1024}')
    echo $container $CONTAINER_MEMORY
  fi
done | sort -nr -k2 | head -n 10
