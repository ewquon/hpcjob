#!/bin/bash
d1=${@:1:1} #${@[1]} doesn't work...
d2=${@:2:1} #${@[2]} doesn't work...
echo "Start time: $d1"
echo "  End time: $d2"
t1=`date -d "$d1" +%s`
t2=`date -d "$d2" +%s`
delta=$((t2-t1))
echo "     DELTA= $delta s"
echo "          = `echo \"scale=1; $delta/60\" | bc` min"
echo "          = `echo \"scale=1; $delta/3600\" | bc` hrs"
