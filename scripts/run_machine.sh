#!/bin/bash

machines=$(docker-machine ls -q)

for machine in $machines
do
    docker-machine ssh $machine "$@"
done
