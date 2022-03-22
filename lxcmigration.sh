#!/bin/bash
# ./lxcmigration.sh
# v0.1 - Initial Version
# v0.2 - Fix problem with small containers (<1gb) being excluded from the listing
# v0.3 - Drop zfs list in favor of /kinsta/main.conf
# v0.4 - Use readarray to avoid "column: line too long" error
# v1.0 - Check staging disk usage too, exclude site if staging usage is bigger than 7 GiB
# v1.1 - Set disk = 0 when variable is empty
# v1.2 - Dropped lxc exc in favor of nsenter
# v1.3 - Two optional arguments: SIZE and SHOW. Size defines the maximum container size we accept to migrate, SHOW defines the number of containers listed
#

RUNNING_CONTAINERS=$(ps aux | grep 'lxc monito[r]' | rev | cut -d' ' -f1 | rev)

GET_OPTS=$(getopt -o '' --long size:,show: -n 'finish' -- "$@")

if [ $? != 0 ]; then echo "Failed to parse options... exiting." >&2 ; exit 1 ; fi

eval set -- "$GET_OPTS"

# Extract options and their arguments into variables.
while true ; do
    case "$1" in
        --size)
          DISK_LIMIT=$(echo $2 | awk '{print $1 * 1024 * 1024 * 1024 }')
          shift 2
          ;;
        --show)
          LIST_SIZE=$(echo $2 | awk '{print $1 + 1}') # +1 to account for the header
          shift 2
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Invalid option!"
          exit 1
          ;;
    esac
done

if [ -z $DISK_LIMIT ]; then
  DISK_LIMIT=7516192768 # 7 GiB
fi

if [ -z $LIST_SIZE ]; then
  LIST_SIZE=200
fi


container_list=$(for container in $(echo "$RUNNING_CONTAINERS" | grep -v '\-staging\-' ); do
  SITE_NAME=$(echo $container | cut -d'-' -f2)
  # Check if there is a staging running
  STAGING_NAME=$(echo "$RUNNING_CONTAINERS" | grep "\-staging\-$SITE_NAME")
  if [ $? == 0 ]; then
    STAGING_RUNNING=1
    # Access the LXD mount namespace to get the value of disk_usage_full
    STAGING_DISK=$(nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$STAGING_NAME/rootfs/kinsta/main.conf | grep ^disk_usage_full | cut -d'=' -f2)
    if [ "$STAGING_DISK" == "" ]; then 
      STAGING_DISK=0; 
    fi
    STAGING_DISK_GIB=$(echo "$STAGING_DISK" | awk '{printf "%0.2f", $1 / 1024 / 1024 /1024}')
  else
   STAGING_RUNNING=0
  fi

  CONTAINER_DISK=$(nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$container/rootfs/kinsta/main.conf | grep ^disk_usage_full | cut -d'=' -f2)
  if [ "$CONTAINER_DISK" == "" ]; then CONTAINER_DISK=0; fi
  CONTAINER_DISK_GIB=$(echo "$CONTAINER_DISK" | awk '{printf "%0.2f", $1 / 1024 / 1024 /1024}')

  if [ $CONTAINER_DISK -lt $DISK_LIMIT ]; then
    CONTAINER_MEMORY=$(cat /sys/fs/cgroup/memory/lxc.payload.${container}/memory.usage_in_bytes | awk '{print $1 / 1024 / 1024 / 1024}')
    if [ $STAGING_RUNNING == 1 ]; then
      if [ $STAGING_DISK -lt $DISK_LIMIT ]; then
        echo "$container $CONTAINER_MEMORY $CONTAINER_DISK_GIB $STAGING_DISK_GIB"
      fi
    else
      echo "$container $CONTAINER_MEMORY $CONTAINER_DISK_GIB"
    fi
  fi
done | sort -nr -k2 )

readarray -t ARR < <(printf "CONTAINER 'MEMORY' 'LIVE-Disk-GiB' 'STAGING-Disk-GiB' \n$container_list")
printf '%s\n' "${ARR[@]}" | column  -t | head -n $LIST_SIZE
