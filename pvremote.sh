#!/bin/bash

if [ -z "$1" ]; then
    echo "Need to specify server"
    exit
fi

ip=`ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | tail -n 1`
echo $ip

ssh $1 "module load paraview && pvserver -rc --client-host=$ip"

echo ''
echo "Need to verify that pvserver is no longer running on $1..."
