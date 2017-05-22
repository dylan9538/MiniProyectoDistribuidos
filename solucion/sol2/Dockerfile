FROM ubuntu:16.04

RUN echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list; \
apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460; \
apt-get update; \
apt-get install aptly -y

ADD aptly.conf /etc/aptly.conf
