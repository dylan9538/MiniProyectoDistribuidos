#Base image used
FROM ubuntu:16.04 

#Add private key to container
ADD /keys/private.asc /keys/private.asc
#Add aptly configuration
ADD /conf/aptly.conf /etc/aptly.conf

#Add publish configuration
ADD /conf/publish_snapshot.sh /scripts/publish_snapshot.sh
RUN chmod +x /scripts/publish_snapshot.sh

#Add entrypoint
ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh
RUN chmod +x /scripts/Entrypoint.sh \

#Import key to gpg and remove for safety
&& gpg --import /keys/private.asc \
&& rm -f /keys/private.asc \

#Set keyring
&& gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import \

#Install Aptly
&& echo deb http://repo.aptly.info/ squeeze main > /etc/apt/sources.list \
&& apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460 \
&& apt-get update \
&& apt-get install aptly -y \

#Install System Aptly dependencies (These were deleted from base image ubuntu:16.04)
&& echo deb http://co.archive.ubuntu.com/ubuntu/ xenial main restricted >> /etc/apt/sources.list \
&& apt-get update && apt-get install -y \
    xz-utils \
    bzip2 \

#Install Expect
&& echo deb http://co.archive.ubuntu.com/ubuntu/ xenial universe >> /etc/apt/sources.list \
&& apt-get update \
&& apt-get install expect -y \

#Configure Aptly mirror
&& aptly mirror create -architectures=amd64 -filter='Priority (required) | Priority (important) | Priority (standard) | postgresql' -filter-with-deps mirror-xenial http://mirror.upb.edu.co/ubuntu/ xenial main \
&& aptly mirror update mirror-xenial

#EntryPoint Command 
CMD ["./scripts/Entrypoint.sh"]
