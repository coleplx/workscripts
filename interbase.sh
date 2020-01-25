#!/bin/bash
PHP_BIN=$(ls /usr/bin/lsphp*)

apt install firebird-dev -y  &> /dev/null

for PHP in $PHP_BIN; do
    PHP_VERSION=$($PHP -v | head -n1 | cut -d' ' -f2 | cut -d'-' -f1)
    PHP_SHORT_VERSION=$(basename $PHP | sed -e 's/lsphp//'  | sed -e 's/\.//')
    PHP_SHORT_VERSION2=$(basename $PHP | sed -e 's/lsphp//')
    # Installing dependencies
    echo "Installing dev package for PHP"
    apt install lsphp${PHP_SHORT_VERSION}-dev -y &> /dev/null

    # Downloading PHP source to compile extensions
    echo "Downloading PHP sources to compile extensions..."
    wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz -O /usr/local/src/$PHP_VERSION.tgz &> /dev/null
    cd /usr/local/src; tar -xf $PHP_VERSION.tgz
    cd php-$PHP_VERSION/ext/interbase
    # Generate configure script
    echo "Generating configure script for interbase..."
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpize &> /dev/null
    # Configure the extension
    if [ $? != 0 ]; then
        echo "Something went wrong with phpize @ interbase extension. Exiting..."
        exit
    fi
    echo "Configuring extension..."
    ./configure --with-php-config=/usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/php-config &> /dev/null
    if [ $? != 0 ]; then
        echo "Something went wrong configuring interbase extension. Exiting..."
        exit
    fi
    echo "Compiling extension..."
    make &> /dev/null
    # Install extension
    if [ $? != 0 ]; then
        echo "Couldn't compile the extension. Exiting..."
        exit
    fi
    make install &> /dev/null
    echo "extension=interbase.so" > /usr/local/lsws/lsphp72/etc/php/7.2/mods-available/interbase.ini
    # Activate extension
    echo "Activating extension..."
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpenmod -v $PHP_SHORT_VERSION2 interbase
    echo "Interbase extension should be enabled now!"

    # pdo_firebird
    cd /usr/local/src/php-$PHP_VERSION/ext/pdo_firebird
    echo "Generating configure script for pdo_firebird..."
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpize &> /dev/null
    # Configure the extension
    if [ $? != 0 ]; then
        echo "Something went wrong with phpize @ interbase extension. Exiting..."
        exit
    fi
    echo "Configuring extension..."
    ./configure --with-php-config=/usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/php-config &> /dev/null
    if [ $? != 0 ]; then
        echo "Something went wrong configuring interbase extension. Exiting..."
        exit
    fi
    echo "Compiling extension pdo_firebird..."
    make &> /dev/null
    # Install extension
    if [ $? != 0 ]; then
        echo "Couldn't compile the extension. Exiting..."
        exit
    fi
    make install &> /dev/null
    echo "extension=pdo_firebird.so" > /usr/local/lsws/lsphp72/etc/php/7.2/mods-available/firebird.ini
    # Activate extension
    echo "Activating extension pdo_firebird..."
    /usr/local/lsws/lsphp$PHP_SHORT_VERSION/bin/phpenmod -v $PHP_SHORT_VERSION2 pdo_firebird
    echo "pdo_firebird extension should be enabled now!"
done

systemctl restart lsws
