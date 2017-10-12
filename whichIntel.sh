#!/bin/bash

procstr=`cat /proc/cpuinfo | grep 'model name' | head -n 1`
echo $procstr >&2

procname=${procstr#*Intel(R) Xeon(R) CPU}
procname=`echo $procname | awk '{print $1,$2}'`

case $procname in
'E5-2670 v2')
    echo 'sandybridge'
    ;;
'E5-2695 v2')
    echo 'ivybridge'
    ;;
'E5-2670 v3')
    echo 'haswell'
    ;;
*)
    echo $procname
esac
