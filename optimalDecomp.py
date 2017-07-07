#!/usr/bin/env python
#
# Brute force approach to finding the optimal decomposition given
# a number of processors and domain dimensions
#
# Eliot Quon
import numpy as np

def optimal_decomp(N,Lx,Ly,Lz):
    # N: # of total processors
    # Lx: domain length in x
    # Ly: domain length in y
    # Lz: domain length in z
    factors = []
    for f in range(2,N):
        if N % f == 0:
            factors.append(f)
    combos = []
    for f1 in factors:
        for f2 in factors:
            f3 = float(N)/f1/f2
            if (f3 == int(f3)) and (f3 > 1):
                combos.append([f1,f2,int(f3)])
    Lvec = np.array([Lx,Ly,Lz])
    Lopt = N/np.prod(Lvec)
    deviation = []
    for decomp in combos:
        cellsPerPlane = Lvec/np.array(decomp)
        deviation.append(np.std(cellsPerPlane))
    imin = np.argmin(deviation)
    return combos[imin]

#===========================================================
if __name__ == "__main__":
    import sys
    N = int(sys.argv[1])
    Lx = int(sys.argv[2])
    Ly = int(sys.argv[3])
    Lz = int(sys.argv[4])
    print optimal_decomp(N,Lx,Ly,Lz)
