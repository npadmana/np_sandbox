PRO COMPARE_XD_COMBNN, plotfile, mix=mix

;;Restore XD probabilities for ugriz and ugriz+ukidss
ugriz= mrdfits('chunk11_extreme_deconv_z4.fits',1)
ugriz_core= mrdfits('chunk11_extreme_deconv_HRH07.fits',1)
ukidss= mrdfits('chunk11_extreme_deconv_ukidss_ugriz.fits',1)
galex= mrdfits('chunk11_extreme_deconv_galex_ugriz.fits',1)
all= mrdfits('chunk11_extreme_deconv_galex_ukidss_ugriz.fits',1)
;;Areas
specarea= 205.12825
area= 205.12825
;;Data
data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
;;switch at i_0=20 mag to XD-ugriz
if keyword_set(mix) then begin
    prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
      mags=mags, var_mags=var_mags
    indx= where(mags[3,*] GT 21.5)
    ukidss[indx].pqso= ugriz[indx].pqso
    galex[indx].pqso= ugriz[indx].pqso
    all[indx].pqso= ugriz[indx].pqso
endif


;;NN
;;Erin's file
in=mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)
indx= where(in.inchunk EQ 1)
one= in[indx];;chunk1
spherematch, data.ra, data.dec, one.ra, one.dec, 2./3600., uindx, oindx
one= one[oindx]
sortindx_combnn= reverse(sort(one.nn_value))

;;Take out CORE
sortindx_ugriz= REVERSE(SORT(ugriz_core.pqso))
core_indx= sortindx_ugriz[0:floor(area*20.)-1]
incore= bytarr(n_elements(data.ra))
incore[core_indx]= 1B
noncore_ugriz= where(incore EQ 0B)
noncore_ukidss= where(incore EQ 0B)
noncore_galex= where(incore EQ 0B)
noncore_all= where(incore EQ 0B)
noncore_combnn= where(incore[uindx] EQ 0B)
;;Sort
sortindx_ugriz= REVERSE(SORT(ugriz[noncore_ugriz].pqso))
sortindx_ukidss= REVERSE(SORT(ukidss[noncore_ukidss].pqso))
sortindx_galex= REVERSE(SORT(galex[noncore_galex].pqso))
sortindx_all= REVERSE(SORT(all[noncore_all].pqso))
sortindx_combnn= REVERSE(SORT(one[noncore_combnn].nn_value))

;;Calculate efficiencies
xs= dindgen(1001)/1000*40.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
ysgalex= dblarr(nxs)
ysall= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= noncore_ugriz[sortindx_ugriz[0:floor(xs[ii]*area)]]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= noncore_ukidss[sortindx_ukidss[0:floor(xs[ii]*area)]]
    ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= noncore_galex[sortindx_galex[0:floor(xs[ii]*area)]]
    ysgalex[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= noncore_all[sortindx_all[0:floor(xs[ii]*area)]]
    ysall[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    targetindx= uindx[noncore_combnn[sortindx_combnn[0:floor(xs[ii]*area)]]]
    ysthree[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
ENDFOR

;;Plot
k_print, filename=plotfile
djs_plot, xs, ysall, xtitle='# BONUS targets [deg^{-2}]', ytitle='# quasar [deg^{-2}]',linestyle=0
djs_oplot, xs, ysone, linestyle=1
djs_oplot, xs, ysthree, linestyle=2
djs_oplot, xs, ystwo, linestyle=3
djs_oplot, xs, ysgalex, linestyle=4

;;add 20 lines
djs_oplot, [20.,20.], [0.,ysone[500]], linestyle=1
djs_oplot, [20.,0.], [ysone[500],ysone[500]], linestyle=1

djs_oplot, [20.,20.], [0.,ysall[500]], linestyle=0
djs_oplot, [20.,0.], [ysall[500],ysall[500]], linestyle=0

djs_oplot, [20.,20.], [0.,ysthree[500]], linestyle=2
djs_oplot, [20.,0.], [ysthree[500],ysthree[500]], linestyle=2

;;add legend
legend, ['XDQSO w/ UKIDSS+GALEX', 'XDQSO w/ UKIDSS',$
         'XDQSO w/ GALEX','XDQSO','NN Combinator'], $
  linestyle=[0,3,4,1,2], /right, /bottom, box=0.,charsize=1.1

k_end_print


END
