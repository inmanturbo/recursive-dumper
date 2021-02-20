FROM clearlinux

ARG EMAIL

ARG USER

RUN swupd bundle-add git mariadb openssh-server

# Copy SSH key for git private repos
ADD id_rsa /root/.ssh/id_rsa
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/id_rsa \
  && chmod 600 /root/.ssh/config

RUN git config --global user.email "${EMAIL}"
RUN git config --global user.name "${USER}"

WORKDIR /workdir

COPY ./db-dumper.sh /workdir/db-dumper.sh
COPY ./docker-entrypoint.sh /workdir/docker-entrypoint.sh

RUN  chmod +x /workdir/db-dumper.sh \
  && chmod +x /workdir/docker-entrypoint.sh

CMD ["/workdir/docker-entrypoint.sh"]


