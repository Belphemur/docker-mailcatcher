#!/bin/bash

# APACHE defaults
if [ -z ${APACHE_MIN_CHILDS+x} ]; then APACHE_MIN_CHILDS=1; fi
if [ -z ${APACHE_MAX_CHILDS+x} ]; then APACHE_MAX_CHILDS=50; fi
if [ -z ${APACHE_MIN_CHILDS_SPARE+x} ]; then APACHE_MIN_CHILDS_SPARE=1; fi
if [ -z ${APACHE_MAX_CHILDS_SPARE+x} ]; then APACHE_MAX_CHILDS_SPARE=5; fi
if [ -z ${APACHE_SERVER_NAME+x} ]; then APACHE_SERVER_NAME=rainloop.loc; fi
if [ -z ${APACHE_SERVER_ADMIN+x} ]; then APACHE_SERVER_ADMIN=webmaster@rainloop.loc; fi
# PHP defaults
if [ -z ${PHP_MAX_POST_SIZE+x} ]; then PHP_MAX_POST=20M; fi
if [ -z ${PHP_MAX_UPLOAD_SIZE+x} ]; then PHP_MAX_UPLOAD_SIZE=8M; fi
if [ -z ${PHP_MAX_UPLOADS+x} ]; then PHP_MAX_POST=20; fi
if [ -z ${PHP_MAX_EXECUTION_ZIME+x} ]; then PHP_MAX_EXECUTION_ZIME=30; fi
# RAINLOOP defaults
if [ -z ${RAINLOOP_ADMIN_LOGIN+x} ]; then RAINLOOP_ADMIN_LOGIN=admin; fi
if [ -z ${RAINLOOP_ADMIN_PASSWORD+x} ]; then RAINLOOP_ADMIN_PASSWORD=12345; fi

sed "s/StartServers.*=.*/StartServers = $APACHE_MIN_CHILDS/g" -i /etc/apache2/mods-available/mpm_prefork.conf
sed "s/MaxRequestWorkers.*=.*/MaxRequestWorkers = $APACHE_MAX_CHILDS/g" -i /etc/apache2/mods-available/mpm_prefork.conf
sed "s/MinSpareServers.*=.*/MinSpareServers = $APACHE_MIN_CHILDS_SPARE/g" -i /etc/apache2/mods-available/mpm_prefork.conf
sed "s/MaxSpareServers.*=.*/MaxSpareServers = $APACHE_MAX_CHILDS_SPARE/g" -i /etc/apache2/mods-available/mpm_prefork.conf

sed "s/ServerName .*/ServerName $APACHE_SERVER_NAME/g" -i /etc/apache2/sites-available/000-default.conf
sed "s/ServerAdmin .*/ServerAdmin $APACHE_SERVER_ADMIN/g" -i /etc/apache2/sites-available/000-default.conf

echo "ServerName $APACHE_SERVER_NAME" > /etc/apache2/conf-enabled/servername.conf

sed "s/post_max_size.*=.*/post_max_size = $PHP_MAX_POST/g" -i /etc/php/7.0/apache2/php.ini
sed "s/upload_max_filesize.*=.*/upload_max_filesize = $PHP_MAX_UPLOAD_SIZE/g" -i /etc/php/7.0/apache2/php.ini
sed "s/max_file_uploads.*=.*/max_file_uploads = $PHP_MAX_POST/g" -i /etc/php/7.0/apache2/php.ini
sed "s/max_execution_time.*=.*/max_execution_time = $PHP_MAX_EXECUTION_ZIME/g" -i /etc/php/7.0/apache2/php.ini

if [ -f /var/www/html/data/_data_/_default_/configs/application.ini  ]; then
  sed "s/admin_login.*=.*/admin_login = $RAINLOOP_ADMIN_LOGIN/g" -i /var/www/html/data/_data_/_default_/configs/application.ini
  sed "s/admin_password.*=.*/admin_password = $RAINLOOP_ADMIN_PASSWORD/g" -i /var/www/html/data/_data_/_default_/configs/application.ini
else
  mkdir -p /var/www/html/data/_data_/_default_/configs/
  echo "[security]" >> /var/www/html/data/_data_/_default_/configs/application.ini
  echo "admin_login = $RAINLOOP_ADMIN_LOGIN" >> /var/www/html/data/_data_/_default_/configs/application.ini
  echo "admin_password = $RAINLOOP_ADMIN_PASSWORD" >> /var/www/html/data/_data_/_default_/configs/application.ini
fi

chown -R www-data.www-data /var/www/html/data
