FROM ubuntu:16.04

ADD keys/public.asc /tmp
RUN apt-key add /tmp/public.asc
RUN rm -f /tmp/public.asc

ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh
RUN chmod +x /scripts/Entrypoint.sh

EXPOSE 5000
CMD ["./scripts/Entrypoint.sh"]
