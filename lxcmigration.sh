#!/bin/bash
# ./lxcmigration.sh
# v0.1 - Initial Version
# v0.2 - Fix problem with small containers (<1gb) being excluded from the listing
# v0.3 - Drop zfs list in favor of /kinsta/main.conf
# v0.4 - Use readarray to avoid "column: line too long" error
# v1.0 - Check staging disk usage too, exclude site if staging usage is bigger than 7 GiB
#
RUNNING_CONTAINERS=$(ps aux | grep 'lxc monito[r]' | rev | cut -d' ' -f1 | rev)


cont_list=$(for container in $(echo "$RUNNING_CONTAINERS" | grep -v '\-staging\-' ); do
  SITE_NAME=$(echo $container | cut -d'-' -f2)
  # Check if there is a staging running
  STAGING_NAME=$(echo "$RUNNING_CONTAINERS" | grep "\-staging\-$SITE_NAME")
  if [ $? == 0 ]; then
    STAGING_RUNNING=1
    STAGING_DISK=$(lxc exec $STAGING_NAME -- cat /kinsta/main.conf | grep ^disk_usage_full | cut -d'=' -f2)
    STAGING_DISK_GIB=$(echo "$STAGING_DISK" | awk '{printf "%0.2f", $1 / 1024 / 1024 /1024}')
  else
   STAGING_RUNNING=0
  fi

  CONTAINER_DISK=$(lxc exec $container -- cat /kinsta/main.conf | grep ^disk_usage_full | cut -d'=' -f2)
  CONTAINER_DISK_GIB=$(echo "$CONTAINER_DISK" | awk '{printf "%0.2f", $1 / 1024 / 1024 /1024}')

  # 7516192768 bytes = 7 GiB
  if [ $CONTAINER_DISK -lt 7516192768 ]; then
    CONTAINER_MEMORY=$(cat /sys/fs/cgroup/memory/lxc.payload.${container}/memory.usage_in_bytes | awk '{print $1 / 1024 / 1024 / 1024}')
    if [ $STAGING_RUNNING == 1 ]; then
      if [ $STAGING_DISK -lt 7516192768 ]; then
        echo "$container $CONTAINER_MEMORY $CONTAINER_DISK_GIB $STAGING_DISK_GIB"
      fi
    else
      echo "$container $CONTAINER_MEMORY $CONTAINER_DISK_GIB"
    fi
  fi
done | sort -nr -k2 )

readarray -t ARR < <(printf "CONTAINER 'MEMORY' 'LIVE-Disk-GiB' 'STAGING-Disk-GiB' \n$cont_list")
printf '%s\n' "${ARR[@]}" | column  -t
