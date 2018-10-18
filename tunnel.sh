#!/bin/bash
if [ -z "$2" ]; then
    echo 'Run remote: jupyter notebook --ip="*" --no-browser'
    echo "USAGE: $0 local_port remote_port [remote_addr]"
    exit
fi
#remoteaddr='hpc-dav4'
remoteaddr='dav4.hpc.nrel.gov'

if [ -n "$3" ]; then
    remoteaddr="$3"
fi

ssh -L $1:$remoteaddr:$2 -f -N peregrine.hpc.nrel.gov
