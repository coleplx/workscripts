#!/bin/bash

for i in $(find /usr/bin/ -type l -iname lsphp*); do
    VERSAO=$(echo $i | cut -d'/' -f4 | sed -e 's/\.//')
    VERSAO_SHORT=$(echo $i | egrep -o [0-9.]+)
    if [ $VERSAO_SHORT = "5.6" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -q -y $VERSAO-dev
        wget https://pecl.php.net/get/timezonedb-2019.3.tgz -O /usr/local/src/timezonedb.tgz
        tar -xf /usr/local/src/timezonedb.tgz -C /usr/local/src/
        cd /usr/local/src/timezonedb-2019.3/; /usr/local/lsws/lsphp56/bin/phpize && ./configure --with-php-config=/usr/local/lsws/lsphp56/bin/php-config && make && make install
    else
        DEBIAN_FRONTEND=noninteractive apt-get install -q -y $VERSAO-pear $VERSAO-dev
        /usr/local/lsws/$VERSAO/bin/pecl install timezonedb
    fi
    if [ $? == 0 ]; then
        if [ $VERSAO_SHORT = "5.6" ]; then
            echo 'extension=timezonedb.so' > /usr/local/lsws/lsphp56/etc/conf.d/timezonedb.ini
        else
            echo 'extension=timezonedb.so' > /usr/local/lsws/$VERSAO/etc/php/$VERSAO_SHORT/mods-available/timezonedb.ini
        fi
    fi
done

/etc/init.d/lsws restart
