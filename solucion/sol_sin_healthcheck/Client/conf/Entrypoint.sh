#!/bin/bash
# Waits until the mirror's service is up
until $(curl --output /dev/null --silent --head --fail http://mirror_c:8080)
do
  echo 'Waiting for mirror...'     
  sleep 1
done
echo "connected..."

# Adds mirror's source dependency to sources.list
echo "deb http://mirror_c:8080/ xenial main" > /etc/apt/sources.list
# chmod 777 /tmp
# Clean and update sources 
apt-get clean
apt-get update -y
# Install dependencies allocated in the mirror
apt-get install python3 -y
apt-get install postgresql -y
# Start httpd's service (dummy service to keep container alive)
httpd-foreground
