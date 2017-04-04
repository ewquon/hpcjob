#!/usr/bin/env python
import sys
import glob,os

#prefix = 'soln'
if len(sys.argv) == 1:
    print 'Specify an output prefix, e.g.:'
    print ' ',sys.argv[0],'soln'
    print 'for Ensight files of the form soln@12345.case'
    sys.exit()


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


prefix = sys.argv[1]
outfile = prefix+'_series.case'
verbose = False

if os.path.isfile(outfile):
    print 'Output case file already exists:',outfile
    sys.exit('Stopping now.')

N = 0
indices = []
first = True
solnvars = []
solntypes = dict()
print ''
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
        print 'Solution variables in casefiles:',solntypes
        first = False

    sys.stdout.write('\rProcessing '+name)

    try:
        idx = int(name.split('@')[1])
    except IndexError:
        print '\nProblem with file:',name
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
            #tvals += '\n' + tstr
            tvals.append(float(tstr))
        except NameError:
            #tvals = tstr
            tvals = [float(tstr)]
        if verbose: print idx,': t=',tstr
    N += 1
print ''

indices.sort()
tvals.sort()
delta = indices[1]-indices[0]
print 'Time index range: [',indices[0],indices[-1],']  delta=',delta
print 'Time range: [',tvals[0],tvals[-1],']'

# varstrs:
#scalar per element: Pressure {prefix}@*****00000.Pressure
#scalar per element: VolumeFractionWater {prefix}@*****00000.VolumeFractionWater
#vector per element: Velocity {prefix}@*****00000.Velocity
varstrs = ''
sys.stdout.write('Variables written out:')
for v in solnvars:
    #varstrs += 'scalar per element: ' + v + ' soln@*****00000.{}\n'.format(v)
    varstrs += '{vartype} per element: {varname} {prefix}@*****00000.{varname}\n'.format(
            prefix=prefix, vartype=solntypes[v], varname=v)
    sys.stdout.write(' {:s}'.format(v))
sys.stdout.write('\n')
    

with open(outfile,'w') as f:
    f.write(
        filestr.format(
            prefix=prefix,
            varstrs=varstrs, 
            nsteps=N,
            start=indices[0], 
            delta=delta,
            timeValues='\n'.join([str(t) for t in tvals]) #timeValues=tvals
        )
    )
print '*** Wrote',outfile,'***'

