;+
;   NAME:
;      xdqsoz_plotprediction
;   PURPOSE:
;      plot predictions for quasar redshifts from XDQSOz
;   INPUT:
;      indx - index in the relevant array
;   OPTIONAL INPUT:
;      plotfile - if set, send plot to this file
;     yrange - yrange to use
;   KEYWORDS:
;      altqso - use alternative quasar sample (NOT IMPLEMENTED YET)
;   OUTPUT:
;      plot to output device or saved
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;-
PRO XDQSOZ_PLOTPREDICTION, indx, plotfile=plotfile, yrange=yrange, $
                           altqso=altqso, uvdata=uvdata, nirdata=nirdata, $
                           dump=dump
IF ~keyword_set(yrange) THEN yrange=[0.,10.]
legendcharsize= 1.2
charsize=1.1
;;load quasar
IF keyword_set(altqso) THEN BEGIN
    qso= xdqsoz_read_altquasars()
ENDIF ELSE BEGIN
    qso= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
ENDELSE
IF keyword_set(altqso) THEN mi= sdss_flux2mags(sdss_deredden(qso.psfflux[3],qso.extinction[3]),1.8) ELSE mi= sdss_flux2mags(qso.psfflux[3],1.8)
qso= qso[where(mi GE 17.75 and mi LE 22.45)]
mi= mi[where(mi GE 17.75 and mi LE 22.45)]
qso= qso[indx]
IF keyword_set(altqso) THEN extinction= qso.extinction ELSE extinction= dblarr(5)
;;load zpdf
xdqsoz_zpdf, sdss_deredden(qso.psfflux,extinction),$
  sdss_deredden_error(qso.psfflux_ivar,extinction),$
  zmean=zmean,zcovar=zcovar,$
  zamp=zamp
nzs= 1001
zs= dindgen(nzs)/(nzs-1.)*5.2+0.3
zpdf= eval_xdqsoz_zpdf(zs,zmean,zcovar,zamp)
zpdf/= total(zpdf)*(zs[1]-zs[0])
IF keyword_set(dump) THEN BEGIN
    dumpStruct= {zs:zs, $
                 sdss:zpdf, $
                 galex:dblarr(nzs), $
                 ukidss:dblarr(nzs),$
                 galexukidss:dblarr(nzs)}
ENDIF
IF keyword_set(plotfile) THEN k_print, filename=plotfile
djs_plot, zs, zpdf, xrange=[0.,5.5],yrange=yrange, $
  position=[.2,.7375,.9,.95], xtickformat='(A1)',$
  charsize=charsize
oplotbarx, qso.z, color=djs_icolor('gray'),thick=4
djs_oplot, [0.,5.5],[1./5.2,1./5.2],color='gray'
legend, [strtrim(qso.oname,2),$
         'z = '+strtrim(string(qso.z,format='(F4.1)'),2),$
        textoidl('i_0 = ')+strtrim(string(mi[indx],format='(F4.1)'),2)], $
  box=0., /right,/top, charsize=legendcharsize
legend, ['SDSS ugriz'], box=0., /left, /top, charsize=legendcharsize
;;galex pdf
extinction= dblarr(n_elements(qso.psfflux[*]))
IF ~keyword_set(uvdata) THEN BEGIN
    IF keyword_set(altqso) THEN uvdata= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts_sdss_galex.fits',1) ELSE uvdata= mrdfits('$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits',1)
ENDIF
get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qso, $
  ngalexdata=ngalexdata, old=~keyword_set(altqso)
IF keyword_set(altqso) THEN BEGIN
    nuv= flux2mags(sdss_deredden(uvflux[0],uvextinction[0]))
    fuv= flux2mags(sdss_deredden(uvflux[1],uvextinction[1]))
    nuvsnr= sdss_deredden(uvflux[0],uvextinction[0])*sqrt(sdss_deredden_error(uvflux_ivar[0],uvextinction[0]))
    fuvsnr= sdss_deredden(uvflux[1],uvextinction[1])*sqrt(sdss_deredden_error(uvflux_ivar[1],uvextinction[1]))
ENDIF ELSE BEGIN
    nuv= flux2mags(uvflux[0])
    fuv= flux2mags(uvflux[1])
    nuvsnr= uvflux[0]*sqrt(uvflux_ivar[0])
    fuvsnr= uvflux[1]*sqrt(uvflux_ivar[1])
ENDELSE
nirflux= 0.
nirflux_ivar= 0.
nirextinction= 0.
combine_fluxes, qso.psfflux, qso.psfflux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  /uv, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
IF keyword_set(altqso) THEN BEGIN
    flux= sdss_deredden(outflux,outextinction)
    flux_ivar= sdss_deredden_error(outflux_ivar,outextinction)
ENDIF ELSE BEGIN
    flux= outflux
    flux_ivar= outflux_ivar
ENDELSE
xdqsoz_zpdf, flux,$
  flux_ivar,$
  zmean=zmean,zcovar=zcovar,$
  zamp=zamp, /galex
