PRO COMPARE_XD_GALEX, plotfile, nocore=nocore

;;Restore XD probabilities
ugriz= mrdfits('chunk11_extreme_deconv_z4.fits',1)
IF keyword_set(nocore) THEN ugriz_core= mrdfits('chunk11_extreme_deconv_HRH07.fits',1)
galex= mrdfits('chunk11_extreme_deconv_galex_ugriz.fits',1)
;;Areas
specarea= 205.12825
area= 205.12825
;;Data
data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)

;;NN
;;Erin's file
;in=mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)
;indx= where(in.inchunk EQ 1)
;one= in[indx];;chunk1
;spherematch, data.ra, data.dec, one.ra, one.dec, 2./3600., uindx, oindx
;one= one[oindx]
;sortindx_combnn= reverse(sort(one.nn_value))

;;Take out CORE
IF keyword_set(nocore) THEN BEGIN
    sortindx_ugriz= REVERSE(SORT(ugriz_core.pqso))
    core_indx= sortindx_ugriz[0:floor(area*20.)-1]
    incore= bytarr(n_elements(data.ra))
    incore[core_indx]= 1B
    noncore_ugriz= where(incore EQ 0B)
    noncore_galex= where(incore EQ 0B)
ENDIF ELSE BEGIN
    noncore_ugriz= lindgen(n_elements(ugriz.pqso))
    noncore_galex= lindgen(n_elements(galex.pqso))
ENDELSE
;;Sort
sortindx_ugriz= REVERSE(SORT(ugriz[noncore_ugriz].pqso))
sortindx_galex= REVERSE(SORT(galex[noncore_galex].pqso))

;;Calculate efficiencies
xs= dindgen(1001)/1000*40.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ysgalex= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= noncore_ugriz[sortindx_ugriz[0:floor(xs[ii]*area)]]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= noncore_galex[sortindx_galex[0:floor(xs[ii]*area)]]
    ysgalex[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
ENDFOR

;;Plot
IF keyword_set(nocore) THEN xtitle= '# BONUS targets [deg^{-2}]' ELSE xtitle='# targets [deg^{-2}]'
k_print, filename=plotfile
djs_plot, xs, ysgalex, xtitle=xtitle, ytitle='# 2.2 \leq z \leq 4.0 quasar [deg^{-2}]',linestyle=0
djs_oplot, xs, ysone, linestyle=1

;;add 20 lines
djs_oplot, [20.,20.], [0.,ysone[500]], linestyle=1
djs_oplot, [20.,0.], [ysone[500],ysone[500]], linestyle=1

djs_oplot, [20.,20.], [0.,ysgalex[500]], linestyle=0
djs_oplot, [20.,0.], [ysgalex[500],ysgalex[500]], linestyle=0

;;add legend
legend, ['XDQSO w/ GALEX', 'XDQSO'], $
  linestyle=[0,1], /right, /bottom, box=0.,charsize=1.1

k_end_print


END
