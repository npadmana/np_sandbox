PRO XDQSOZ_PLOT_GALEXUKIDSS_SNR, plotfile
xrange=[0.,30.]
charsize=1.2
npix=101
thick=4.
k_print, filename=plotfile
qso= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
;mi= sdss_flux2mags(qso.psfflux[3],1.8)
;qso= qso[where(mi GE 17.75 and mi LE 22.45)]
;mi= mi[where(mi GE 17.75 and mi LE 22.45)]
nqso= n_elements(qso.ra)
;;Add GALEX and UKIDSS data
flux= qso.psfflux
flux_ivar= qso.psfflux_ivar
extinction= dblarr(n_elements(flux[*,0]),n_elements(flux[0,*]))
nirdata= mrdfits('$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits',1)
get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qso
uvdata= mrdfits('$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits',1)
get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qso, $
  ngalexdata=ngalexdata, old=~keyword_set(altqso)
combine_fluxes, flux, flux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  /nir,/uv, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
flux= outflux
flux_ivar= outflux_ivar
;;GALEX first
yrange=[0.,60000.]
;;Restrict the sample to those objects that have the relevant fluxes
;;FUV
missing_value= 1./1d5
indx= where(flux_ivar[6,*] NE missing_value,cnt);;FUV
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[6,indx]
    thisflux_ivar= flux_ivar[6,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.5,0.9,0.9]
djs_plot, xvec, hist, thick=thick, position=position, yrange=yrange, $
  xtickformat='(A1)', charsize=charsize, color='dark blue', linestyle=2, $
  ytickformat='(F6.0)', yticks=3, yminor=5
legend, ['GALEX','FUV','NUV'], box=0., textcolors=djs_icolor(['white','dark blue','cyan']),linestyle=[1,2,0], colors= djs_icolor(['white','dark blue','cyan']), charsize=1.5, /right,/bottom, thick=thick
legend, ['GALEX'], box=0., charsize=1.5, position=[16.7,22000.]
djs_oplot, [5.,5.],yrange, color='gray',thick=thick
;;NUV
indx= where(flux_ivar[5,*] NE missing_value,cnt)
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[5,indx]
    thisflux_ivar= flux_ivar[5,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.5,0.9,0.9]
djs_oplot, xvec, hist, thick=thick, color='cyan', linestyle=0
;;ADD LEGEND
;;UKIDSS
yrange=[0.,30000.]
indx= where(flux_ivar[7,*] NE missing_value,cnt);;Y
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[7,indx]
    thisflux_ivar= flux_ivar[7,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.1,0.9,0.5]
djs_plot, xvec, hist, thick=thick, position=position, $
  charsize=charsize, color='orange', linestyle=1, $
  xtitle='signal-to-noise ratio', /noerase, yrange=yrange, $
  ytickformat='(F6.0)', yticks=3, yminor=5
xyouts, -7., 15000., $
  'cumulative distribution', charsize=1.5*charsize, orientation=90
legend, ['UKIDSS','Y','J','H','K'], box=0., textcolors=djs_icolor(['white','orange','magenta red','red','brown']),linestyle=[0,1,2,3,0], colors= djs_icolor(['white','orange','magenta red','red','brown']), charsize=1.5, /left,/top, thick=thick
legend, ['UKIDSS'], box=0., charsize=1.5, position=[.7,27800]
djs_oplot, [5.,5.],yrange, color='gray',thick=thick
;;J
indx= where(flux_ivar[8,*] NE missing_value,cnt)
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[8,indx]
    thisflux_ivar= flux_ivar[8,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.5,0.9,0.9]
djs_oplot, xvec, hist,thick=thick, color='magenta red', linestyle=2
;;H
indx= where(flux_ivar[9,*] NE missing_value,cnt)
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[9,indx]
    thisflux_ivar= flux_ivar[9,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.5,0.9,0.9]
djs_oplot, xvec, hist, thick=thick, color='red', linestyle=3
;;K
indx= where(flux_ivar[10,*] NE missing_value,cnt)
if cnt gt 0 then begin
    thisqso= qso[indx]
    thisflux= flux[10,indx]
    thisflux_ivar= flux_ivar[10,indx]
endif
hogg_plothist, thisflux*sqrt(thisflux_ivar), /dontplot, npix=npix, xrange=xrange, xvec=xvec, hist=hist, /totalweight
hist= total(hist,/cumul)
position=[0.1,0.5,0.9,0.9]
djs_oplot, xvec, hist, thick=thick, color='brown', linestyle=0
;;ADD LEGEND
k_end_print
END
