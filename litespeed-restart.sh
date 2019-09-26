#!/usr/bin/env bash

declare -i throttle_by=5

@debounce() {
  if [[ ! -f /tmp/lsws-executing ]]
  then
    touch /tmp/lsws-executing
    "$@"
    retVal=$?
    echo "Primeiro retval: $retVal"
    {
      sleep $throttle_by
      if [[ -f /tmp/lsws-on-finish ]]
      then
        "$@"
        rm -f tmp/lsws-on-finish
      fi
      rm -f /tmp/lsws-executing
    } &
    return $retVal
  elif [[ ! -f /tmp/lsws-on-finish ]]
  then
    touch /tmp/lsws-on-finish
  fi
}


# will execute not more than once per $throttle_by seconds
@debounce /usr/local/lsws/bin/lswsctrl restart
wait $(jobs -p) # need to wait for the bg jobs to complete
