# Test to see if CMASS in spAll is correctly set
library(ggplot2)
library(bitops)
source('~/myWork/nputils/R/BOSS/common.R')
source('~/myWork/nputils/R/BOSS/galtarget.R')

load("spall.xdr")
flagval <- boss.Flagname2Val("GAL_CMASS", boss.target1)
cmass1 <- spall[bitAnd(spall$TARGET1, flagval) > 0, ]
cmass1 <- boss.ComputeAuxColors(cmass1)
cmass1 <- boss.SelectCMASS(cmass1)
small <- cmass1[is.finite(cmass1$is.CMASS), 
                c("is.CMASS", "CHUNK", "PLUG_RA", "PLUG_DEC","PLATE", "FIBERID", "MJD")]


gg <- ggplot(small, aes(x=factor(CHUNK, 
                                 levels=paste("boss", seq(1:30), sep="")), 
                        fill=factor(is.CMASS, levels=c(TRUE, FALSE))))
gg <- gg + geom_bar(position="fill") + scale_x_discrete("Chunk") + 
  scale_y_continuous("Fraction") + scale_fill_discrete("Is CMASS?")
myopts <- opts(axis.text.x=theme_text(angle=90.0))
print(gg + myopts)





