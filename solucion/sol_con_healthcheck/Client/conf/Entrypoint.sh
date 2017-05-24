#!/bin/bash

echo "deb http://mirror_c:8080/ xenial main" > /etc/apt/sources.list
chmod 777 /tmp
apt-get clean
apt-get update -y
apt-get install python3 -y
apt-get install postgresql -y

httpd-foreground
