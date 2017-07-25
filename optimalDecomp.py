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
    if len(sys.argv) <= 1:
        sys.exit('USAGE: '+sys.argv[0]+' Nx Ny Nz [N]')
    Nx = int(sys.argv[1])
    Ny = int(sys.argv[2])
    Nz = int(sys.argv[3])
    if len(sys.argv) > 4:
        N = int(sys.argv[4])
        print optimal_decomp(N,Nx,Ny,Nz)
    else:
        ppn = 24
        Ncells = Nx*Ny*Nz
        for cells_per_proc in np.arange(3,10)*1e4:
            Nnodes = int((Ncells / cells_per_proc) / ppn)
            N = Nnodes * ppn
           #print 'nnodes, ppn =',Nnodes,ppn
           #print 'nprocs =',N
           #print 'procs/node =',Ncells/N
            print N,'Nnodes=',Nnodes,' partions:',optimal_decomp(N,Nx,Ny,Nz),' procs/node =',Ncells/N

