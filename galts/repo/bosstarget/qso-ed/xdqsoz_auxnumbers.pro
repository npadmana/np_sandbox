;+
; Runs the numbers for the auxilary data
;-
PRO XDQSOZ_AUXNUMBERS, altqso=altqso, cutmi=cutmi, galex=galex, ukidss=ukidss, $
                       mihist=mihist, overplot=overplot, color=color
;;Get quasars
IF keyword_set(altqso) THEN BEGIN
    qso= xdqsoz_read_altquasars()
ENDIF ELSE BEGIN
    qso= mrdfits('$BOVYQSOEDDATA/qso_all_extreme_deconv.fits.gz',1)
    ;qso= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
ENDELSE
IF keyword_set(altqso) THEN mi= sdss_flux2mags(sdss_deredden(qso.psfflux[3],qso.extinction[3]),1.8) ELSE mi= sdss_flux2mags(qso.psfflux[3],1.8)
IF keyword_set(cutmi) THEN BEGIN
    qso= qso[where(mi GE 17.75 and mi LE 22.45)]
    mi= mi[where(mi GE 17.75 and mi LE 22.45)]
ENDIF
nqso= n_elements(qso.ra)
get_qso_fluxes, qso, flux, flux_ivar, weight, /allz
;;Add GALEX or UKIDSS data
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


;;print statistics on how many objects have FUV/NUV, YJHK
missing_value= 1./1d5
IF keyword_set(galex) THEN BEGIN
    indx= where(flux_ivar[6,*] NE missing_value,nfuv)
    indx= where(flux_ivar[5,*] NE missing_value,nnuv)
    IF keyword_set(ukidss) THEN BEGIN
        indx= where(flux_ivar[7,*] NE missing_value,ny)
        indx= where(flux_ivar[8,*] NE missing_value,nj)
        indx= where(flux_ivar[9,*] NE missing_value,nh)
        indx= where(flux_ivar[10,*] NE missing_value,nk)
    ENDIF
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    indx= where(flux_ivar[5,*] NE missing_value,ny)
    indx= where(flux_ivar[6,*] NE missing_value,nj)
    indx= where(flux_ivar[7,*] NE missing_value,nh)
    indx= where(flux_ivar[8,*] NE missing_value,nk)
ENDIF
IF keyword_set(galex) THEN BEGIN
    print, nfuv, 'objects with FUV'
    print, nnuv, 'objects with NUV'
ENDIF
IF keyword_set(ukidss) THEN BEGIN
    print, ny, 'objects with Y'
    print, nj, 'objects with J'
    print, nh, 'objects with H'
    print, nk, 'objects with K'
ENDIF

;;Now look at the magnitude distributions

;;Restrict the sample to those objects that have all fluxes
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
        ;print, strtrim(string(cnt),2)+" objects"
    endif
ENDIF

print, nqso, 'objects'
print, mean(mi), 'mean i-band magnitude'
print, minmax(mi), 'minmax i-band magnitude'

if keyword_set(mihist) then begin
    hogg_plothist, mi, xrange=[17.75,22.], /dontplot, xvec=xvec, hist=hist
    hist/= total(hist)*(xvec[1]-xvec[0])
    IF keyword_set(overplot) THEN djs_oplot, xvec, hist, color=color ELSE djs_plot, xvec, hist, color=color
endif
END
