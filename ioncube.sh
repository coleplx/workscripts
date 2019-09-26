#!/bin/bash
# ioncube.sh

PHP_VERSION=$(ls -1 /usr/sbin/ | grep php-fpm)

# Download IonCube
wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /usr/local/src/ioncube.tar.gz
cd /usr/local/src/; tar -zxf /usr/local/src/ioncube.tar.gz
ION_DIR=/usr/local/src/ioncube

# Copia a versao do ioncube para cada versao do PHP instalada
for i in $PHP_VERSION; do
    php_version=$(/usr/sbin/$i -v | head -n1 | egrep -o "PHP [0-9.]+" | egrep -o "[0-9.]+" | cut -d'.' -f1-2)
    extension_dir=$(/usr/sbin/$i -i | egrep ^extension_dir | cut -d' ' -f3)
    cp $ION_DIR/ioncube_loader_lin_${php_version}.so $extension_dir/
    chmod 644 $extension_dir/ioncube_loader_lin_${php_version}.so
    echo "zend_extension = ioncube_loader_lin_${php_version}.so" > /etc/php/${php_version}/mods-available/ioncube.ini
    ln -s /etc/php/${php_version}/mods-available/ioncube.ini /etc/php/${php_version}/fpm/conf.d/01-ioncube.ini
done

# interno
cez --php-reload

# Limpa os arquivos temporarios
rm -rf /usr/local/src/ioncube.tar.gz
rm -rf $ION_DIR
