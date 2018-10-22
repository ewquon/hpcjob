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
# Assumes that the ssh tunnel command is of the form:
#
#   ssh -L $local_port:$remoteaddr:$remote_port -f -N $domain
#
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
domain=peregrine.hpc.nrel.gov
opencmd='open'  # Mac OSX command to open browser

get_address()
{
    connected=false
    token=''
    cmd=''
    while read -r line || [[ -n "$line" ]]; do
        if [ -z "$1" ]; then
            echo $line
        elif [[ $line == http://localhost* ]]; then
            # example line to parse: http://localhost:8888/?token=blerg :: /path/to/server
            addr=${line%% ::*}
            path=${line##*:: }
            port=${addr#http://localhost:}
            if [[ $port == *token=* ]]; then
                # have token (instead of notebook password)
                token=${port#*/?token=}
            fi
            port=${port%/*} # remote port
            if [ "$port" == "$1" ]; then
                #cmd="ssh -L $localport:$remoteaddr:$port -f -N $domain"
                #running=`ps -e | grep "$cmd" | grep -v 'grep'`
                running=`ps -e | grep 'ssh -L' | grep -e $domain -e $port`
                if [ -z "$running" ]; then
                    # create tunnel
                    localport=$((port+1000))
                    cmd="ssh -L $localport:$remoteaddr:$port -f -N $domain"
                    echo "Mapping $localport to remote $addr ($path)"
                    $cmd 2>/dev/null
                    connected="$?"
                else
                    echo "Tunnel to $addr already exists"
                    connected=0
                    # scrape the local port (tunnel may have been user created
                    # and not necessarily equal to the remote port+1000
                    sshparams=${running#*ssh}
                    localport=`echo "${sshparams%%:*}" | awk '{print $(NF)}'`
                fi
                if [ "$connected" == 0 ]; then
                    # perform local port substition and open notebook in browser
                    localaddr=`echo $addr | sed "s/$port/$localport/"`
                    if [ -n "$token" ]; then
                        echo "Opening $localaddr"
                    else
                        echo "Opening $localaddr without token (need to specify notebook password)"
                    fi
                    $opencmd $localaddr
                fi
            fi
        fi
    done
    if [ -n "$1" -a "$connected" != 0 ]; then
        # We specified a port to map/connect to but somethign went wrong...
        if [ -z "$cmd" ]; then
            echo "No notebook server found on port $1"
        else
            echo "Failed to connect to port $1 on $remoteaddr with command:"
            echo "  $cmd"
        fi
    fi
}

ssh $remoteaddr 'module load conda && jupyter notebook list' 2>/dev/null | get_address $1

