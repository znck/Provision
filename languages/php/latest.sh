#!/usr/bin/env bash
#
# REQUIRES:
#       - USER (the default user)
#       - PHP_VERSION (supported values: 5.6, 7.0, 7.1)
#

USER=${USER:-wtuser}
PHP_VERSION=${PHP_VERSION:-7.0}

## => Add PPA repository for PHP
## ----------------------------------------------------------------
apt-add-repository ppa:ondrej/php -y

## => Install base PHP packages
## ----------------------------------------------------------------
apt-get install -y --allow-unauthenticated php${PHP_VERSION}-cli php${PHP_VERSION}-dev \
  php-pgsql php-sqlite3 php-gd \
  php-curl php${PHP_VERSION}-dev \
  php-imap php-mysql php-memcached php-mcrypt php-mbstring \
  php-xml php-imagick php${PHP_VERSION}-zip php${PHP_VERSION}-bcmath php-soap \
  php${PHP_VERSION}-intl php${PHP_VERSION}-readline

apt-get install -y --allow-unauthenticated php${PHP_VERSION}-fpm

## => Install composer
## ----------------------------------------------------------------
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

## => Configure PHP CLI
## ----------------------------------------------------------------
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini

# Disable XDebug On The CLI
phpdismod -s cli xdebug

## => Configure PHP FPM
## ----------------------------------------------------------------
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini

## => Configure PHP sessions
## ----------------------------------------------------------------
chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions
sed -i "s/\;session.save_path = .*/session.save_path = \"\/var\/lib\/php5\/sessions\"/" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/php5\/sessions/php\/sessions/" /etc/php/${PHP_VERSION}/fpm/php.ini

## => Configure PHP to run as ${USER}
## ----------------------------------------------------------------
sed -i "s/^user = www-data/user = ${USER}/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i "s/^group = www-data/group = ${USER}/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

sed -i "s/;listen\.owner.*/listen.owner = ${USER}/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i "s/;listen\.group.*/listen.group = ${USER}/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = 60/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

## => Restart FPM service
## ----------------------------------------------------------------
service php${PHP_VERSION}-fpm restart
