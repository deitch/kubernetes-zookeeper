#!/bin/bash
set -e

# set the env var for extracting the cardinal
if [ -z "$ZOO_MY_ID" ]; then
    ZOO_MY_ID=$(($(hostname | sed s/.*-//) + 1))
    echo "Guessed server id: $ZOO_MY_ID"
fi

export ZOO_MY_ID

# did we set all ifaces?
if [[ "$ZOO_SERVER_ALL_IFACES" == "1" ]]; then
  # substitute the ZOO_SERVERS entry for my server with 0.0.0.0
  shopt -s extglob
  ZOO_SERVERS="${ZOO_SERVERS/server.${ZOO_MY_ID}=+([^:]):/server.${ZOO_MY_ID}=0.0.0.0:}"
fi

/docker-entrypoint.sh $@
