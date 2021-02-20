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

COPY ./dump.sh /workdir/dump.sh

RUN  chmod +x /workdir/dump.sh

CMD ["/workdir/dump.sh", "$@"]


