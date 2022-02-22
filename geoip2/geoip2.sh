#!/bin/bash
# GeoIP2


# Get chris-lea PPA sources
CHRIS_REPO=$(cat /etc/apt/sources.list.d/ppa_chris_lea_nginx_devel_focal.list | cut -d' ' -f2- | head -n1)
echo "deb-src $CHRIS_REPO" >> /etc/apt/sources.list.d/ppa_chris_lea_nginx_devel_focal.list

# Download the src
apt-get update
cd /usr/local/src
apt-get source nginx
NGINX_VERSION=$(ls -1t | grep 'nginx\-')
mv $NGINX_VERSION nginx_orig

# Download latest GeoIP2 release
wget https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/3.3.tar.gz -O geoip2.tar.gz
tar -xf geoip2.tar.gz
GEOIP_DIR=$(ls -1t | grep ngx_http_geoip2)

# Move GeoIP2 to nginx modules directory
mv $GEOIP_DIR nginx_orig/debian/modules/http-geoip2

# Get the patch and apply it
wget https://raw.githubusercontent.com/coleplx/workscripts/master/geoip2/nginx_geoip2.patch -O /usr/local/src/nginx_geoip2.patch
patch -s -p0 < nginx_geoip2.patch

# Recompile the packages
cd nginx_orig
dpkg-buildpackage -uc -b
