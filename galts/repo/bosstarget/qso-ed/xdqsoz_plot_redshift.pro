PRO XDQSOZ_PLOT_REDSHIFT, plotfile, ngc=ngc, sgc=sgc
thick= 3.
xdqsoz= mrdfits('$HOME/public_html/qsocat/xdqsoz_pqso0.5_imag21.5-nobadu.fits.gz',1)
xdqsoz= xdqsoz[where(xdqsoz.mask_out_legacy)]
if keyword_set(ngc) then begin
    glactc, xdqsoz.ra, xdqsoz.dec, 2000., gl, gb, 1, /degree
    xdqsoz= xdqsoz[where(gb GE 0.)]
endif
if keyword_set(sgc) then begin
    glactc, xdqsoz.ra, xdqsoz.dec, 2000., gl, gb, 1, /degree
    xdqsoz= xdqsoz[where(gb LE 0.)]
endif
pcut=0.05
effthick= 3.
legendcharsize=1.4
charsize=1.2
cnt= n_elements(xdqsoz)
;;plot redshift distribution
k_print, filename=plotfile
hogg_plothist, xdqsoz.peakz,xtitle='redshift', $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=21, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
;;plotting symbol
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, cos(phi), sin(phi), /fill
djs_plot, xvec, hist, psym=8, xrange=[0.,6.],xtitle='redshift', $
  ytitle='XDQSOz redshift distribution', yrange=[0.,1.]
oploterror, xvec, hist, err, psym=3
;;imag ranges
npix=21
colors= ['brown','purple','dark blue','cyan','dark green','cyan green',$
         'magenta','dark yellow','orange','magenta red']
ilow= 18.2
ihigh= 18.4
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[1]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[1]), psym=3
basedir='$BOSSTARGET_DIR/data/qso-ed/zcounts/'
linestyles= lonarr(10)+0
in= mrdfits(basedir+'dndz_HRH07_18.2_i_18.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[1],linestyle=linestyles[1], thick=thick
ilow= 18.7
ihigh= 18.9
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[2]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[2]), psym=3
in= mrdfits(basedir+'dndz_HRH07_18.7_i_18.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[2],linestyle=linestyles[2], thick=thick
ilow= 19.2
ihigh= 19.4
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[3]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[3]), psym=3
in= mrdfits(basedir+'dndz_HRH07_19.2_i_19.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[3],linestyle=linestyles[3], thick=thick
ilow= 19.7
ihigh= 19.9
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[4]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[4]), psym=3
in= mrdfits(basedir+'dndz_HRH07_19.7_i_19.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[4],linestyle=linestyles[4], thick=thick
ilow= 20.2
ihigh= 20.4
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[5]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[5]), psym=3
in= mrdfits(basedir+'dndz_HRH07_20.2_i_20.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[5],linestyle=linestyles[5], thick=thick
ilow= 20.7
ihigh= 20.9
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[6]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[6]), psym=3
in= mrdfits(basedir+'dndz_HRH07_20.7_i_20.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[6],linestyle=linestyles[6], thick=thick
ilow= 21.2
ihigh= 21.4
xdqsoz_i= xdqsoz[where(xdqsoz.psfmag[3] GE ilow and xdqsoz.psfmag[3] LT ihigh)]
hogg_plothist, xdqsoz_i.peakz, $
  xvec=xvec, hist=hist, xrange=[0.3,5.5], /dontplot, npix=npix, err=err
norm= total(hist)*(xvec[1]-xvec[0])
hist/= norm
err/= norm
djs_oplot, xvec, hist, psym=8, color=colors[7]
oploterror, xvec, hist, err, errcolor=djs_icolor(colors[7]), psym=3
in= mrdfits(basedir+'dndz_HRH07_21.2_i_21.4.fits',1)
;in.dndz[where(in.z GE 2. and in.z LE 3.)]*= 0.5
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[7],linestyle=linestyles[7], thick=thick
legend, ['18.2 !9l!x i < 18.4', $
         '18.7 !9l!x i < 18.9', $
         '19.2 !9l!x i < 19.4', $
         '19.7 !9l!x i < 19.9', $
         '20.2 !9l!x i < 20.4', $
         '20.7 !9l!x i < 20.9', $
         '21.2 !9l!x i < 21.4'], $
  box= 0., textcolors=djs_icolor(colors[1:7]), $ ;linestyle=linestyles
  /top,/right, charsize=1.4
;;label
;charsize=1.26
;xyouts, 21.6, 30., '0.3 < z < 2', charsize=charsize
;xyouts, 21.6, 5., '2 < z < 3', charsize=charsize
;xyouts, 21.6, 1., 'z > 3', charsize=charsize
;legend, ['XDQSOz','SDSS-DR3'],box=0.,charsize=charsize,/top,/left,$
;  psym=[8,4]
if keyword_set(ngc) then $
  legend, ['NGC'],box=0.,charsize=charsize,/bottom,/right
k_end_print
END
