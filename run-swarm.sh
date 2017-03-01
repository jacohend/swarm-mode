#!/bin/bash

COMMAND="$1"
NETWORK="example_stack"
BASEDIR=`cd $( dirname "${BASH_SOURCE[0]}"  )/..; pwd`

function build {
    docker build -t module .
}

function rm {
    docker stack rm $NETWORK
    sleep 5 #some of the removal happens async
}

function run {
    docker swarm init
    rm
    docker network create $NETWORK
    cd config
    docker stack deploy --compose-file=local-swarm.yaml $NETWORK
}

function scale {
    docker service scale ${NETWORK}_module=2
}

${COMMAND}


