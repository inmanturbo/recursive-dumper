FROM debian

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y mariadb-client git ca-certificates software-properties-common \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workdir

COPY ./db-dumper.sh /workdir/db-dumper.sh
COPY ./docker-entrypoint.sh /workdir/docker-entrypoint.sh

RUN  chmod +x /workdir/db-dumper.sh \
  && chmod +x /workdir/docker-entrypoint.sh

CMD ["/workdir/docker-entrypoint.sh"]


