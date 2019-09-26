#!/usr/bin/env python
import sys,os
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--account',metavar='account',type=str,default='mmc')
parser.add_argument('--time',metavar='time',type=str,default='30')
parser.add_argument('--nodes',metavar='nodes',type=int,default=1)
args = parser.parse_args()

cmdlist = [
    'srun',
    '--time={:s}'.format(args.time),
    '--account={:s}'.format(args.account),
    '--nodes={:d}'.format(args.nodes),
    '--pty', os.environ['SHELL'],
] 
print(' '.join(cmdlist))

prompt = raw_input if (sys.version_info[0] < 3) else input
try:
    prompt('press enter to continue...\n')
except KeyboardInterrupt:
    pass
else:
    p = subprocess.Popen(cmdlist)
    p.wait()

