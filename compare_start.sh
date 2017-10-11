#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -z "$2" ]; then
    echo "specify simulation and starting directories"
    exit
fi

diff -qr $1 $2 | grep -v \
    -e 'processor' \
    -e 'runscript.preprocess.' \
    -e 'log.' \
    -e 'constant/polyMesh' \
    -e 'postProcessing' \
    -e 'sources' \
    -e 'boundaryData' |
while read line; do
    if [[ "$line" == *differ ]]; then
        echo -e "${RED}$line${NC}"
    else
        echo "$line"
    fi
done
