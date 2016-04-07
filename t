#!/bin/bash
starsim=(*.sim)
if [ -d "constant" -a -d "system" ]; then
    #
    # OpenFOAM
    #
    if [ -f "$1" ]; then
        fname="$1"
    else
        fname=`ls -rt log.*.* | tail -n 1`
    fi

    grep 'Time =' $fname | tail -n 1

#elif [ -f "${starsim[0]}" ]; then
elif ls *.sim &> /dev/null; then
    #
    # Star-CCM+
    #
    curdir=`pwd`
    casename=`basename $curdir`
    if [ -f "$1" ]; then
        fname="$1"
    elif [ -f "log.$casename" ]; then
        fname="log.$casename"
    fi

    grep 'TimeStep' $fname | tail -n 1

else
    echo "No log file found; please specify"
fi
