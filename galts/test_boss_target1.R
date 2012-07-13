# Test to see if CMASS in spAll is correctly set
library(ggplot2)
library(bitops)
source('~/myWork/nputils/R/BOSS/common.R')
source('~/myWork/nputils/R/BOSS/galtarget.R')

load("spall.xdr")

test1 <- function (galtype) {
  type1 <- boss.galTypes[[galtype]]
  flagval <- boss.Flagname2Val(type1$name, boss.target1)
  arr1 <- spall[bitAnd(spall$TARGET1, flagval) > 0, ]
  arr1 <- boss.ComputeAuxColors(arr1)
  arr1 <- type1$func(arr1)
  col <- paste("is.",galtype,sep="")
  names(arr1)[names(arr1) == col] <- "is.galtype"
  arr1[!is.finite(arr1$is.galtype), "is.galtype"] <- FALSE 
  
  gg <- ggplot(arr1, aes(x=factor(CHUNK, 
                                  levels=paste("boss", seq(1:30), sep=""), ordered=TRUE), 
                         fill=factor(is.galtype, levels=c(TRUE, FALSE))))
  gg <- gg + geom_bar(position="fill") + scale_x_discrete("Chunk") + 
    scale_y_continuous("Fraction") + scale_fill_discrete(paste("Is",galtype,"?"))
  myopts <- opts(axis.text.x=theme_text(angle=90.0))
  print(gg + myopts)
}






