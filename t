#!/bin/bash
curdir=`pwd`
casename=`basename $curdir`
if [ -f "$1" ]; then
    fname="$1"
elif [ -f "log.$casename" ]; then
    fname="log.$casename"
else
    fname=`ls -rt log.* | tail -n 1`
    echo $fname
fi
grep TimeStep $fname | tail -n 1
