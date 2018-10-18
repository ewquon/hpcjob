#!/bin/bash
#
# Script to facilitate running remote Jupyter notebook servers and
# creating ssh tunnels. 
#
# written by Eliot Quon (eliot.quon@nrel.gov)
#
# Start remote server (e.g., within FastX session) with:
#
#   jupyter notebook --ip="*" --no-browser
#
# USAGE:
#
#   # To display list of running servers
#   connectjupyter.sh
#
#   # To create tunnel to existing server and open up notebook server
#   # in a local browser; the local port number is the remote number 
#   # +1000, to prevent confusion with locally started notebook servers
#   connectjupyter.sh <remote_port_number>
#
remoteaddr=dav4.hpc.nrel.gov

get_address()
{
    connected=false
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
                ssh -L $localport:$remoteaddr:$port -f -N peregrine.hpc.nrel.gov 2>/dev/null
                if [ "$?" == 0 ]; then
                    connected=true
                    localaddr=`echo $addr | sed "s/$port/$localport/"`
                    echo "Opening $localaddr"
                    open $localaddr
                fi
            fi
        fi
    done
    if [ -n "$1" -a "$connected" = false ]; then
        echo "Failed to connect to port $1 on $remoteaddr" 
    fi
}

ssh $remoteaddr 'jupyter notebook list' 2>/dev/null | get_address $1

