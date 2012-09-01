;+
;   NAME:
;      compare_to_truth
;   PURPOSE:
;      evaluate how well the extreme deconvolution is doing in
;      recovering quasars
;   INPUT:
;      savefilename - filename that holds the ranking (and truth)
;      plotfilename - filename for the plot
;      zcuts - [zmin,zmax]
;      area - area of the region targeted
;      specarea - area of the region of spectroscopic confirmation
;   OUTPUT:
;      plot
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;-
PRO COMPARE_TO_TRUTH, savefilename=savefilename, plotfilename=plotfilename,$
                      zcuts=zcuts, area=area,title=title, specarea=specarea
IF ~keyword_set(title) THEN title= 'chunk 2'
IF ~keyword_set(area) THEN area= 143.66
IF ~keyword_set(specarea) THEN specarea= 95.7
IF ~keyword_set(zcuts) THEN zcuts= [2.2,3.5]
IF ~keyword_set(savefilename) THEN savefilename= 'chunk2_extreme_deconv.fits'
in=mrdfits(savefilename,1)
nfibers= 81
fibers= dindgen(81)
nqso= lonarr(81)
FOR ii=0L, nfibers-1 DO nqso[ii]= n_elements(where(in[0:floor(fibers[ii]*area)].z GT zcuts[0] AND in[0:floor(fibers[ii]*area)].z LT zcuts[1]))
IF keyword_set(plotfilename) THEN k_print, filename=plotfilename
djs_plot, fibers, nqso/specarea, xtitle='fibers per square degree',$
  ytitle='QSO per square degree',title=title

;;Efficiency
eff= dblarr(81)
FOR ii=0L, nfibers-1 DO eff[ii]= double(nqso[ii])/n_elements(where(in[0:floor(fibers[ii]*area)].z NE -10000.000))
djs_plot, fibers, eff, xtitle='fibers per square degree',$
  ytitle='efficiency',title=title

IF keyword_set(plotfilename) THEN k_end_print
END
