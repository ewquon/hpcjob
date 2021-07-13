#!/bin/bash
starsim=(*.sim)
if [ -d "constant" -a -d "system" ]; then
    #
    # OpenFOAM
    #
    if [ -f "$1" ]; then
        fname="$1"
    else
        solver=`grep application system/controlDict | awk '{print $2}' | sed 's/\;$//'`
        fname=`ls -rt log.*$solver* | tail -n 1`
        if [ -z "$fname" ]; then
            exit 1
        fi
        echo "Found OpenFOAM output: $fname" >&2
    fi

    str=`grep '^Time =' $fname | tail -n 1`
    latestTime=`echo $str | awk '{print $3}'`
    latestStep=`echo $str | awk '{print $NF}'`

elif [ -d "plt00000" -a -f "datlog" ]; then
    #
    # Solvers based on AMReX
    #
    if [ -f "$1" ]; then
        fname="$1"
    else
        fname=`ls -rt *log* | grep -v 'datlog' | tail -n 1`
        echo "Found AMReX output: $fname" >&2
    fi

    # STEP = 40022 TIME = 0.20011 DT = 5e-06
    str=`grep '^STEP =' $fname | tail -n 1`
    latestTime=`echo $str | awk '{print $6}'`
    latestStep=`echo $str | awk '{print $3}'`

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

