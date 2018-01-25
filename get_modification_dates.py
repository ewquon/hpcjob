#!/usr/bin/env python
from __future__ import print_function
import sys
import os
import datetime

def timestring(timestamp):
    return datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d')

for dpath in sys.argv[1:]:
    if not os.path.isdir(dpath): continue
    fullpaths = []
    timestamps = []
    for fpath in os.listdir(dpath):
        fullpaths.append(os.path.join(dpath,fpath))
        timestamps.append(os.path.getmtime(fullpaths[-1]))
        #print(fpath,timestring(timestamps[-1]))
    timestamps_day = [int(tstamp/3600./24.)*3600.*24. for tstamp in timestamps]
    unique_days = list(set(timestamps_day))
    unique_days.sort(reverse=True)
    print(dpath,'unique times:\n',
            [ timestring(tstamp) for tstamp in unique_days ])
