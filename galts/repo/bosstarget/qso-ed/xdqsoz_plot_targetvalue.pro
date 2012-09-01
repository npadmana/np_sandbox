PRO XDQSOZ_PLOT_TARGETVALUE, plotfile
effthick= 3.
legendcharsize=1.4
charsize=1.2
xrange=[0.,60.]
yrange=[0.,14.9999]
ywidth=0.4
xwidth= 0.4
;;restore
xdqsoz= mrdfits('chunk11_xdqsoz_z4.fits',1)
xdvalue= mrdfits('chunk11_xdqsoz_value.fits',1)
;;First calculate #QSOs
xs= dindgen(1001)/1000*(xrange[1]-xrange[0])+xrange[0]
nxs= n_elements(xs)
specarea= 205.12825
area= specarea
data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
v= calc_value(data.zem,sdss_flux2mags(sdss_deredden(data.psfflux[1],data.extinction[1]),0.9))
sortxdqsoz= reverse(sort(xdqsoz.pqso))
sortxdvalue= reverse(sort(xdvalue.value))
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
ysfour= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    ;;#QSOs
    targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= sortxdvalue[0:floor(xs[ii]*area)]
    ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    ;;value
    targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
    ysthree[ii]= total(v[targetindx])/specarea
    targetindx= sortxdvalue[0:floor(xs[ii]*area)]
    ysfour[ii]= total(v[targetindx])/specarea
ENDFOR
;;plot
k_print, filename=plotfile, ysize=15, xsize=15
djs_plot, xs, ysfour, ytitle='value for Ly\alpha BAF [deg^{-2}]', charsize=charsize, $
  yrange=[0.,11.9999], position=[0.1,0.1,0.1+xwidth,0.1+ywidth], xtitle='# targets [deg^{-2}]', $
  linestyle=0
djs_oplot, xs, ysthree, linestyle=2
djs_plot, xs, ysone, ytitle='# 2.2 !9l!x z !9l!x 4.0 quasar [deg^{-2}]', charsize=charsize, $
  yrange=[0.,19.99999], position=[0.1,0.1+ywidth,0.1+xwidth,0.1+2.*ywidth], xtickformat='(A1)', /noerase, linestyle=2
djs_oplot, xs, ystwo, linestyle=0
legend, [textoidl('expected value for Ly\alpha BAF'), $
         'straight P(2.2 !9l!x z !9l!x 4.0 quasar)'], $
  linestyle=[0,2], box=0.,/right,/bottom,$
  charsize=legendcharsize
END
