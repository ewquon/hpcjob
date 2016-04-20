#!/bin/bash
set -e

iproc=0
while true; do 
    d="processor$iproc"
    if [ ! -d "$d" ]; then
        exit
    fi
    echo "$d"
    tar czf $d.tar.gz $d && rm -r $d
    iproc=$((iproc+1))
done
