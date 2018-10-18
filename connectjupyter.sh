#!/bin/bash
remoteaddr='hpc-dav4'

get_address()
{
    while read -r line || [[ -n "$line" ]]; do
        if [ -z "$1" ]; then
            echo $line
        elif [[ $line == http://localhost* ]]; then
            # example line: http://localhost:8888/?token=blerg :: /path/to/server
            addr=${line%% ::*}
            path=${line##*:: }
            port=${addr#http://localhost:}
            port=${port%/?*}
            if [ "$port" == "$1" ]; then
                localport=$((port+1000))
                echo "Mapping $localport to $addr ($path)"
                ssh -L $localport:$remoteaddr:$port -f -N peregrine.hpc.nrel.gov
                if [ "$?" == 0 ]; then
                    localaddr=`echo $remoteaddr | sed "s/$port/$localport/"`
                    open $localaddr
                fi
            fi
        fi
    done
}

if [ -n "$2" ]; then
    remoteaddr="$2"
fi
ssh $remoteaddr 'jupyter notebook list' 2>/dev/null | get_address $1

