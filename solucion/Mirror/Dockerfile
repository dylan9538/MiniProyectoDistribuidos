FROM ubuntu:16.04

#Add private key to container
ADD /keys/private.asc /keys/private.asc
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
RUN apt-get install aptly -y

#Install System Aptly dependencies
RUN echo deb http://co.archive.ubuntu.com/ubuntu/ xenial main restricted >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install xz-utils -y
RUN apt-get install bzip2 -y

#Install Expect
RUN echo deb http://co.archive.ubuntu.com/ubuntu/ xenial universe >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install expect -y

#Configure Aptly mirror
RUN aptly mirror create -architectures=amd64 -filter='Priority (required) | Priority (important) | Priority (standard) | postgresql' -filter-with-deps mirror-xenial http://mirror.upb.edu.co/ubuntu/ xenial main
RUN aptly mirror update mirror-xenial

#Add publish configuration
RUN echo "Hola"
ADD /conf/publish_snapshot.sh /scripts/publish_snapshot.sh
RUN chmod +x /scripts/publish_snapshot.sh

#Add entrypoint
ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh
RUN chmod +x /scripts/Entrypoint.sh

CMD ["./scripts/Entrypoint.sh"]
