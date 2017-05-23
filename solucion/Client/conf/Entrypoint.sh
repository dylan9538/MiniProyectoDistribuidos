echo mirror
echo "deb http://mirror/ xenial main" > /etc/apt/sources.list
chmod 777 /tmp
apt-get clean
apt-get update -y
apt-get install postgresql -y

postgresql -m http.server 5000
