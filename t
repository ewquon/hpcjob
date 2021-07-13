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

elif [ -f "rsl.out.0000" -a "rsl.error.0000" ]; then
    fname='rsl.out.0000'
    echo "Found WRF output: $fname" >&2
    # Timing for main: time 2020-05-15_12:00:06 on domain   2:    2.89353 elapsed seconds
    ndom=`grep 'Domain #' $fname | wc -l`
    domstr=`printf '%3g' $ndom`
    str=`grep '^Timing for main' $fname | tail -n 10 | grep "on domain $domstr" | tail -n 1`
    latestTime=`echo $str | awk '{print $5}'`
    latestStep='--'

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

