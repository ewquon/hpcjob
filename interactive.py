#!/usr/bin/env python
import sys,os
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--account',metavar='account',type=str,default='mmc')
parser.add_argument('--time',metavar='time',type=str,default='30')
parser.add_argument('--ntasks',metavar='ntasks',type=int,default=36)
parser.add_argument('--qos',metavar='qos',type=str,default='normal')
parser.add_argument('--mail',dest='mail',default=True,action='store_true')
parser.add_argument('--no-mail',dest='mail', action='store_false')
args = parser.parse_args()

cmdlist = [
    'srun',
    '--time={:s}'.format(args.time),
    '--account={:s}'.format(args.account),
    '--ntasks={:d}'.format(args.ntasks),
    '--qos={:s}'.format(args.qos),
]
if args.mail:
    cmdlist += [
        '--mail-type=BEGIN',
        '--mail-user=eliot.quon@nrel.gov',
    ]
cmdlist += ['--pty', os.environ['SHELL']]
print(' '.join(cmdlist))

prompt = raw_input if (sys.version_info[0] < 3) else input
try:
    prompt('press enter to continue...\n')
except KeyboardInterrupt:
    pass
else:
    p = subprocess.Popen(cmdlist)
    p.wait()

