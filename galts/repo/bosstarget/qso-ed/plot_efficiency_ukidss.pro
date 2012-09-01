;+
;   NAME:
;      plot_efficiency_ukidss
;   PURPOSE:
;      plot the efficiency as a function of the number of targets for SDSS+UKIDSS
;   INPUT:
;      plotfile - filename for plot
;   OUTPUT:
;      plot in plotfile
;   HISTORY:
;      2010-11-03 - Written - Bovy (NYU)
;-
PRO PLOT_EFFICIENCY_UKIDSS, plotfile

;;Restore XD probabilities for ugriz and ugriz+ukidss
chunkone= mrdfits('chunk11_extreme_deconv_z4.fits',1)
chunktwo= mrdfits('chunk11_extreme_deconv_ukidss_ugriz.fits',1)
chunkthree= mrdfits('chunk11_extreme_deconv_galex_ugriz.fits',1)
chunkfour= mrdfits('chunk11_extreme_deconv_galex_ukidss_ugriz.fits',1)
;;Sort
sortindx_one= REVERSE(SORT(chunkone.pqso))
sortindx_two= REVERSE(SORT(chunktwo.pqso))
sortindx_three= REVERSE(SORT(chunkthree.pqso))
sortindx_four= REVERSE(SORT(chunkfour.pqso))
;;Areas
specarea= 205.12825
area= 205.12825
specarea_two= 205.12825
area_two= 205.12825
;;Data
specarea_one= 205.12825
area_one= specarea_one
dataone= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
datatwo= dataone

xs= dindgen(1001)/1000*80.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
ysfour= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sortindx_one[0:floor(xs[ii]*area_one)]
    ysone[ii]= n_elements(where(dataone[targetindx].zem GE 2.2))/specarea_one
    targetindx= sortindx_two[0:floor(xs[ii]*area_two)]
    ystwo[ii]= n_elements(where(datatwo[targetindx].zem GE 2.2))/specarea_two
    targetindx= sortindx_three[0:floor(xs[ii]*area)]
    ysthree[ii]= n_elements(where(datatwo[targetindx].zem GE 2.2))/specarea
    targetindx= sortindx_four[0:floor(xs[ii]*area)]
    ysfour[ii]= n_elements(where(datatwo[targetindx].zem GE 2.2))/specarea
ENDFOR

;;Plot
k_print, filename=plotfile+'.ps'
djs_plot, xs, ysfour, xtitle='# targets [deg^{-2}]', ytitle='# z !9b!x 2.2 quasars [deg^{-2}]',linestyle=0, yrange=[0.,23.]
djs_oplot, xs, ysone, linestyle=1
djs_oplot, xs, ystwo, linestyle=2
djs_oplot, xs, ysthree, linestyle=3

;;add 20 and 40 lines
djs_oplot, [20.,20.], [0.,ysone[250]], linestyle=1
djs_oplot, [20.,0.], [ysone[250],ysone[250]], linestyle=1
djs_oplot, [40.,40.], [0.,ysone[500]], linestyle=1
djs_oplot, [40.,0.], [ysone[500],ysone[500]], linestyle=1

djs_oplot, [20.,20.], [0.,ysfour[250]], linestyle=0
djs_oplot, [20.,0.], [ysfour[250],ysfour[250]], linestyle=0
djs_oplot, [40.,40.], [0.,ysfour[500]], linestyle=0
djs_oplot, [40.,0.], [ysfour[500],ysfour[500]], linestyle=0

;;add legend
legend, ['single-epoch ugriz+UKIDSS+GALEX', $
         'single-epoch ugriz+UKIDSS','single-epoch ugriz+GALEX',$
         'single-epoch ugriz'], $
  linestyle=[0,2,3,1], /right, /bottom, box=0.,charsize=1.1
k_end_print

;;BOVY: EDIT BELOW

;;Also plot derivative of efficiency
;;Plot
ysone= smooth(deriv(xs,ysone),250/5,/edge_truncate)
ystwo= smooth(deriv(xs,ystwo),250/5,/edge_truncate)
k_print, filename=plotfile+'_deriv.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='d # quasar / d # targets',linestyle=1, yrange=[0.,1.]
djs_oplot, xs, ystwo, linestyle=0

;;add legend
legend, ['single-epoch ugriz+UKIDSS YJHK', 'single-epoch ugriz'], $
  linestyle=indgen(2), /right, /bottom, box=0.,charsize=1.1
k_end_print

END
