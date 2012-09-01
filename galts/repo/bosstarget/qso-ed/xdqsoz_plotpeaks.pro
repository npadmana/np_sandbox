;+
;   NAME:
;      xdqsoz_plotpeaks
;   PURPOSE:
;      plot the average number of peaks in zPDF; also calculates MAP z
;   INPUT:
;      plotfile - filename for plot
;      tmpfile= filename to store
;   KEYWORDS:
;      galex - use GALEX
;      ukidss - use UKIDSS
;      altqso - use alternative quasar sample
;      testqso - use testqso sample
;      nolabels - don't put any labels
;      intprob - if set, define peaks as integrated_probability > intprob
;   OUTPUT:
;      produces plot
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;      2011-09-18 - Added intprob - Bovy (NYU)
;-
PRO XDQSOZ_PLOTPEAKS, plotfile, tmpfile=tmpfile, $
                      galex=galex, ukidss=ukidss, $
                      altqso=altqso, testqso=testqso, $
                      nolabels=nolabels, _EXTRA=_EXTRA, $
                      legendcharsize=legendcharsize, sdssav=sdssav, $
                      intprob=intprob
IF ~keyword_set(legendcharsize) THEN legendcharsize=1.4
;;Get quasars
IF keyword_set(altqso) THEN BEGIN
    qso= xdqsoz_read_altquasars()
ENDIF ELSE IF keyword_set(testqso) THEN BEGIN
    qso= mrdfits('$BOVYQSOEDDATA/qso_all_extreme_deconv_10.fits',1)
    print, "HAVE YOU SWITCHED THE SAVEFILES TO POINT TO THE POINT9 FILES"
ENDIF ELSE BEGIN
    qso= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
ENDELSE
IF keyword_set(altqso) THEN mi= sdss_flux2mags(sdss_deredden(qso.psfflux[3],qso.extinction[3]),1.8) ELSE mi= sdss_flux2mags(qso.psfflux[3],1.8)
qso= qso[where(mi GE 17.75 and mi LE 22.45)]
mi= mi[where(mi GE 17.75 and mi LE 22.45)]
nqso= n_elements(qso.ra)
;;Add GALEX or UKIDSS data
flux= qso.psfflux
flux_ivar= qso.psfflux_ivar
IF keyword_set(altqso) THEN extinction= qso.extinction ELSE extinction= dblarr(n_elements(flux[*,0]),n_elements(flux[0,*]))
IF keyword_set(ukidss) THEN BEGIN
    IF keyword_set(altqso) THEN nirdata= mrdfits('$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits',1) ELSE nirdata= mrdfits('$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits',1)
    get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qso
ENDIF ELSE BEGIN
    nirflux= 0.
    nirflux_ivar= 0.
    nirextinction= 0.
ENDELSE
IF keyword_set(galex) THEN BEGIN
    IF keyword_set(altqso) THEN uvdata= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts_sdss_galex.fits',1) ELSE uvdata= mrdfits('$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits',1)
    get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qso, $
      ngalexdata=ngalexdata, old=~keyword_set(altqso)
ENDIF ELSE BEGIN
    uvflux= 0.
    uvflux_ivar= 0.
    uvextinction= 0.
    ngalexdata= 0
ENDELSE
combine_fluxes, flux, flux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
IF keyword_set(altqso) THEN BEGIN
    flux= sdss_deredden(outflux,outextinction)
    flux_ivar= sdss_deredden_error(outflux_ivar,outextinction)
ENDIF ELSE BEGIN
    flux= outflux
    flux_ivar= outflux_ivar
