#!/usr/bin/python
import sys
from datetime import datetime

try:
    f = open(sys.argv[1],'r')
    readFile = True
except IndexError:
    f = sys.stdin
    readFile = False
except IOError:
    sys.exit('File not found: '+sys.argv[1])

starttime = -1
endtime = -1
for line in f:
    if 'Started' in line: starttime = line.split(' at ')[1]
    elif 'finished' in line: endtime = line.split(' at ')[1]
if starttime < 0: 
    if readFile: sys.exit('No logged output read from '+sys.argv[1])
    else: sys.exit('No logged output read from stdin')
try: f.close()
except: pass

starttime = starttime.split()
starttime = ' '.join(starttime[:4]+[starttime[-1]])
if endtime > 0:
    endtime = endtime.split()
    endtime = ' '.join(endtime[:4]+[endtime[-1]])
    delta = datetime.strptime(endtime,'%c') - datetime.strptime(starttime,'%c')
    deltaT = delta.seconds
else:
    endtime = 'DNF'
    deltaT = -1

print 'START:',starttime
print '  END:',endtime
print 'DELTA:',deltaT,'s'

