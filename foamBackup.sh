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
tmpdir='TO_SYNC_WITH_MSS'
tarcmd='tar -cf' # --ignore-failed-read'

curdir=`pwd`

mkdir -p "$tmpdir"

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
        echo "Relative path (local): ...$relpath"
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

tmpdir="$curdir/$tmpdir"

for backupdir in "$@"; do
    if [ -d "$tmpdir/$backupdir" ]; then
        echo ''
        echo "SKIPPING existing $backupdir"   
        echo ''
        continue
    fi
    echo ''
    echo "Backing up $backupdir"
    echo ''

    mkdir -p $tmpdir/$backupdir/postProcessing

    cd "$curdir/$backupdir"
    # follow symlinks
#    runcmd tar cfh $tmpdir/$backupdir/start.tar 0* constant system *.pbs runscript* sub*
#    runcmd tar cfh $tmpdir/$backupdir/output.tar log.*
    # retain symlinks
    runcmd $tarcmd $tmpdir/$backupdir/start.tar 0* constant system *.pbs runscript* sub*
    runcmd $tarcmd $tmpdir/$backupdir/output.tar log.*

    cd postProcessing
    postProcFiles=`find . -maxdepth 1 -type f`
    postProcDirs=`find . -maxdepth 1 -type f`
    runcmd $tarcmd $tmpdir/$backupdir/postProcessing/postProcessing.tar $postProcFiles
    for d in `find . -maxdepth 1 -type d`; do
        if [ "$d" == '.' ]; then continue; fi
        d=`basename $d`
        runcmd $tarcmd $tmpdir/$backupdir/postProcessing/$d.tar $d
    done

done
echo ''
echo 'DONE'
echo ''
echo 'Now run rsync:'
echo "rsync -aPvh $tmpdir/* $tgtdir/"
