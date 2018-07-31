#!/bin/bash
prefix=/scratch/$USER
atime=21
cd $prefix

datestr=`date +%Y%m%d`

if [ -z "$1" ]; then
    echo 'Endangered list:'
    cat $prefix/.notify-list
    echo ''
    echo "USAGE: $0 [path1] [path2] ..."
else
    for path in $*; do
        pathshort=${path#$prefix/}
        echo ''
        echo "Looking for files older than $atime days in $pathshort"
        pathshort=${pathshort//\//.}
        fname="$prefix/log.checkpurge.$pathshort.$datestr"
        time lfs find $path -type f --atime +$atime > $fname
        echo "Log in $fname"
    done
fi
