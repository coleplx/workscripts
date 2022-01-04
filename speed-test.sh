#!/bin/bash
# test-worker-speed.sh
#
# v0.1

CACHE_BUSTER="?$(uuidgen)"

TEMP=$(getopt -o '' --long type:,format:,file: -n 'finish' -- "$@")

if [ $? != 0 ]; then echo "Missing/invalid arguments... exiting." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        --type)
          TEST_TYPE=$2
          shift 2
          ;;
        --format)
          OUTPUT_FORMAT=$2
          shift 2
          ;;
        --file)
          FILE=$(cat $2)
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

# We should have a bunch of URLs to test if no url list is provided (--file=)
if [ -z "$FILE" ]; then
  PAGE_LIST="https://testkinsta32.kinsta.cloud/"
  IMAGE_LIST="https://testkinsta32.kinsta.cloud/wp-content/uploads/2021/12/db265add-3f1c-3e4e-9ea9-1e0ae139444e.jpg$CACHE_BUSTER
  https://testkinsta32.kinsta.cloud/wp-content/uploads/2021/12/126c0a33-34cf-3c02-8b60-0350e4e1367f.jpg$CACHE_BUSTER"
  SCRIPT_LIST="https://testkinsta32.kinsta.cloud/wp-content/themes/twentytwentyone/style.css$CACHE_BUSTER"
fi

# This sets "page" as the default test type if not provided (--type=)
if [ -z "$TEST_TYPE" ]; then
  TEST_TYPE="page"
fi

# Select the appropriate list of URLs to test
case $TEST_TYPE in
  image)
    SITE_LIST="$IMAGE_LIST"
    ;;
  script)
    SITE_LIST="$SCRIPT_LIST"
    ;;
  page)
    SITE_LIST="$PAGE_LIST"
    ;;
esac


# Default output is csv. The "pretty" format is also available for manual testing
if [ -z "$OUTPUT_FORMAT" ]; then
  OUTPUT_FORMAT=csv
fi

TOTAL_REQUEST_TIME=0
TOTAL_REQUEST_TIME_CACHED=0
NUMBER_OF_REQUESTS=0
NUMBER_OF_CACHED_REQUESTS=0
TOTAL_TTFB=0
TOTAL_TTFB_CACHED=0
cached_count=0
worker_count=0

if [ "$OUTPUT_FORMAT" == "pretty" ]; then
  echo "- Test type: $TEST_TYPE"
  echo "- URLs: $SITE_LIST"
