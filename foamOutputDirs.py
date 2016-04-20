#!/usr/bin/python
import os
import sys

searchPath='.'
if len(sys.argv) > 1: 
    searchPath = sys.argv[1]
    if not os.path.exists(searchPath): sys.exit()


dirs = os.walk(searchPath).next()[1]

dirlist = []
numlist = []
for d in dirs:
    try: 
        step = float(d)
        numlist.append(step)
        dirlist.append(d)
    except ValueError: pass

# sort list of floats
indices = [i[0] for i in sorted(enumerate(numlist), key=lambda x:x[1])]

#print ' '.join(dirlist)
#print ' '.join([dirlist[i] for i in indices])
if len(dirlist) > 0:
    print ' '.join([dirlist[i] for i in indices]).strip()
