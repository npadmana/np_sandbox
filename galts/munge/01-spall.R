# Reads in the spall data file, munges it and then caches it
# 
# Author: npadmana
###############################################################################

spall <- boss.ComputeAuxColors(spall)
boss.SelectLOWZ(spall)
boss.SelectCMASS(spall)
boss.SelectSPARSE(spall)

cache('spall')