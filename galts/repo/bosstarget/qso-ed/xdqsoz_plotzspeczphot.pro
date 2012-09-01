;+
;   NAME:
;      xdqsoz_plotzspeczphot
;   PURPOSE:
;      plot the spectro-z vs. photo-z
;   INPUT:
;      plotfile=  filename for plot
;      tmpfile= filename to store (assumed to exist; calculate using
;               xdqsoz_plotpeaks)
;   OPTIONAL INPUT:
;      ilim - use i <= ilim
;      imin - use i > imin
;   KEYWORDS:
;      galex - use GALEX
;      ukidss - use UKIDSS
;      altqso - use alternative quasar sample
;      testqso - use test ten-percent quasar sample
;      onepeak - restrict the sample to single-peaked objects
;      hoggscatter - hogg_scatterplot
;      conditional - conditional hogg_scatterplot
;                    (hoggscatter must be set) 
;   OUTPUT:
;      produces plot
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;-
PRO XDQSOZ_PLOTZSPECZPHOT, plotfile=plotfile, tmpfile=tmpfile, $
                           galex=galex, ukidss=ukidss, onepeak=onepeak, $
                           hoggscatter=hoggscatter, conditional=conditional, $
                           ilim=ilim, altqso=altqso, imin=imin, $
                           nolabels=nolabels, _EXTRA=_EXTRA, $
                           legendcharsize=legendcharsize, $
                           testqso=testqso
IF ~keyword_set(legendcharsize) THEN legendcharsize=1.4
;;Get quasars
IF keyword_set(altqso) THEN BEGIN
    qso= xdqsoz_read_altquasars()
ENDIF ELSE IF keyword_set(testqso) THEN BEGIN
    qso= mrdfits('$BOVYQSOEDDATA/qso_all_extreme_deconv_10.fits',1)
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

restore, filename=tmpfile

;;quasars in the right redshift range
indx=  where(qso.z GE 0.3 and qso.z LE 5.5,cnt)
IF cnt gt 0 then begin
    qso= qso[indx]
    mi= mi[indx]
    peaks= peaks[indx]
    peakz= peakz[indx]
    flux= flux[*,indx]
    flux_ivar= flux_ivar[*,indx]
    nqso= cnt
ENDIF

IF keyword_set(ilim) THEN BEGIN
    indx= where(mi LT ilim,cnt)
    IF cnt GT 0 THEN BEGIN
        qso= qso[indx]
        mi= mi[indx]
        peaks= peaks[indx]
        peakz= peakz[indx]
        flux= flux[*,indx]
        flux_ivar= flux_ivar[*,indx]
        nqso= cnt
        print, strtrim(string(cnt),2)+" ilim objects"
    ENDIF
ENDIF

IF keyword_set(imin) THEN BEGIN
    indx= where(mi GT imin,cnt)
    IF cnt GT 0 THEN BEGIN
        qso= qso[indx]
        mi= mi[indx]
        peaks= peaks[indx]
        peakz= peakz[indx]
        flux= flux[*,indx]
        flux_ivar= flux_ivar[*,indx]
        nqso= cnt
        print, strtrim(string(cnt),2)+" imin objects"
    ENDIF
ENDIF

IF keyword_set(onepeak) THEN BEGIN
    indx= where(peaks EQ 1,cnt)
    IF cnt GT 0 THEN BEGIN
        qso= qso[indx]
        mi= mi[indx]
        peaks= peaks[indx]
        peakz= peakz[indx]
        flux= flux[*,indx]
        flux_ivar= flux_ivar[*,indx]
        fonepeak= cnt/double(nqso)*100.
        nqso= cnt
        print, strtrim(string(cnt),2)+" npeak=1 objects"
    ENDIF
ENDIF

;;Calculate mean and dispersion, and how many objs are in |Delta z | < 0.3
diffmean= mean(qso.z-peakz)
diffvar= variance(qso.z-peakz)
outindx= where(abs(qso.z-peakz) GE 4.*sqrt(diffvar),outcnt)
print, outcnt
point3= where(abs(qso.z-peakz) LT 0.3,npoint3)
print, npoint3, float(npoint3)/n_elements(qso.z)
print, diffmean, sqrt(diffvar/nqso), sqrt(diffvar), outcnt/double(nqso)*100.

IF keyword_set(plotfile) THEN k_print, filename=plotfile
IF keyword_set(nolabels) THEN BEGIN
    IF keyword_set(hoggscatter) THEN hogg_scatterplot, qso.z, peakz, $
      conditional=conditional, xrange=[0.,5.99], yrange=[0.,5.99], $
      outliers=~keyword_set(conditional), outcolor=djs_icolor('black'), $
      _EXTRA=_EXTRA ELSE $
      djs_plot, qso.z, peakz, $
      xrange=[0.,5.99], yrange=[0.,5.99], psym=3, _EXTRA=_EXTRA
ENDIF ELSE BEGIN
    IF keyword_set(hoggscatter) THEN hogg_scatterplot, qso.z, peakz, $
      xtitle='spectroscopic redshift', ytitle='photometric redshift', $
      conditional=conditional, xrange=[0.,5.99], yrange=[0.,5.99], $
      outliers=~keyword_set(conditional), outcolor=djs_icolor('black') ELSE $
      djs_plot, qso.z, peakz, $
      xtitle='spectroscopic redshift', ytitle='photometric redshift', $
      xrange=[0.,5.99], yrange=[0.,5.99], psym=3
ENDELSE
djs_oplot, [0.,5.99],[0.,5.99], color='black'
djs_oplot, [0.,5.99],[0.-0.3,5.99-0.3], color='gray',thick=2.
djs_oplot, [0.,5.99],[0.+0.3,5.99+0.3], color='gray',thick=2.
;;add legend
if keyword_set(galex) then begin
    if keyword_set(ukidss) then begin
        legend, ['+ GALEX UV + UKIDSS NIR'], box=0., charsize=legendcharsize, $
          /top, /left
    endif else begin
        legend, ['+ GALEX UV'], box=0., charsize=legendcharsize, $
          /top, /left
    endelse
endif else if keyword_set(ukidss) then begin
    legend, ['+ UKIDSS NIR'], box=0., charsize=legendcharsize, $
      /top, /left
endif else begin
    legend, ['SDSS ugriz'], box=0., charsize=legendcharsize, $
      /top, /left
endelse
if keyword_set(onepeak) then begin
    legend, [textoidl('f_{one peak} = ')+strtrim(string(fonepeak,format='(F4.1)'),2)+ ' %', $
             textoidl('\sigma = ')+strtrim(string(sqrt(diffvar),format='(F4.2)'),2), $
             textoidl('f_{> 4 \sigma} = ')+strtrim(string(outcnt/double(nqso)*100.,format='(F5.2)'),2)+' %'], box=0., charsize=legendcharsize, /bottom, /right
endif else begin
    legend, [textoidl('N_{objects} = ')+strtrim(string(nqso,format='(I)'),2), $
             textoidl('\sigma = ')+strtrim(string(sqrt(diffvar),format='(F4.2)'),2), $
             textoidl('f_{> 4 \sigma} = ')+strtrim(string(outcnt/double(nqso)*100.,format='(F5.2)'),2)+' %'], box=0., charsize=legendcharsize, /bottom, /right
endelse
IF keyword_set(plotfile) THEN k_end_print
END
