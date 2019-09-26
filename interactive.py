#!/usr/bin/env python
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--account',metavar='account',type=str,default='mmc')
parser.add_argument('--time',metavar='time',type=str,default='30')
parser.add_argument('--nodes',metavar='nodes',type=int,default=1)
args = parser.parse_args()

print('srun --time={:s} --account={:s} --nodes={:d} --pty {:s}'.format(
        args.time, args.account, args.nodes, os.environ['SHELL']))
