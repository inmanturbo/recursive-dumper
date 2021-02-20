#!/bin/sh

set -e

GIT_USER=${USER:-fake_user}

GIT_SSH_KEY=${SSH_KEY:-fake_key}

GIT_SSH_CONFIG=${SSH_CONFIG:-fake_config}

GIT_EMAIL=${EMAIL:-fake@fake.com}


# Copy SSH key for git private repos
mkdir -p /root/.ssh
echo "${SSH_KEY}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa


echo "${SSH_CONFIG}" > /root/.ssh/config
chmod 600 /root/.ssh/config

git config --global user.email "${EMAIL}"
git config --global user.name "${USER}"

CMD="/workdir/db-dumper.sh ${DUMPER_COMMAND}"
  
exec ${CMD}