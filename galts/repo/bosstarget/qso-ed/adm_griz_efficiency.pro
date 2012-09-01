PRO ADM_GRIZ_EFFICIENCY, plotfile, chunk=chunk
IF ~keyword_set(chunk) THEN chunk= 1
effthick= 3.
legendcharsize=1.4
charsize=1.05
xrange=[0.,60.]
yrange=[0.,19.9999]
xs= dindgen(1001)/1000*(xrange[1]-xrange[0])+xrange[0]
nxs= n_elements(xs)
IF chunk EQ 1 THEN BEGIN
    specarea= 205.12825
    area= specarea
    data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
    ;;restore probabilities
    ugriz= mrdfits('chunk11_extreme_deconv_HRH07.fits',1)
    griz= mrdfits('chunk11_extreme_deconv_griz.fits',1)
    NUVgriz= mrdfits('chunk11_extreme_deconv_NUVgriz.fits',1)
ENDIF ELSE IF chunk EQ 2 THEN BEGIN
    specarea= 95.7
    area= 143.66
    data= mrdfits('$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits',1)
    ;;restore probabilities
    ugriz= mrdfits('chunk2_extreme_deconv_HRH07.fits',1)
    griz= mrdfits('chunk2_extreme_deconv_griz.fits',1)
    NUVgriz= mrdfits('chunk2_extreme_deconv_NUVgriz.fits',1)
ENDIF
;;calculate efficiency
sortugriz= reverse(sort(ugriz.pqso))
sortgriz= reverse(sort(griz.pqso))
sortNUVgriz= reverse(sort(NUVgriz.pqso))
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sortugriz[0:floor(xs[ii]*area)]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
    targetindx= sortgriz[0:floor(xs[ii]*area)]
    ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
    targetindx= sortNUVgriz[0:floor(xs[ii]*area)]
    ysthree[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
ENDFOR
k_print, filename=plotfile
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', linestyle=0, $
  charsize=charsize, ytitle=' # 2.2 !9l!x z !9l!x 3.5 quasars [deg^{-2}]', $
  xrange=xrange, yrange=yrange
djs_oplot, xs, ystwo, linestyle=1
djs_oplot, xs, ysthree, linestyle=2
legend, ['ugriz','griz','NUVgriz'], box=0., charsize=legendcharsize, $
  /bottom, /right, linestyle=[0,1,2]
k_end_print
END
