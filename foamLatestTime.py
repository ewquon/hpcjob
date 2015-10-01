#!/usr/bin/python
import os
import sys

searchPath='.'
if len(sys.argv) > 1: 
    searchPath = sys.argv[1]
    if not os.path.exists(searchPath): sys.exit()


dirs = os.walk(searchPath).next()[1]

latestTime = -1
latestDir = ''
for d in dirs:
    try: 
        step = float(d) # need this to verify this is a time-step dir!
        #latestTime = max(latestTime,step)
        if step > latestTime:
            latestTime = step
            latestDir = d
    except ValueError: pass

#if latestTime > 0: print latestTime
#if latestTime > 0: print latestDir
if latestTime >= 0: print latestDir
