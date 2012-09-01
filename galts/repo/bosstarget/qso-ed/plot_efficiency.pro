;+
;   NAME:
;      plot_efficiency
;   PURPOSE:
;      plot the efficiency as a function of the number of targets
;   INPUT:
;      plotfile - filename for plot
;   OUTPUT:
;      plot in plotfile
;   HISTORY:
;      2010-09-01 - Written - Bovy (NYU)
;-
PRO PLOT_EFFICIENCY, plotfile, boss11=boss11

;;Restore XD probabilities for chunk 1 and 2
IF keyword_set(boss11) THEN chunkone= mrdfits('chunk11_extreme_deconv_HRH07.fits',1) ELSE chunkone= mrdfits('chunk1_extreme_deconv_HRH07.fits',1)
chunktwo= mrdfits('chunk2_extreme_deconv_HRH07.fits',1)
;;Sort
sortindx_one= REVERSE(SORT(chunkone.pqso))
sortindx_two= REVERSE(SORT(chunktwo.pqso))
;;Areas
specarea_two= 95.7
area_two= 143.66
;;Data
IF keyword_set(boss11) THEN BEGIN
    specarea_one= 205.12825
    area_one= specarea_one
    dataone= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
ENDIF ELSE BEGIN
    specarea_one= 81.2
    area_one= 219.93
    dataone= mrdfits('$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits',1)
ENDELSE
datatwo= mrdfits('$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits',1)

xs= dindgen(1001)/1000*80.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sortindx_one[0:floor(xs[ii]*area_one)]
    ysone[ii]= n_elements(where(dataone[targetindx].zem GE 2.2 and dataone[targetindx].zem LE 3.5))/specarea_one
    targetindx= sortindx_two[0:floor(xs[ii]*area_two)]
    ystwo[ii]= n_elements(where(datatwo[targetindx].zem GE 2.2 and datatwo[targetindx].zem LE 3.5))/specarea_two
ENDFOR

;;Plot
k_print, filename=plotfile+'.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='# quasar [deg^{-2}]',linestyle=0
djs_oplot, xs, ystwo, linestyle=1

;;add 20 and 40 lines
djs_oplot, [20.,20.], [0.,ysone[250]]
djs_oplot, [20.,0.], [ysone[250],ysone[250]]
djs_oplot, [40.,40.], [0.,ysone[500]]
djs_oplot, [40.,0.], [ysone[500],ysone[500]]

djs_oplot, [20.,20.], [0.,ystwo[250]], linestyle=1
djs_oplot, [20.,0.], [ystwo[250],ystwo[250]], linestyle=1
djs_oplot, [40.,40.], [0.,ystwo[500]], linestyle=1
djs_oplot, [40.,0.], [ystwo[500],ystwo[500]], linestyle=1

;;add legend
legend, ['BOSS area 1', 'BOSS area 2'], $
  linestyle=indgen(2), /right, /bottom, box=0.,charsize=1.1
k_end_print



;;Also plot derivative of efficiency
;;Plot
ysone= smooth(deriv(xs,ysone),250/5,/edge_truncate)
ystwo= smooth(deriv(xs,ystwo),250/5,/edge_truncate)
k_print, filename=plotfile+'_deriv.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='d # quasar / d # targets',linestyle=0, yrange=[0.,1.]
djs_oplot, xs, ystwo, linestyle=1

;;add legend
legend, ['BOSS area 1', 'BOSS area 2'], $
  linestyle=indgen(2), /right, /top, box=0.,charsize=1.1
k_end_print

END
