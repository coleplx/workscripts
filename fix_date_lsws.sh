#!/bin/bash

for i in $(find /usr/bin/ -type l -iname lsphp*); do
    VERSAO=$(echo $i | cut -d'/' -f4 | sed -e 's/\.//')
    VERSAO_SHORT=$(echo $i | egrep -o [0-9.]+)
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y $VERSAO-pear $VERSAO-pear
    /usr/local/lsws/$VERSAO/bin/pecl install timezonedb
    if [ $? == 0 ]; then
        echo 'extension=timezonedb.so' > /usr/local/lsws/$VERSAO/etc/php/$VERSAO_SHORT/mods-available/timezonedb.ini
    fi
done

/etc/init.d/lsws restart
