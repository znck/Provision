#!/usr/bin/env bash
#
# REQUIRES:
#       - USER (the default user)
#

USER=${USER:-wtuser}

## => Add PPA repository for Nginx
## ----------------------------------------------------------------
apt-add-repository ppa:nginx/development -y

## => Install Nginx
## ----------------------------------------------------------------
apt-get install -y --allow-unauthenticated nginx

## => Configure Nginx
## ----------------------------------------------------------------

# Generate dhparam file.
echo "Generating dhpraam file this will take some time...";
openssl dhparam -out /etc/nginx/dhparams.pem 2048 &> /dev/null

# Disable default site.
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart

# Run nginx as ${USER}
sed -i "s/user www-data;/user ${USER};/" /etc/nginx/nginx.conf

# Some nginx configurations
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
sed -i "s/# multi_accept.*/multi_accept on;/" /etc/nginx/nginx.conf

## => Install a catch-all server
## ----------------------------------------------------------------
cat > /etc/nginx/sites-available/catch-all << EOF
server {
    return 404;
}
EOF
ln -s /etc/nginx/sites-available/catch-all /etc/nginx/sites-enabled/catch-all

## => Restart service
## ----------------------------------------------------------------
service nginx restart
service nginx reload

## => Add ${USER} to www-data group
## ----------------------------------------------------------------
usermod -a -G www-data ${USER}
id ${USER}
groups ${USER}
