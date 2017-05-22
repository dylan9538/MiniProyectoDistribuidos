FROM ubuntu:16.04

#Add private key to container
COPY /keys/private.asc /keys/private.asc

#Add aptly configuration
ADD /conf/aptly.conf /etc/aptly.conf

#Import key to gpg
RUN gpg --import /keys/private.asc

#Set keyring
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import

#Install Aptly
RUN echo deb http://repo.aptly.info/ squeeze main > /etc/apt/sources.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
RUN apt-get update
RUN apt-get install aptly

#Configure Aptly mirror
RUN aptly mirror create -architectures=amd64 -filter='Priority (required) | Priority (important) | Priority (standard) | postgresql' -filter-with-deps mirror-xenial http://mirror.upb.edu.co/ubuntu/ xenial main
RUN aptly mirror update mirror-xenial
RUN aptly snapshot create mirror-snap-xenial from mirror mirror-xenial
RUN aptly publish snapshot mirror-xenial

VOLUME ["/aptly"]