ENDELSE
;;Restrict the sample to those objects that have all fluxes
missing_value= 1./1d5
IF keyword_set(galex) THEN BEGIN
    IF keyword_set(ukidss) THEN BEGIN
        indx= where(flux_ivar[5,*] NE missing_value and $
                    flux_ivar[6,*] NE missing_value and $
                    flux_ivar[7,*] NE missing_value and $
                    flux_ivar[8,*] NE missing_value and $
                    flux_ivar[9,*] NE missing_value and $
                    flux_ivar[10,*] NE missing_value,cnt)
    ENDIF ELSE BEGIN
        indx= where(flux_ivar[5,*] NE missing_value and $
                    flux_ivar[6,*] NE missing_value,cnt)
    ENDELSE
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    indx= where(flux_ivar[5,*] NE missing_value and $
                flux_ivar[6,*] NE missing_value and $
                flux_ivar[7,*] NE missing_value and $
                flux_ivar[8,*] NE missing_value,cnt)
ENDIF
IF keyword_set(galex) OR keyword_set(ukidss) THEN BEGIN
    if cnt gt 0 then begin
        qso= qso[indx]
        flux= flux[*,indx]
        flux_ivar= flux_ivar[*,indx]
        mi= mi[indx]
        nqso= cnt
        print, strtrim(string(cnt),2)+" objects"
    endif
ENDIF
IF ~file_test(tmpfile) THEN BEGIN
    peaks= dblarr(nqso)
    peakz= dblarr(nqso)
    for ii=0L, nqso-1 do begin
        print, format = '("Working on ",i7," of ",i7,a1,$)', $
          ii+1,nqso,string(13B)
        peaks[ii]= xdqsoz_peaks(flux[*,ii],flux_ivar[*,ii],$
                                galex=galex,ukidss=ukidss,peakz=thispeakz,xdqsoz=xdqsoz)
        peakz[ii]= thispeakz
        if keyword_set(intprob) then begin
            thispeaks= 0.
            for jj=0L, n_elements(xdqsoz.otherprob)-1 do begin
                if xdqsoz.otherprob[jj] GE intprob then thispeaks+= 1
            endfor
            if xdqsoz.peakprob GE intprob then thispeaks+= 1
            peaks[ii]= thispeaks
        endif
    endfor
    save, filename=tmpfile, peaks,peakz
ENDIF ELSE BEGIN
    restore, filename=tmpfile
ENDELSE

;;Calculate average number of peaks in bins
npix= 101
zs= dindgen(npix+1)/npix*5.2+0.3
av= dblarr(npix)
for ii=0L, npix-1 do begin
    thisindx= where(qso.z GE zs[ii] and qso.z LT zs[ii+1],cnt)
    if cnt eq 0 then begin
        av[ii]= !VALUES.F_NAN
        continue
    endif
    av[ii]= mean(peaks[thisindx])
endfor

IF ~keyword_set(galex) and ~keyword_set(ukidss) and arg_present(sdssav) THEN sdssav= av

if keyword_set(galex) then begin
    if keyword_set(ukidss) then begin
        title= '+ GALEX UV+ UKIDSS NIR'
    endif else begin
        title= '+ GALEX UV'
    endelse
endif else if keyword_set(ukidss) then begin
    title= '+ UKIDSS NIR'
endif else begin
    title= 'SDSS ugriz'
endelse

IF ~keyword_set(nolabels) THEN k_print, filename=plotfile

IF keyword_set(nolabels) THEN BEGIN
    djs_plot, zs, av, $
      yrange=[0,3.], xrange=[0.,5.5], psym=10, _EXTRA=_EXTRA
    IF (keyword_set(galex) or keyword_set(ukidss)) and keyword_set(sdssav) THEN djs_oplot, zs, sdssav, color='gray',thick=3., psym=10
ENDIF ELSE BEGIN
    djs_plot, zs, av, $
      xtitle='redshift', ytitle='average number of peaks', $
      yrange=[0,3.], xrange=[0.,5.5], psym=10, title=title, charsize=1.2
ENDELSE
djs_oplot, [0.,5.5],[1.,1.],color='gray',thick=3
legend, [title], box=0.,/right,/top, charsize=legendcharsize
IF ~keyword_set(nolabels) THEN k_end_print
END
