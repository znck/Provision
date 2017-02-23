#!/usr/bin/env bash
#
# REQUIRES:
#       - USER (the database user)
#       - DB_PASSWORD (random password for database user)
#

USER=${USER:-tower}
DB_PASSWORD=${DB_PASSWORD:-password}

## => Add PPA repository for Postgres
## ----------------------------------------------------------------
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

## => Install postgres
## ----------------------------------------------------------------
apt-get install -y --allow-unauthenticated postgresql postgresql-contrib

## => Detect postgres version
## ----------------------------------------------------------------
PG_VERSION=`postgres --version | awk '{print $3}' | sed 's/\.[^.]*$//'`

## => Configure remote access
## ----------------------------------------------------------------
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/${PG_VERSION}/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" | tee -a /etc/postgresql/${PG_VERSION}/main/pg_hba.conf

## => Create postgres ${USER}
## ----------------------------------------------------------------
sudo -u postgres psql -c "CREATE ROLE ${USER} LOGIN UNENCRYPTED PASSWORD '${DB_PASSWORD}' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"

## => Restart postgres service
## ----------------------------------------------------------------
service postgresql restart
