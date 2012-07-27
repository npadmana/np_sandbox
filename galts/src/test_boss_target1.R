library("ProjectTemplate")
load.project()

library(bitops)

test1 <- function (galtype) {
  type1 <- boss.galTypes[[galtype]]
  flagval <- boss.Flagname2Val(type1$name, boss.target1)
  arr1 <- spall[bitAnd(spall$TARGET1, flagval) > 0, ]
  type1$func(arr1)
  col <- paste("is.",galtype,sep="")
  setnames(arr1, col, "is.galtype")
  
  # Make the plot
  gg <- ggplot(arr1, aes(x=factor(CHUNK, 
                                  levels=paste("boss", seq(1:30), sep=""), ordered=TRUE), 
                         fill=factor(is.galtype, levels=c(TRUE, FALSE))))
  gg <- gg + geom_bar(position="fill") + scale_x_discrete("Chunk") + 
    scale_y_continuous("Fraction") + scale_fill_discrete(paste("Is",galtype,"?"))
  myopts <- opts(axis.text.x=theme_text(angle=90.0))
  return(gg + myopts)
}

ggsave(filename="graphs/test_spall_lowz.png", plot=test1("LOWZ"))
ggsave(filename="graphs/test_spall_cmass.png", plot=test1("CMASS"))
ggsave(filename="graphs/test_spall_sparse.png", plot=test1("SPARSE"))





