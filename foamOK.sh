#!/bin/bash

check()
{
    logfile="$1"
    shift
    if [ -f "$logfile" ]; then
        donestr="$*"
        if [ -z "$*" ]; then donestr='End'; fi
        found=`grep "$donestr" $logfile`
        if [ "$?" == 0 ]; then
            echo "$logfile... $found"
        else
            echo "*** Problem with $logfile: $* not found ***"
        fi
    else
        echo "Current directory does not have $logfile"
    fi
}

check log.*blockMesh*
check log.*renumberMesh*
check log.*checkMesh* 'Mesh OK'
check log.*changeDictionary*
check log.*decomposePar*
check log.*setFieldsABL* 'Finalising'

t

