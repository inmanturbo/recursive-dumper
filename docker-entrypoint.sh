#!/bin/sh

set -e

CMD="/workdir/db-dumper.sh ${DUMPER_COMMAND}"
   
exec ${CMD}