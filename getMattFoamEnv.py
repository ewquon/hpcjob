#!/usr/bin/python
import sys

source='/home/mchurchf/.bash_profile'
user_settings = {'WM_PROJECT_USER_DIR': '$HOME/OpenFOAM/$USER-$OPENFOAM_VERSION'}

inFn = False
with open(source,'r') as f:
    for line in f:
        # skip comments
        if line.startswith('#'): continue

        # keep writing an openfoam function
        if inFn:
            # check for user-specific setting changes
            for envvar in user_settings.keys():
                if envvar+'=' in line:
                    idx = line.find(envvar+'=') + len(envvar) + 1
                    line = line[:idx] + user_settings[envvar] + '\n'
            sys.stdout.write( line )

            if line.strip()=='}':
                inFn = False
                print '' # for readability
            continue

        # found openfoam function
        if line.rstrip().endswith('()') and 'foam' in line.lower():
            inFn = True
            sys.stdout.write( line )

