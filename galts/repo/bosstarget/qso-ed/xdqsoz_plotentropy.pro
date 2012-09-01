;+
;   NAME:
;      xdqsoz_plotentropy
;   PURPOSE:
;      plot the KL divergence between p(z|flux) and p(z); also
;      calculates the KL divergence between p(z|SDSS) and
;      p(z|SDSS+GALEX) for galex and ukidss
;   INPUT:
;      plotfile - filename for plot
;      tmpfile= filename to store
;   KEYWORDS:
;      galex - use GALEX
;      ukidss - use UKIDSS
;      altqso - use alternative quasar sample
;      uniform - compare to uniform distribution
;   OUTPUT:
;      produces plot
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;-
PRO XDQSOZ_PLOTENTROPY, plotfile, tmpfile=tmpfile, $
                        galex=galex, ukidss=ukidss, $
                        altqso=altqso, uniform=uniform
IF ~keyword_set(seed) THEN seed= -1L
;;Get quasars
IF keyword_set(altqso) THEN BEGIN
    qso= xdqsoz_read_altquasars()
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
flux= outflux
flux_ivar= outflux_ivar
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
;;fix bad SDSS
indx= where(flux_ivar EQ 0.,cnt)
IF cnt gt 0 then flux_ivar[indx]= 1./1d5
IF ~file_test(tmpfile) THEN BEGIN
    entropy= dblarr(nqso)
    crossentropy= dblarr(nqso)
    for ii=0L, nqso-1 do begin
        print, format = '("Working on ",i7," of ",i7,a1,$)', $
          ii+1,nqso,string(13B)
        entropy[ii]= xdqsoz_calc_entropy(flux[*,ii],$
                                         flux_ivar[*,ii],$
                                         galex=galex,ukidss=ukidss,$
                                         uniform=uniform)
        if keyword_set(galex) or keyword_set(ukidss) then $
          crossentropy[ii]= xdqsoz_calc_entropy(flux[*,ii],$
                                                flux_ivar[*,ii],$
                                                galex=galex,ukidss=ukidss,$
                                                /cross)
;        print, qso[ii].z, entropy[ii], crossentropy[ii]
    endfor
    save, filename=tmpfile, entropy, crossentropy
ENDIF ELSE BEGIN
    restore, filename=tmpfile
ENDELSE

k_print, filename=plotfile
hogg_scatterplot, qso.z, entropy, /conditional, $
  xnpix=151, ynpix=151, $;/nogreyscale, $
  xtitle='redshift', ytitle='entropy', $
  xrange=[0.3,5.5];,yrange=[0.,10.]
k_end_print
END
