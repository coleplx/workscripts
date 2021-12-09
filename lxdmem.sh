#!/bin/bash
# lxdmem.sh
#
# Paulo H. Paracatu - paulo {at} cole.tec.br

# Get system stats only once
MEMINFO=$(cat /proc/meminfo)
ARC_SUMMARY=$(arc_summary -s arc)
ARC_HITS=$(arc_summary -s archits)
OS_USERS=$(for i in $(cat /etc/passwd | cut -d':' -f1); do echo $i; done | sed -e ':a;N;$!ba;s/\n/|/g')
# This is 15~25x faster than "lxc list --fast | grep RUNNING"
RUNNING_CONTAINERS=$(ps aux | grep 'lxc monito[r]' | rev | cut -d' ' -f1 | rev)
MEMORY_PER_CONTAINER=$(for container in $RUNNING_CONTAINERS; do  MEM_IN_BYTES=$(cat /sys/fs/cgroup/memory/lxc.payload.${container}/memory.usage_in_bytes); echo $MEM_IN_BYTES $container; done)

# Available memory
MEMFREE=$(echo "$MEMINFO" | grep MemFree | awk '{print $2 / 1024 / 1024}')
MEMAVAILABLE=$(echo "$MEMINFO" | grep MemAvailable | awk '{print $2 / 1024 / 1024}')

# Memory usage at the moment
ARC_USAGE=$(echo "$ARC_SUMMARY" | grep '^ARC size' | awk '{print $6 " " $7}')
ARC_MAXSIZE=$(echo "$ARC_SUMMARY" | grep 'Max size (high water):' | awk '{print $6 " " $7}')
ARC_HIT=$(echo "$ARC_HITS"  | grep 'Actual hit ratio' | awk '{print $8 $9 }')
if [ "$(echo $ARC_USAGE | grep -o GiB)" == "GiB" ]; then
  ARC_USAGE=$(echo $ARC_USAGE | cut -d' ' -f1)
elif [ "$(echo $ARC_USAGE | grep -o MiB)" == "MiB" ]; then
  ARC_USAGE=$(echo $ARC_USAGE | cut -d' ' -f1 | awk '{print $1 / 1024}')
else
  # Not worth to calculate if less than 1 MiB, really...
  ARC_USAGE=0
fi
CONTAINERS_USAGE=$(echo "$MEMORY_PER_CONTAINER" | awk '{s+=$1} END {print s / 1024 / 1024 / 1024}')
CONTAINER_TOP_MEM_USAGE=$(echo "$MEMORY_PER_CONTAINER" | sort -nr | head -n5 | awk '{print $2 " " $1 / 1024 / 1024 /1024 " GiB"}')
LXD_USERS_MEM_USAGE=$(ps -axo size,pid,user,command --sort -size | awk '{print $3 " " $0}' | egrep "^($OS_USERS)" | awk '{ hr=$2/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |    cut -d "" -f2 | cut -d "-" -f1  | head  -n 20 | awk '{print $1}' | awk '{s+=$1} END {print s / 1024}' | awk '{s+=$1} END {print s}')

# Max memory limits
MEMTOTAL=$(echo "$MEMINFO" | grep MemTotal | awk '{print $2 / 1024 / 1024}')
ARC_SIZE=$(echo "$ARC_SUMMARY" | grep 'Max size' | awk '{print $6 " " $7}')

# Linux Used Memory
MEMCACHED=$(echo "$MEMINFO" | grep ^Cached: | awk '{print $2 / 1024 / 1024}')
MEMBUFFER=$(echo "$MEMINFO" | grep ^Buffers: | awk '{print $2 / 1024 / 1024}')
MEMSLAB=$(echo "$MEMINFO" | grep ^Slab: | awk '{print $2 / 1024 / 1024}')

# Process info
RUNNING_PC=$(ps ax --no-headers -o "rss,cmd")
MYSQL_MEM="0"
NGINX_MEM="0"
REDIS_MEM="0"
PHPFPM_MEM="0"
PHPCLI_MEM="0"
FILEBEAT_MEM="0"
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'mariadb|mysql')" ]; then
  MYSQL_MEM=$(echo "$RUNNING_PC" | egrep "mariadb|mysql" | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'nginx')" ]; then
  NGINX_MEM=$(echo "$RUNNING_PC" | grep nginx | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'redis-server')" ]; then
  REDIS_MEM=$(echo "$RUNNING_PC" | grep redis-server | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'php-fpm')" ]; then
  PHPFPM_MEM=$(echo "$RUNNING_PC" | grep php-fpm | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'filebeat')" ]; then
  FILEBEAT_MEM=$(echo "$RUNNING_PC" | grep filebeat | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi
if [ -n "$(echo "$RUNNING_PC" | egrep -o 'php ')" ]; then
  PHPCLI_MEM=$(echo "$RUNNING_PC" | grep 'php ' | awk '{sum+=$1;}END{print sum/1024/1024;}')
fi

# Sum all known memory usage
TOTAL_KNOWN_MEMORY_USAGE=$(echo $ARC_USAGE $CONTAINERS_USAGE $LXD_USERS_MEM_USAGE $MEMBUFFER $MEMCACHED $MEMSLAB | awk '{print $1 + $2 + $3 + $4 + $5}')

echo ""
echo "------ System Info ------"
echo "Total memory:             $MEMTOTAL GiB"
echo "Free memory:              $MEMFREE GiB"
echo "Available memory:         $MEMAVAILABLE GiB"
echo "Total Known Memory Usage: $TOTAL_KNOWN_MEMORY_USAGE GiB"
echo ""
echo "------ Details ------"
echo "ARC Memory Usage:                                    $ARC_USAGE GiB ($ARC_MAXSIZE MAX)"
echo "ARC Cache Efficiency:                                $ARC_HIT"
echo "Containers Memory Usage:                             $CONTAINERS_USAGE GiB"
echo "OS Users Memory Usage:                               $LXD_USERS_MEM_USAGE GiB"
echo "OS Buffers (temporary storage for raw disk blocks):  $MEMBUFFER GiB"
echo "OS Page Cache:                                       $MEMCACHED GiB"
echo "Slabs (In-kernel data structures cache):             $MEMSLAB GiB"
echo ""
echo "------ Memory Usage per Common Process (All containers) ------"
echo "PHP:      $PHPFPM_MEM GiB"
echo "PHP CLI:  $PHPCLI_MEM GiB"
echo "MySQL:    $MYSQL_MEM GiB"
echo "NGINX:    $NGINX_MEM GiB"
echo "Filebeat: $FILEBEAT_MEM GiB"
echo "Redis:    $REDIS_MEM GiB"
echo ""
echo "Containers using most memory (GiB):"
echo "$(echo "$CONTAINER_TOP_MEM_USAGE"  | column -t)"
echo ""
