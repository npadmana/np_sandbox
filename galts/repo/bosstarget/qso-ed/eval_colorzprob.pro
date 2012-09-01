;+
;   NAME:
;      eval_colorzprob
;   PURPOSE:
;      evaluate the probability of a relative flux + redshift (*not* a color)
;   INPUT:
;      z - redshift [1], or [ndata]
;      flux - [5] or [5,ndata] array of fluxes
;      flux_ivar - [5] or [5,ndata] array of flux_ivars
;   KEYWORDS:
;      galex - use GALEX fits
;      ukidss - use UKIDSS
;   OUTPUT:
;      number or array of probabilities
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;      2010-04-29 - adapted for sdss3 svn - Bovy
;      2010-05-29 - Added GALEX - Bovy
;      2010-10-30 - Added UKIDSS - Bovy
;      2010-11-02 - Added zfour - Bovy
;      2010-12-16 - Started testing 'full' - Bovy
;      2011-01-16 - Adapted for colorz - Bovy
;-
FUNCTION EVAL_COLORZPROB, z, flux, flux_ivar, galex=galex, ukidss=ukidss
_SAVEDIR= '$BOSSTARGET_DIR/data/qso-ed/zfits/'
basesavefilename= 'dc_qso_allz_fluxdist_'

b= 1.8;;Magnitude softening
_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 60
nbins= (_IMAX-_IMIN)/_ISTEP

nfi= n_elements(flux[0,*])
nz= n_elements(z)
ndim= n_elements(flux)/nfi-1
;;Check inputs
if nfi GE 1 and nz EQ 1 then begin
    thisz= replicate(z,nfi)
    thisflux= flux
endif else if nz gt 1 and nfi eq 1 then begin
    thisz= z
    thisflux= dblarr(ndim+1,nz)
    for ii=0L, nz-1 do thisflux[*,ii]= flux
    nfi= n_elements(thisflux[0,*])
endif else begin
    print, "Warning: inputs to eval_colorz are wrong"
    return , -1.
endelse

if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(thisflux[3,*],b)
out= dblarr(nfi)
;;Just loop through the solutions bin
FOR ii=0L, nbins-1 DO BEGIN
    indx= where(mi GE (_IMIN+(ii+0.5)*_ISTEP) AND $
                mi LT (_IMIN+(ii+1.5)*_ISTEP))
    IF indx[0] EQ -1 THEN CONTINUE ;;Nothing here
    ;;Prep the data
    if scalarOut THEN prep_data, thisflux, flux_ivar, mags=ydata,var_mags=ycovar, $
      /relfluxes ELSE $
      prep_data, thisflux[*,indx], flux_ivar[*,indx], mags=ydata,var_mags=ycovar, $
      /relfluxes
    ndata= n_elements(ydata[0,*])
    zydata= dblarr(ndim+1,ndata)
    zydata[0,*]= alog(thisz[indx])
    zydata[1:ndim,*]= ydata
    zycovar= dblarr(ndim+1,ndim+1,ndata)
    zycovar[1:ndim,1:ndim,*]= ycovar
    ydata= zydata
    ycovar= zycovar
    ;;Load solution
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    thissavefilename+= '_z.sav'
    restore, filename=thissavefilename
    jac= 1D0/thisz[indx]
    out[indx]= jac*exp(calc_loglike(ydata,ycovar,xmean,xcovar,amp))
ENDFOR
RETURN, out
END
