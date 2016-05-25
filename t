#!/bin/bash
starsim=(*.sim)
if [ -d "constant" -a -d "system" ]; then
    #
    # OpenFOAM
    #
    if [ -f "$1" ]; then
        fname="$1"
    else
        fname=`ls -rt log.* | tail -n 1`
        echo "Found OpenFOAM output: $fname" >&2
    fi

    str=`grep 'Time =' $fname | grep -v 'Exec' | tail -n 1`
    latestTime=`echo $str | awk '{print $3}'`
    latestStep=`echo $str | awk '{print $NF}'`

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
        echo "Found Star-CCM+ output: $fname" >&2
    fi

    str=`grep 'TimeStep' $fname | tail -n 1`
    latestTime=`echo $str | awk '{print $NF}'`
    latestStep=`echo $str | awk '{print $2}'`
    latestStep=${latestStep%:}

else
    echo "No log file found; please specify"
    exit
fi

echo "Time step $latestStep : t= $latestTime"

