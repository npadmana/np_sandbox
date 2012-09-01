PRO XDQSOZ_PLOT_IMAG, plotfile, ngc=ngc, sgc=sgc
xdqsoz= mrdfits('$HOME/public_html/qsocat/xdqsoz_pqso0.5_imag21.5-nobadu.fits.gz',1)
xdqsoz= xdqsoz[where(xdqsoz.mask_out_legacy)]
savefile= 'xdqsoz_imag.fits'
if file_test(savefile) then begin
    restore, savefile
endif else begin
    out= xdqsoz_marginalize_colorzprob(0.00000001,2.,$
                                       xdqso_sdss_deredden(xdqsoz.psfflux,$
                                                           xdqsoz.extinction),$
                                       xdqso_sdss_deredden_error(xdqsoz.psfflux_ivar,$
                                                                 xdqsoz.extinction),$
                                       norm=totlike)
    plowz= out/totlike*xdqsoz.pqso
    out= xdqsoz_marginalize_colorzprob(2.,3.,$
                                       xdqso_sdss_deredden(xdqsoz.psfflux,$
                                                           xdqsoz.extinction),$
                                       xdqso_sdss_deredden_error(xdqsoz.psfflux_ivar,$
                                                                 xdqsoz.extinction),$
                                       norm=totlike)
    pmidz= out/totlike*xdqsoz.pqso
    phiz= xdqsoz.pqso-plowz-pmidz
    save, plowz, pmidz, phiz, filename=savefile
endelse
xdqsoz_low= xdqsoz[where(plowz GE 0.5)]
xdqsoz_mid= xdqsoz[where(pmidz GE 0.5)]
xdqsoz_hi= xdqsoz[where(phiz GE 0.5)]   
if keyword_set(ngc) then begin
    glactc, xdqsoz_low.ra, xdqsoz_low.dec, 2000., gl, gb, 1, /degree
    xdqsoz_low= xdqsoz_low[where(gb GE 0.)]
    glactc, xdqsoz_mid.ra, xdqsoz_mid.dec, 2000., gl, gb, 1, /degree
    xdqsoz_mid= xdqsoz_mid[where(gb GE 0.)]
    glactc, xdqsoz_hi.ra, xdqsoz_hi.dec, 2000., gl, gb, 1, /degree
    xdqsoz_hi= xdqsoz_hi[where(gb GE 0.)]
endif
if keyword_set(sgc) then begin
    glactc, xdqsoz_low.ra, xdqsoz_low.dec, 2000., gl, gb, 1, /degree
    xdqsoz_low= xdqsoz_low[where(gb LE 0.)]
    glactc, xdqsoz_mid.ra, xdqsoz_mid.dec, 2000., gl, gb, 1, /degree
    xdqsoz_mid= xdqsoz_mid[where(gb LE 0.)]
    glactc, xdqsoz_hi.ra, xdqsoz_hi.dec, 2000., gl, gb, 1, /degree
    xdqsoz_hi= xdqsoz_hi[where(gb LE 0.)]
endif
pcut=0.05
effthick= 3.
legendcharsize=1.4
charsize=1.2
xrange=[0.,60.]
yrange=[0.,14.9999]
ywidth=0.4
xwidth= 0.4
;;restore
cnt= n_elements(xdqsoz)
;;plot imag distribution
if keyword_set(ngc) then begin
    specarea= 7606.2721
endif else if keyword_set(sgc) then begin
    specarea= 3172.0344
endif else begin
    specarea= 7606.2721+3172.0344
endelse
k_print, filename=plotfile
hogg_plothist, xdqsoz_low.psfmag[3],xtitle='i [mag]', $
  weight=dblarr(cnt)+1./specarea, $
  xvec=xvec, hist=hist, xrange=[17.8,21.5], /dontplot, npix=38, err=err
;;plotting symbol
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, cos(phi), sin(phi), /fill
djs_plot, xvec, hist, psym=8, /ylog, xrange=[17.,23.],xtitle='i [mag]', $
  yrange=[0.1,100], ytitle='N(i) [mag^{-1} deg^{-2}]'
;oploterr, xvec, hist, err
rx= [17.725,17.975,18.225,18.475,18.725,18.975,19.225]
ry= 4.*[0.21,0.33,.55,.82,1.25,1.86,2.62]
djs_oplot, rx, ry, psym=4
;;hi
hogg_plothist, xdqsoz_hi.psfmag[3],xtitle='i [mag]', $
  weight=dblarr(cnt)+1./specarea, $
  xvec=xvec, hist=hist, xrange=[17.8,21.5], /dontplot, npix=38, err=err
djs_oplot, xvec, hist, psym=8, /ylog, xrange=[17.,23.],xtitle='i [mag]', $
  yrange=[0.1,100], ytitle='N(i) [mag^{-1} deg^{-2}]'
;oploterr, xvec, hist, err
rx= [17.725,17.975,18.225,18.475,18.725,18.975,19.225]
ry= 4.*[0.21,0.33,.55,.82,1.25,1.86,2.62]
djs_oplot, rx, ry, psym=4
rx= [17.825,18.075,18.325,18.575,18.825,19.075,19.325,19.575,19.825,20.075]
ry= 4.*[0.01,0.02,0.03,0.05,0.08,0.12,0.17,0.22,0.28,0.38]
djs_oplot, rx, ry, psym=4
;;mid
hogg_plothist, xdqsoz_mid.psfmag[3],xtitle='i [mag]', $
  weight=dblarr(cnt)+1./specarea, $
  xvec=xvec, hist=hist, xrange=[17.8,21.5], /dontplot, npix=38, err=err
djs_oplot, xvec, hist, psym=8, /ylog, xrange=[17.,23.],xtitle='i [mag]', $
  yrange=[0.1,100], ytitle='N(i) [mag^{-1} deg^{-2}]'
;oploterr, xvec, hist, err
;;label
charsize=1.26
xyouts, 21.6, 30., '0.3 < z < 2', charsize=charsize
xyouts, 21.6, 5., '2 < z < 3', charsize=charsize
xyouts, 21.6, 1., 'z > 3', charsize=charsize
legend, ['XDQSOz','SDSS-DR3'],box=0.,charsize=charsize,/top,/left,$
  psym=[8,4]
if keyword_set(ngc) then $
  legend, ['NGC'],box=0.,charsize=charsize,/bottom,/right
k_end_print
END
