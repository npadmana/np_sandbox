;+
;   NAME:
;      eval_colorprob
;   PURPOSE:
;      evaluate the probability of a relative flux (*not* a color)
;   INPUT:
;      flux - [5] or [5,ndata] array of fluxes
;      flux_ivar - [5] or [5,ndata] array of flux_ivars
;   KEYWORDS:
;      qso - qso color-probability
;      lowz - qso-lowz color probability
;      bossz - qso-BOSS redshift range probability
;      galex - use GALEX fits
;      ukidss - use UKIDSS
;      zfour - use z=4 as the boundary between bossz and hiz
;   OUTPUT:
;      number or array of probabilities
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;      2010-04-29 - adapted for sdss3 svn - Bovy
;      2010-05-29 - Added GALEX - Bovy
;      2010-10-30 - Added UKIDSS - Bovy
;      2010-11-02 - Added zfour - Bovy
;      2010-12-16 - Started testing 'full' - Bovy
;-
FUNCTION EVAL_COLORPROB, flux, flux_ivar, qso=qso, lowz=lowz, bossz=bossz, $
                         galex=galex, ukidss=ukidss, zfour=zfour, full=full
IF keyword_set(full) THEN $
  _SAVEDIR= '$BOSSTARGET_DIR/pro/qso-ed/testfulls82/' $
ELSE _SAVEDIR= '$BOSSTARGET_DIR/data/qso-ed/fits/'
IF keyword_set(qso) AND keyword_set(lowz) THEN BEGIN
    basesavefilename= 'dc_qso_lowz_fluxdist_'
ENDIF ELSE IF keyword_set(qso) AND keyword_set(bossz) THEN BEGIN
    basesavefilename= 'dc_qso_bossz_fluxdist_'
ENDIF ELSE IF keyword_set(qso) THEN BEGIN
    basesavefilename= 'dc_qso_fluxdist_'
ENDIF ELSE BEGIN
    IF keyword_set(full) THEN basesavefilename= 'dc_full_fluxdist_' $
    ELSE basesavefilename= 'dc_fluxdist_'
ENDELSE

b= 1.8;;Magnitude softening
_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 20
;IF keyword_set(full) and ~keyword_set(qso) THEN _NGAUSS= 30
nbins= (_IMAX-_IMIN)/_ISTEP

nfi= n_elements(flux[0,*])
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(flux[3,*],b)
out= dblarr(nfi)
;;Just loop through the solutions bin
FOR ii=0L, nbins-1 DO BEGIN
    ;IF ~keyword_set(qso) AND _IMIN+(ii+0.5)*_ISTEP GT 21.5 THEN BEGIN
    ;    indx= where(mi GE (_IMIN+(ii+0.5)*_ISTEP))
    ;ENDIF ELSE BEGIN
    indx= where(mi GE (_IMIN+(ii+0.5)*_ISTEP) AND $
                mi LT (_IMIN+(ii+1.5)*_ISTEP))
    ;ENDELSE
    IF indx[0] EQ -1 THEN CONTINUE ;;Nothing here
    ;;Prep the data
    if scalarOut THEN prep_data, flux, flux_ivar, mags=ydata,var_mags=ycovar, $
      /relfluxes ELSE $
      prep_data, flux[*,indx], flux_ivar[*,indx], mags=ydata,var_mags=ycovar, $
      /relfluxes
    ;;Load solution
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    IF keyword_set(zfour) AND keyword_set(qso) AND ~keyword_set(lowz) THEN thissavefilename+= '_z4'
    thissavefilename+= '.sav'
    restore, filename=thissavefilename
    out[indx]= exp(calc_loglike(ydata,ycovar,xmean,xcovar,amp))
ENDFOR
RETURN, out
END
