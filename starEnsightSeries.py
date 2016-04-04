#!/usr/local/bin/python
import sys
import glob,os

prefix = 'soln'
outfile = prefix+'_series.case'
verbose = False

N = 0
indices = []
first = True
solnvars = []
solntypes = dict()
for fname in glob.glob('*.case'):
    if fname==outfile: continue

    name,ext = os.path.splitext(fname)
    if first:
        for solnfile in glob.glob(name+'00000.*'):
            solnname,solnext = os.path.splitext(solnfile)
            varname = solnext[1:] #strip '.'
            if not varname=='geo':
                solnvars.append(varname)
        #print 'Solution variables:',solnvars
        with open(fname,'r') as f:
            for line in f:
                if 'per element' in line:
                    line = line.split()
                    varname = line[3]
                    vartype = line[0]
                    solntypes[varname] = vartype
        print 'Solution variables:',solntypes
        first = False

    idx = int(name.split('@')[1])
    indices.append(idx)
    with open(fname,'r') as f:
        found = False
        for line in f:
            if line.startswith('time values'): 
                found = True
                continue
            if found:
                tstr = line.strip()
                break
        try:
            tvals += '\n' + tstr
        except NameError:
            tvals = tstr
        if verbose: print idx,': t=',tstr
    N += 1

indices.sort()
delta = indices[1]-indices[0]
print 'time index range: [',indices[0],indices[-1],']  delta=',delta

filestr = """FORMAT
type: ensight gold
GEOMETRY
model: {prefix}@*****00000.geo
VARIABLE
{varstrs}
TIME
time set:               1
number of steps:        {nsteps:d}
filename start number:  {start:d}
filename increment:     {delta:d}
time values:
{timeValues}

#SCRIPTS
#metadata: starccmplus.xml"""

# varstrs:
#scalar per element: Pressure {prefix}@*****00000.Pressure
#scalar per element: VolumeFractionWater {prefix}@*****00000.VolumeFractionWater
#vector per element: Velocity {prefix}@*****00000.Velocity
varstrs = ''
for v in solnvars:
    #varstrs += 'scalar per element: ' + v + ' soln@*****00000.{}\n'.format(v)
    varstrs += '{vartype} per element: {varname} soln@*****00000.{varname}\n'.format(vartype=solntypes[v],varname=v)
    

with open(outfile,'w') as f:
    f.write(filestr.format(prefix=prefix, varstrs=varstrs, 
        nsteps=N, start=indices[0], 
        delta=delta, timeValues=tvals))
print 'wrote',outfile

