#!/bin/bash
acct='wakedynamics'
ppn=36
nodes=1
timelim='00:30:00'

if [ -z "$1" ]; then
    echo "Need to specify server"
    exit
fi
if [ -n "$2" ]; then
    nodes="$2"
fi

slurms="--account='$acct' --nodes=$nodes --ntasks-per-node=$ppn --time='$timelim'"
echo "========================================"
echo "Using $((nodes*ppn)) cores for $timelim"
echo "========================================"
echo ''
echo "srun flags: $slurms"
echo ''

ip=`ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'`
echo $ip


ssh $1 "module load paraview && srun $slurms pvserver -rc --client-host=$ip"
