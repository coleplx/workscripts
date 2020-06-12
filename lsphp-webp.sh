#!/bin/bash
# lsphp-webp.sh

# Version to install
PHP_VERSION=$1
PHP_SHORT_VERSION=$(echo $PHP_VERSION | sed  's/\.//')
if [ -z $PHP_VERSION ]; then
  echo "Usage: ./lsphp-webp PHP-VERSION"
  echo "Example: ./lsphp-webp 7.3"
  break
fi

# Deps
apt-get install libjpeg-dev libpng-dev lsphp${PHP_SHORT_VERSION}-dev lsphp${PHP_SHORT_VERSION}-pear -y

# libwebp
cd /usr/local/src/
wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.1.0.tar.gz -O /usr/local/src/libwebp-1.1.0.tar.gz
tar -xf /usr/local/src/libwebp-1.1.0.tar.gz
cd libwebp-1.1.0
./configure
make
make install

# ImageMagick
apt-get update
apt build-dep imagemagick -y
cd /usr/local/src/
wget https://imagemagick.org/download/ImageMagick.tar.gz
tar -xf ImageMagick.tar.gz
cd ImageMagick-*
./configure --with-webp=yes
make
make install
ldconfig /usr/local/lib


# php-imagick
cd /usr/local/src/
/usr/local/lsws/lsphp${PHP_SHORT_VERSION}/bin/pecl download imagick
tar -xf imagick-*.tgz
cd $(ls -1t | grep imagick | head -n1)
/usr/local/lsws/lsphp${PHP_SHORT_VERSION}/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp${PHP_SHORT_VERSION}/bin/php-config
make
make install
systemctl restart lsws
