#!/bin/sh

set -e

GIT_USER=${GIT_USER:-fake_user}

GIT_SSH_KEY=${GIT_SSH_KEY:-fake_key}

GIT_SSH_CONFIG=${GIT_SSH_CONFIG:-fake_config}

GIT_EMAIL=${GIT_EMAIL:-fake@fake.com}


# Copy SSH key for git private repos
mkdir -p /root/.ssh
echo "${GIT_SSH_KEY}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa


echo "${GIT_SSH_CONFIG}" > /root/.ssh/config
chmod 600 /root/.ssh/config

git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_USER}"

CMD="/workdir/db-dumper.sh ${DUMPER_COMMAND}"
  
exec ${CMD}