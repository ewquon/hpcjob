#!/bin/sh
#
# Tars up select files/folders within specified directories
#
# - note: directly creating tar files on /mss is VERY slow (08/26/16)
#
# USAGE:
# 1. Create .backupPath if saving in location other than /mss/projects/${curpath}
# 2. foamBackup.sh case1 [case2 case3...]
#
pathfile='.backupPath'
basepath="/mss/projects"
tarcmd='tar -cvf' # --ignore-failed-read'

echo "Backup path: $basepath"

curdir=`pwd`
if [ -f "$pathfile" ]; then
    tgtdir=`cat "$pathfile"`
    echo "Using alternate backup path: $tgtdir"
else
    altRemotePath=`upsearch "$pathfile"`
    if [ -n "$altRemotePath" ]; then
        echo "Found $altRemotePath"
        tgtdir=`cat "$altRemotePath"`
        echo "Specified alternate path: $tgtdir"
        altRemotePath=`dirname "$altRemotePath"`
        len=${#altRemotePath}
        relpath=${PWD:len}
        echo "Relative path (local): (...)$relpath"
        tgtdir="${tgtdir}${relpath}"
        echo "Alternate path: $tgtdir"
    else
        tgtdir="$basepath/${curdir#/scratch/$USER/}"
        echo "Using backup path: $tgtdir"
    fi
fi
if [ -z "$1" ]; then
    echo "Specify directory(ies) to backup"
    exit
fi

runcmd()
{
    echo $*
    $*
}

for timedir in "$@"; do
    if [ -f "$tgtdir/$timedir.tar" ]; then
        echo ''
        echo "SKIPPING existing $tgtdir/$timedir.tar"
        continue
    fi

    runcmd $tarcmd $tgtdir/$timedir.tar $timedir

done
echo ''
echo 'DONE'
echo ''
