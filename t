#!/bin/bash
curdir=`pwd`
casename=`basename $curdir`
fname='BLERG'

if [ -d "constant" -a -d "system" ]; then
    # OpenFOAM
    if [ -f "$1" ]; then
        fname="$1"
    else
        fname=`ls -rt log.*.* | tail -n 1`
    fi

    grep 'Time =' $fname | tail -n 1

elif [ -n "*.sim" ]; then
    # Star-CCM+
    if [ -f "$1" ]; then
        fname="$1"
    elif [ -f "log.$casename" ]; then
        fname="log.$casename"
    else
        fname=`ls -rt log.* | tail -n 1`
    fi

    grep TimeStep $fname | tail -n 1

fi
