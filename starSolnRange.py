#!/usr/bin/python
import os
import glob
solndir = '.'
prefixes = ['case','geo','VolumeFractionWater']
min = 0
max = 15000

filelist = []
for prefix in prefixes:
    filelist += glob.glob(solndir+os.sep+'*.'+prefix)
#print filelist

s = ''
for file in filelist:
    time = int(file.split('@')[1][:5])
    #print file,time
    if time >= min and time <= max: s += ' ' + file

print s
