#!/bin/bash
# lxdmem.sh
#
# Paulo H. Paracatu - paulo {at} cole.tec.br

# Available memory
MEMFREE=$(cat /proc/meminfo | grep MemFree | awk '{print $2 / 1024 / 1024}')
MEMAVAILABLE=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2 / 1024 / 1024}')

# Memory usage at the moment
ARC_USAGE=$(arc_summary -s arc | grep '^ARC size' | awk '{print $6 " " $7}')
if [ "$(echo $ARC_USAGE | grep -o GiB)" == "GiB" ]; then
  ARC_USAGE=$(echo $ARC_USAGE | cut -d' ' -f1)
elif [ "$(echo $ARC_USAGE | grep -o MiB)" == "MiB" ]; then
  ARC_USAGE=$(echo $ARC_USAGE | cut -d' ' -f1 | awk '{print $1 / 1024}')
else
  # Not worth to calculate if less than 1 MiB, really...
  ARC_USAGE=0
fi
CONTAINERS_USAGE=$(lxc list --format=json | jq  '.[] | "\(.name) \(.status) \(.state.memory.usage)"' | tr -d "\"" | grep -v Stopped | cut -d' ' -f3 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024}')
CONTAINER_TOP_MEM_USAGE=$(lxc list --format=json | jq  '.[] | "\(.name) \(.status) \(.state.memory.usage)"' | tr -d "\"" | grep -v Stopped | awk '{print $3 " " $0}' | sort -r | head -n5 | awk '{print $2 " " $4 / 1024 / 1024 / 1024}')
LXD_USERS_MEM_USAGE=$(for i in $(cat /etc/passwd | cut -d':' -f1); do ps -o size,pid,user,command --sort -size -u $i | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |    cut -d "" -f2 | cut -d "-" -f1  | head  -n 20 | awk '{print $1}' | awk '{s+=$1} END {print s / 1024}'; done | awk '{s+=$1} END {print s}')


# Max memory limits
MEMTOTAL=$(cat /proc/meminfo | grep MemTotal | awk '{print $2 / 1024 / 1024}')
ARC_SIZE=$(arc_summary -s arc | grep 'Max size' | awk '{print $6 " " $7}')

# Linux Used Memory
MEMBUFCACHE=$(free -k | grep Mem: | awk '{print $6 / 1024 / 1024}')
MEMUSED=$(free -k | grep Mem: | awk '{print $3 / 1024 /1024}')


# Sum all known memory usage
TOTAL_KNOWN_MEMORY_USAGE=$(echo $ARC_USAGE $CONTAINERS_USAGE $LXD_USERS_MEM_USAGE $MEMBUFCACHE | awk '{print $1 + $2 + $3 + $4}')

echo ""
echo "------ System Info ------ "
echo "Total memory:             $MEMTOTAL GiB"
echo "Free memory:              $MEMFREE GiB"
echo "Available memory:         $MEMAVAILABLE GiB"
echo "Used memory:              $MEMUSED"
echo ""
echo "------ Details ------ "
echo "ARC Memory Usage:         $ARC_USAGE GiB"
echo "Containers Memory Usage:  $CONTAINERS_USAGE GiB"
echo "OS Users Memory Usage:    $LXD_USERS_MEM_USAGE GiB"
echo "OS Buffers/Caches:        $MEMBUFCACHE GiB"
echo "                         ---------------------"
echo "Total Known Memory Usage (Caches included): $TOTAL_KNOWN_MEMORY_USAGE GiB"
echo ""
echo "Containers using most memory: "
echo "$(echo "$CONTAINER_TOP_MEM_USAGE"  | column -t)"
echo ""