zpdf= eval_xdqsoz_zpdf(zs,zmean,zcovar,zamp)
zpdf/= total(zpdf)*(zs[1]-zs[0])
IF keyword_set(dump) THEN dumpStruct.galex= zpdf
djs_plot, zs, zpdf, $
  /noerase, position=[.2,.525,.9,.7375], xtickformat='(A1)', $
  yrange=yrange, charsize=charsize, xrange=[0.,5.5]
legend, ['+ GALEX UV'], box=0., /left, /top, charsize=legendcharsize
legend, [textoidl('NUV_0 = ')+strtrim(string(nuv,format='(F4.1)'),2), $
         textoidl('NUV SNR = ')+strtrim(string(nuvsnr,format='(F4.1)'),2), $
         textoidl('FUV SNR = ')+strtrim(string(fuvsnr,format='(F4.1)'),2)], $
  box=0., /right, $
  /top, charsize=legendcharsize
djs_oplot, [0.,5.5],[1./5.2,1./5.2],color='gray'
oplotbarx, qso.z, color=djs_icolor('gray'),thick=4
;;ukidss pdf
IF ~keyword_set(nirdata) THEN BEGIN
    IF keyword_set(altqso) THEN nirdata= mrdfits('$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits',1) ELSE nirdata= mrdfits('$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits',1)
ENDIF
get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qso
IF keyword_set(altqso) THEN BEGIN
    k= flux2mags(sdss_deredden(nirflux[3],nirextinction[3]))
    ksnr= sdss_deredden(nirflux[3],nirextinction[3])*sqrt(sdss_deredden_error(nirflux_ivar[3],nirextinction[3]))
    klabel= 'K_0 = '
ENDIF ELSE BEGIN
    k= flux2mags(nirflux[3])
    ksnr= nirflux[3]*sqrt(nirflux_ivar[3])
    klabel= 'K_0 = '
ENDELSE
uvflux= 0.
uvflux_ivar= 0.
uvextinction= 0.
combine_fluxes, qso.psfflux, qso.psfflux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  /nir, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
IF keyword_set(altqso) THEN BEGIN
    flux= sdss_deredden(outflux,outextinction)
    flux_ivar= sdss_deredden_error(outflux_ivar,outextinction)
ENDIF ELSE BEGIN
    flux= outflux
    flux_ivar= outflux_ivar
ENDELSE
xdqsoz_zpdf, flux,$
  flux_ivar,$
  zmean=zmean,zcovar=zcovar,$
  zamp=zamp,/ukidss
zpdf= eval_xdqsoz_zpdf(zs,zmean,zcovar,zamp)
zpdf/= total(zpdf)*(zs[1]-zs[0])
IF keyword_set(dump) THEN dumpStruct.ukidss= zpdf
djs_plot, zs, zpdf, /noerase, position=[.2,.3125,.9,.525], $
  yrange=yrange, xtickformat='(A1)', $
  charsize=charsize, xrange=[0.,5.5]
legend, ['+ UKIDSS NIR'], box=0., /left, /top, charsize=legendcharsize
legend, [textoidl(klabel)+strtrim(string(k,format='(F4.1)'),2), $
         textoidl('K SNR = ')+strtrim(string(ksnr,format='(F4.1)'),2)], $
  box=0., /right, charsize=legendcharsize, /top
djs_oplot, [0.,5.5],[1./5.2,1./5.2],color='gray'
oplotbarx, qso.z, color=djs_icolor('gray'),thick=4
;;all data
get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qso, $
  ngalexdata=ngalexdata, old=~keyword_set(altqso)
get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qso
combine_fluxes, qso.psfflux, qso.psfflux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  /nir,/uv, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
IF keyword_set(altqso) THEN BEGIN
    flux= sdss_deredden(outflux,outextinction)
    flux_ivar= sdss_deredden_error(outflux_ivar,outextinction)
ENDIF ELSE BEGIN
    flux= outflux
    flux_ivar= outflux_ivar
ENDELSE
xdqsoz_zpdf, flux,$
  flux_ivar,$
  zmean=zmean,zcovar=zcovar,$
  zamp=zamp,/ukidss, /galex
zpdf= eval_xdqsoz_zpdf(zs,zmean,zcovar,zamp)
zpdf/= total(zpdf)*(zs[1]-zs[0])
IF keyword_set(dump) THEN BEGIN
    dumpStruct.galexukidss= zpdf
    mwrfits, dumpStruct, dump, /create
ENDIF
djs_plot, zs, zpdf, /noerase, position=[0.2,.1,.9,.3125], $
  xtitle='redshift', yrange=yrange, xrange=[0.,5.5]
legend, ['+ GALEX UV + UKIDSS NIR'], box=0., /left, /top, charsize=legendcharsize
djs_oplot, [0.,5.5],[1./5.2,1./5.2],color='gray'
oplotbarx, qso.z, color=djs_icolor('gray'),thick=4
xyouts, -0.5, yrange[1]+(yrange[1]-yrange[0])/2., $
  'p(redshift)', orientation=90., charsize=charsize*1.7
IF keyword_set(plotfile) THEN k_end_print
END
