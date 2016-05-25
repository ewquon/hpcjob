#!/bin/bash
set -e

if [ -n "$1" ]; then 
    iproc=$1
else
    iproc=0
fi

while true; do 
    d="processor$iproc"
    if [ ! -d "$d" ]; then
        exit
    fi
    echo "$d"
    tar czf $d.tar.gz $d && rm -r $d
    iproc=$((iproc+1))
done
