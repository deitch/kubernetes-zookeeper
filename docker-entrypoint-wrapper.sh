#!/bin/bash
set -e

# set the env var for extracting the cardinal
if [ -z "$ZOO_MY_ID" ]; then
    ZOO_MY_ID=$(($(hostname | sed s/.*-//) + 1))
    echo "Guessed server id: $ZOO_MY_ID"
fi

export ZOO_MY_ID

/docker-entrypoint.sh $@
