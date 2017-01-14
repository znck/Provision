#!/usr/bin/env bash

## => Add PPA repository for Redis
## ----------------------------------------------------------------
apt-add-repository ppa:chris-lea/redis-server -y

## => Install redis
## ----------------------------------------------------------------
apt-get install -y --allow-unauthenticated redis-server

## => Configure
## ----------------------------------------------------------------
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf

## => Restart redis server
## ----------------------------------------------------------------
service redis-server restart
