#!/bin/bash
#
# Touches select files within a simulation directory to ensure that files won't
# disappear when a job starts.
#
nproc=`ls -d processor*/ | wc -l`
echo "Processor directories found: $nproc"
latest_proc_dir=`ls processor0 | grep -v 'constant' | awk '{if ($1 > lasttime) lasttime=$1} END {print lasttime}'`
echo "Latest restart time: $latest_proc_dir"
if [ "`ls -d processor*/$latest_proc_dir/ | wc -l`" -ne "$nproc" ]; then
    echo 'Not all processor directories contain the expected time!'
    exit 1
fi
touch runscript.* log.*
touch 0*
echo 'Touching processor directories'
touch processor*/$latest_proc_dir
touch processor*/$latest_proc_dir/*
echo 'Touching constant directory'
touch constant/*
touch constant/polyMesh/*
echo 'Touching system directory'
touch system/*
touch system/*/*
