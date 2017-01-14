#!/usr/bin/env bash

## => Install ufw
## ----------------------------------------------------------------
apt-get install -y --allow-unauthenticated ufw

## => Setup firewall
## ----------------------------------------------------------------
ufw allow 22 # SSH

## => Enable firewall
## ----------------------------------------------------------------
ufw --force enable
