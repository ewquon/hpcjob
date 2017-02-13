#!/bin/bash
set -e

if [ -z "$1" ]; then 
    echo 'Specify results dir (e.g. "waterSurface")'
    exit
fi

for resultsDir in $@; do
    for d in `find . -type d -name "$resultsDir"`; do
        #echo "tar cvzf $d.tar.gz $d"
        tar cvzf $d.tar.gz $d && rm -r $d
    done
done
