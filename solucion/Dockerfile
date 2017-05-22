from mirror_key

RUN aptly mirror create -architectures=amd64 -filter='Priority (required) | Priority (important) | Priority (standard) | postgresql' -filter-with-deps mirror-xenial http://mirror.upb.edu.co/ubuntu/ xenial main

RUN aptly mirror update mirror-xenial

RUN aptly snapshot create mirror-snap-xenial from mirror mirror-xenial

RUN aptly publish snapshot mirror-xenial

VOLUME ["/aptly"]

CMD aptly serve
