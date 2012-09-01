;+
;   NAME:
;      plot_dndi
;   PURPOSE:
;      plot the number counts for different luminosity functions
;   INPUT:
;      lumfunc - luminosity function ('HRH07' or 'R06')
;      zmin, zmax
;   OPTIONAL INPUTS:
;      plotfilename - if set, save figure
;   KEYWORDS:
;      correct - if True, correct for incompleteness
;      attenuate - if set, attenuate the QSO number counts
;      everythingcorrect - correct the everything counts
;      overplot - if set, overplot
;      _EXTRA - plot inputs
;   OUTPUT:
;      plot in file if plotfilename is given
;   HISTORY:
;      2010-05-06 - Written - Bovy (NYU)
;-
PRO PLOT_DNDI, lumfunc, zmin, zmax, plotfilename=plotfilename, $
               correct=correct, attenuate=attenuate, $
               everythingcorrect=everythingcorrect, overplot=overplot, $
               _EXTRA=_EXTRA
filename= dndipath(ZMIN,ZMAX,lumfunc)
READ_DNDI, filename, i, dndi, correct=correct, attenuate=attenuate, $
               everythingcorrect=everythingcorrect
IF keyword_set(plotfilename) THEN k_print, filename=plotfilename
IF keyword_set(overplot) THEN djs_oplot, i, dndi, _EXTRA=_EXTRA ELSE $
  djs_plot, i, dndi, _EXTRA=_EXTRA 
IF keyword_set(plotfilename) THEN k_end_print
END
