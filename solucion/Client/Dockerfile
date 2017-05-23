FROM postgres:latest

ADD keys/public.asc /tmp
RUN apt-key add /tmp/public.asc
RUN rm -f /tmp/public.asc

ADD /conf/Entrypoint.sh /scripts/Entrypoint.sh
RUN chmod +x /scripts/Entrypoint.sh

RUN apt-get update
RUN apt-get install curl -y

CMD ["./scripts/Entrypoint.sh"]
