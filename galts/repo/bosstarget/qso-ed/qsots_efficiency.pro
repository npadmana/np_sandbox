;+
; Plot of efficiency of target selection
;-
PRO QSOTS_EFFICIENCY, plotfile, in=in, knownfirst=knownfirst
;;first load core
chunk11= mrdfits('chunk11_extreme_deconv_HRH07.fits',1)
sortindx_core= REVERSE(SORT(chunk11.pqso))
specarea_one= 205.12825
area_one= specarea_one
data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
xs_core= dindgen(501)/500*20.
nxs= n_elements(xs_core)
yscore= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sortindx_core[0:floor(xs_core[ii]*area_one)]
    yscore[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
ENDFOR
;;remove core
match, sortindx_core[floor(20.*area_one):n_elements(sortindx_core)-1], $
  lindgen(n_elements(data.ra)), $
  subsort, subchunk
chunk11= chunk11[subchunk]
data= data[subchunk]
;;now do BONUS, first single-epoch
;;Erin's file
if ~keyword_set(in) then in=mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)
;indx= where(in.inchunk EQ 1)
;one= in[indx];;chunk1
;;spherematch to chunk11
spherematch, in.ra, in.dec, data.ra, data.dec, 2./3600., $
  iindx, cindx
print, n_elements(iindx), n_elements(data.ra)
in= in[iindx]
chunk11= chunk11[cindx]
data= data[cindx]
;;run combinator
bqnn=obj_new('bosstarget_qsonn');;combinator
gmag = 22.5-2.5*alog10(data.psfflux[1] > 0.001) - data.extinction[1]
;;load XD with GALEX and UKIDSS
xdqso_bonus= mrdfits('chunk11_extreme_deconv_galex_ukidss_ugriz.fits',1)
xdqso_bonus= xdqso_bonus[subchunk]
xdqso_bonus= xdqso_bonus[cindx]
xdqso_bonus_sdss= mrdfits('chunk11_extreme_deconv_z4.fits',1)
xdqso_bonus_sdss= xdqso_bonus_sdss[subchunk]
xdqso_bonus_sdss= xdqso_bonus_sdss[cindx]
value_struct = bqnn->value_select(gmag, $
                                  in.like_ratio_core, $
                                  in.kde_prob, $
                                  in.nn_xnn, $
                                  in.nn_znn_phot, $
                                  xdqso_bonus_sdss.pqso, $
                                  xdqso_bonus.pqso, $
                                  lonarr(n_elements(chunk11.pqso))+1, $
                                  lonarr(n_elements(chunk11.pqso))+1)
;;sort
;print, minmax(value_struct.value), n_elements(where(value_struct.value GE 0.3))
sortindx_bonus= reverse(sort(value_struct.value_with_ed))
sortindx_bonus_aux= reverse(sort(value_struct.value_with_ed_ukidss))
xs_bonus= dindgen(501)/500*20.
nxs= n_elements(xs_bonus)
ysbonus= dblarr(nxs)
ysbonus_aux= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sortindx_bonus[0:floor(xs_bonus[ii]*area_one)]
    ysbonus[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
    targetindx= sortindx_bonus_aux[0:floor(xs_bonus[ii]*area_one)]
    ysbonus_aux[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
ENDFOR

;;plot
k_print, filename=plotfile
djs_plot, xs_core, yscore, xtitle='# targets [deg^{-2}]', $
  ytitle='# z !9b!x 2.2 quasars [deg^{-2}]', $
  xrange=[xs_core[0],xs_bonus[n_elements(xs_bonus)-1]+20.], $
  yrange= [0.,20.]
print, yscore[-1]
if keyword_set(knownfirst) then begin
   ;;known: 0.9 fibers, 0.9 quasars
    djs_oplot, [20.,20.9], $
      [yscore[n_elements(yscore)-1],yscore[n_elements(yscore)-1]+0.9]
    ;;first: 0.66 fibers, 0.33 quasars
    djs_oplot, [20.9,20.9+0.66], $
      [yscore[n_elements(yscore)-1]+0.9,yscore[n_elements(yscore)-1]+0.9+0.33]
    bonusstartx= 20.9+0.66
    bonusstarty= yscore[n_elements(yscore)-1]+0.9+0.33
    djs_oplot, xs_bonus+bonusstartx, bonusstarty+ysbonus/ysbonus[n_elements(ysbonus)-1]*(ysbonus[n_elements(ysbonus)-1]-.8)
    djs_oplot, [20.9+0.66,20.9+0.66], [0.,20.], linestyle=2
    print, bonusstarty+ysbonus[-1]/ysbonus[n_elements(ysbonus)-1]*(ysbonus[n_elements(ysbonus)-1]-.8)
endif else begin
    bonusstartx= 20.
    bonusstarty= yscore[n_elements(yscore)-1]
    djs_oplot, xs_bonus+bonusstartx, ysbonus+bonusstarty
endelse
djs_oplot, [20.,20.], [0.,20.], linestyle=2
djs_oplot, [0.,40.], [15.,15.], linestyle=0, color='gray'
xyouts, 2., 1., 'CORE', charsize=1.4
xyouts, 32.75, 1., 'BONUS', charsize=1.4
plots, [17.,20.45], [yscore[n_elements(yscore)-1]+.45,yscore[n_elements(yscore)-1]+.45]
xyouts, 11., 11., 'KNOWN', charsize=1.4
plots, [23.75,20.9+.33], [11.25,yscore[n_elements(yscore)-1]+.9+.33/2.]
xyouts, 24.25, 11., 'FIRST', charsize=1.4
;xyouts, 0.25, 15.15, 'BOSS goal', charsize=1.4
if ~keyword_set(knownfirst) then begin
    djs_oplot, xs_bonus+20., ysbonus_aux+yscore[n_elements(yscore)-1]
    xyouts, 22.5, 18., '+ UV & NIR', charsize=1.4
endif
k_end_print

;s82= mrdfits('star82-varcat-bound-ts.fits',1)

END
