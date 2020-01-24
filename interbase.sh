#!/bin/bash
PHP_BIN=$(ls /usr/bin/lsphp*)

apt install firebird-dev -y

for PHP in $PHP_BIN; do
    PHP_VERSION=$($PHP -v | head -n1 | cut -d' ' -f2 | cut -d'-' -f1)
    PHP_SHORT_VERSION=$(basename $PHP | sed -e 's/lsphp//'  | sed -e 's/\.//')
    PHP_SHORT_VERSION2=$(basename $PHP | sed -e 's/lsphp//')
    apt install lsphp${PHP_SHORT_VERSION}-dev -y
    wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz -O /usr/local/src/$PHP_VERSION.tgz
    cd /usr/local/src; tar -xf $PHP_VERSION.tgz
    cd php-$PHP_VERSION/ext/interbase
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpize
    ./configure --with-php-config=/usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/php-config
    make
    make install
    echo "extension=interbase.so" > /usr/local/lsws/lsphp72/etc/php/7.2/mods-available/interbase.ini    
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpenmod -v $PHP_SHORT_VERSION2 interbase
done

systemctl restart lsws
    
