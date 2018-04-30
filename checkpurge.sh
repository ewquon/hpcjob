#!/bin/bash
prefix=/scratch/$USER
atime=21
cd $prefix

datestr=`date +%Y%m%d`

for path in $*; do
    pathshort=${path#$prefix/}
    echo ''
    echo "Looking for files older than $atime days in $pathshort"
    pathshort=${pathshort//\//.}
    time lfs find $path -type f --atime +$atime > $prefix/log.checkpurge.$pathshort.$datestr
done
