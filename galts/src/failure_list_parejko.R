# Generate a list of galaxies in spAll that do not match the 
# TS cuts
# 
# Author: npadmana
###############################################################################

library("ProjectTemplate")
load.project()
library(bitops)


flagval <- boss.Flagname2Val("GAL_LOZ", boss.target1)
lowz <- (bitAnd(spall$TARGET1, flagval) > 0) & (!spall$is.LOWZ)

flagval <- boss.Flagname2Val("GAL_CMASS", boss.target1)
cmass <- (bitAnd(spall$TARGET1, flagval) > 0) & (!spall$is.CMASS)

arr1 <- spall[(lowz|cmass) & (spall$CHUNK != "boss1") & (spall$CHUNK != "boss2") & 
				(spall$SPECPRIMARY==1) & (spall$ZWARNING_NOQSO==0), 
		 list(CHUNK, PLATE, MJD, FIBERID, PLUG_RA, PLUG_DEC, RUN, FIELD, CAMCOL, ID, is.LOWZ, is.CMASS, TARGET1)]
 

write.table(arr1, "cache/parejko.txt", row.names=FALSE) 
 