fi
for url in $(echo "$SITE_LIST"); do
  # egrep workaround to remove special characters (tab, newline, etc)
  WORKER_VERSION=$(curl -s -I https://testkinsta32.kinsta.cloud/ | egrep "ki-edge" | cut -d'=' -f2 | egrep -o "[0-9a-zA-Z.]+")
  if [ "$worker_count" == "0" ]; then
    LAST_WORKER_VERSION=$WORKER_VERSION
    worker_count=1
  elif [ "$WORKER_VERSION" != "$LAST_WORKER_VERSION" ]; then
    echo "Worker version mismatch detected. Please run the test using the same worker version on all URLs"
    exit 1
  fi

  if [ "$OUTPUT_FORMAT" == "pretty" ]; then
    echo "-- Test URL: $url"
    echo "--- Worker version: $WORKER_VERSION"
  fi

  for i in {1..10}; do
    NUMBER_OF_REQUESTS=$(echo $NUMBER_OF_REQUESTS 1 | awk '{print $1 + $2}')
    # We can use curl to calculate the approximate TTFB
    # DNS lookup: %{time_namelookup}
    # TLS handshake: %{time_appconnect}
    # TTFB including connection: %{time_starttransfer}
    # We can use time_starttransfer - time_appconnect to get the real TTFB (Reference: https://blog.cloudflare.com/a-question-of-timing/)
    # TTFB: %{time_starttransfer} - %{time_appconnect}
    # Total time: %{time_total}
    REQUEST_INFO=$(curl -s -w "TLS Handshake: %{time_appconnect}\nTTFB Connection: %{time_starttransfer}\nTTFB: $(echo %{time_starttransfer} %{time_appconnect})\nTotal Time: %{time_total}" -I -X GET $url | egrep -i "TTFB:|Total Time|cf-cache-status" )
    REQUEST_TIME=$(echo "$REQUEST_INFO" | grep Total | cut -d' ' -f3 | sed -e 's/,/./')
    TTFB=$(echo "$REQUEST_INFO" | grep TTFB: | cut -d' ' -f2- | sed -e 's/,/./g' | awk '{print $1 - $2}')
    REQUEST_CACHE=$(echo "$REQUEST_INFO" | grep cf-cache-status | cut -d' ' -f2 | egrep -o "[A-Za-z]+" )

    if [ "$REQUEST_CACHE" == "DYNAMIC" ] || [ "$REQUEST_CACHE" == "MISS" ]; then
      UNCACHED_REQUEST_TIME=$REQUEST_TIME
      UNCACHED_TTFB=$TTFB
    fi

    TOTAL_REQUEST_TIME=$(echo $TOTAL_REQUEST_TIME $REQUEST_TIME | awk '{print $1 + $2}')
    TOTAL_TTFB=$(echo $TOTAL_TTFB $TTFB | awk '{print $1 + $2}')

    if [ "$REQUEST_CACHE" == "HIT" ]; then
      NUMBER_OF_CACHED_REQUESTS=$(echo $NUMBER_OF_CACHED_REQUESTS 1 | awk '{print $1 + $2}')

      TOTAL_REQUEST_TIME_CACHED=$(echo $TOTAL_REQUEST_TIME_CACHED $REQUEST_TIME | awk '{print $1 + $2}')
      TOTAL_TTFB_CACHED=$(echo $TOTAL_TTFB_CACHED $TTFB | awk '{print $1 + $2}')


      if [ "$cached_count" == "0" ]; then
        FIRST_TTFB=$TTFB
        FAST=$REQUEST_TIME
        SLOW=$REQUEST_TIME
        cached_count=1
      else
        if [ "$(echo $REQUEST_TIME'>'$SLOW | bc -l)" == "1" ]; then
          SLOW=$REQUEST_TIME
        fi
        if [ "$(echo $REQUEST_TIME'<'$FAST | bc -l)" == "1" ]; then
          FAST=$REQUEST_TIME
        fi
      fi
    fi
  done

done
AVG_REQUEST_TIME=$(echo $TOTAL_REQUEST_TIME $NUMBER_OF_REQUESTS | awk '{print $1 / $2}')
AVG_TTFB=$(echo $TOTAL_TTFB $NUMBER_OF_REQUESTS | awk '{print $1 / $2}')

if [ "$NUMBER_OF_CACHED_REQUESTS" != "0" ]; then
  AVG_REQUEST_TIME_CACHED=$(echo $TOTAL_REQUEST_TIME_CACHED $NUMBER_OF_CACHED_REQUESTS | awk '{print $1 / $2}')
  AVG_TTFB_CACHED=$(echo $TOTAL_TTFB_CACHED $NUMBER_OF_CACHED_REQUESTS | awk '{print $1 / $2}')
else
  AVG_REQUEST_TIME_CACHED=null
  AVG_TTFB_CACHED=null
fi

# The CSV fields will need to be the same for future tests ideally.
# These might be all we need:
# Worker version, Date of test, Total requests, Uncached request time, Avg request time, Avg request time cached-only, Uncached TTFB, Avg TTFB, Avg TTFB cached-only
if [ "$OUTPUT_FORMAT" == "pretty" ]; then
  echo "-----------"
  echo "Uncached request time: $UNCACHED_REQUEST_TIME"
  echo "Requests: $NUMBER_OF_REQUESTS"
  echo "Fastest cached request time: $FAST"
  echo "Slowest cached request time: $SLOW"
  echo "Avg request time: $AVG_REQUEST_TIME"
  echo "Avg request time cached-only: $AVG_REQUEST_TIME_CACHED "
  echo "Uncached TTFB: $UNCACHED_TTFB"
  echo "Avg TTFB: $AVG_TTFB"
  echo "Avg TTFB cached-only: $AVG_TTFB_CACHED"
else
  #     Worker Version  Date              Requests            Uncached Request time
  echo "$WORKER_VERSION,$(date +%Y-%m-%d),$NUMBER_OF_REQUESTS,$UNCACHED_REQUEST_TIME,$AVG_REQUEST_TIME,$AVG_REQUEST_TIME_CACHED,$UNCACHED_TTFB,$AVG_TTFB,$AVG_TTFB_CACHED"
fi
