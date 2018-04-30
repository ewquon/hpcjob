#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RSYNC='rsync -aPvh'

target="$1"
if [ -z "$target" ]; then
    echo 'Specify backup path!'
    echo 'Example (run from inside case directory):'
    echo "  $0 /projects/allocation/task/foo/bar"
    exit
fi

echo ''
if [ ! -d "$target" ]; then
    echo "Creating backup path: $target"
    mkdir -p $target
else
    echo -e "${RED}Warning${NC}: $target already exists! (Rename postProcessing files as necessary!)"
fi

if [ ! -d "constant" ]; then echo -e "${RED}ERROR${NC}: 'constant' not found" && exit; fi
if [ ! -d "system" ]; then echo -e "${RED}ERROR${NC}: 'system' not found" && exit; fi

echo ''
echo    '-----------------------------------------------------------'
read -p " Was this started in a screen?? Press enter to continue..."
echo    '-----------------------------------------------------------'
echo ''

startdirs='constant system'
if [ ! -d "0.original" ]; then
    echo -e "${RED}Warning${NC}: '0.original' not found"
else
    startdirs="$startdirs 0.original"
fi

timedirs=`foamOutputDirs.py`

latesttime=`foamLatestTime.py processor0`
if [ "$latesttime" -le 0 ]; then echo -e "${RED}Warning${NC}: latest time is $latesttime?"; fi
echo "Latest processor time directory: $latesttime"

cd postProcessing
for d in `find . -maxdepth 1 -type d`; do
    if [ "$d" == '.' ]; then continue; fi
    if [ ! -s "${d}.tar" ]; then
        echo "Creating ${d}.tar"
        tar cf ${d}.tar $d
    fi
done
cd ..
postProcessing_files=`find postProcessing -maxdepth 1 -not -type d | xargs`
echo "Post-processing files: $postProcessing_files"

echo '--- rsync -------------------------------------------------'
$RSYNC \
        $startdirs \
        setUp \
        runscript.* \
        log.* \
        $timedirs \
    $target/
$RSYNC -m --include='processor**/' --include="**/constant/**" --include="**/$latesttime/**" --exclude='*' ./  $target/
$RSYNC ${postProcessing_files} $target/postProcessing/

