;+
;   NAME:
;      marginalize_colorzprob
;   PURPOSE:
;      marginalize the probability of a relative flux + redshift
;      (*not* a color) over redshift
;   INPUT:
;      z_min, z_max - redshift
;      flux - [5] or [5,ndata] array of fluxes
;      flux_ivar - [5] or [5,ndata] array of flux_ivars
;   OPTIONAL INPUT:
;      norm - normalization factor (if precomputed)
;   KEYWORDS:
;      galex - use GALEX fits
;      ukidss - use UKIDSS
;      log - calculate log
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
FUNCTION MARGINALIZE_COLORZPROB, z_min,z_max, flux, flux_ivar, galex=galex, ukidss=ukidss, $
                                 norm=norm, log=log
_SAVEDIR= '$BOSSTARGET_DIR/data/qso-ed/zfits/'
basesavefilename= 'dc_qso_allz_fluxdist_'

b= 1.8;;Magnitude softening
_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 60
nbins= (_IMAX-_IMIN)/_ISTEP
_DEFAULTZMIN= 0.3
_DEFAULTZMAX= 5.5

nfi= n_elements(flux[0,*])
nz= n_elements(z_min)
ndim= n_elements(flux)/nfi-1
;;Check inputs
if nfi GE 1 and nz EQ 1 then begin
    thisz_min= replicate(z_min,nfi)
    thisz_max= replicate(z_max,nfi)
    thisflux= flux
endif else if nz gt 1 and nfi eq 1 then begin
    thisz_min= z_min
    thisz_max= z_max
    thisflux= dblarr(ndim+1,nz)
    for ii=0L, nz-1 do thisflux[*,ii]= flux
    nfi= n_elements(thisflux[0,*])
endif else begin
    print, "Warning: inputs to eval_colorz are wrong"
    return , -1.
endelse

;;First calculate p(relative-flux), i.e., fully marginalized
;;probability, and save membership probabilities
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(thisflux[3,*],b)
out= dblarr(nfi)
member_prob= dblarr(_NGAUSS,nfi)
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
    ;;Load solution
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    IF keyword_set(zfour) AND keyword_set(qso) AND ~keyword_set(lowz) THEN thissavefilename+= '_z4'
    thissavefilename+= '_z.sav'
    restore, filename=thissavefilename
    ;;Marginalize over redshift
    ngauss= n_elements(amp)
    ndimx= n_elements(xmean)/ngauss
    thisxmean= xmean[1:ndimx-1,*]
    thisxcovar= xcovar[1:ndimx-1,1:ndimx-1,*]
    calc_membership_prob, thismember_prob, ydata, ycovar,thisxmean,thisxcovar,amp, loglike=thisnorm
    IF keyword_set(log) THEN out[indx]= thisnorm ELSE out[indx]= exp(thisnorm)
    member_prob[*,indx]= thismember_prob
ENDFOR

IF arg_present(norm) THEN norm= out

IF z_min EQ _DEFAULTZMIN and z_max EQ _DEFAULTZMAX THEN BEGIN
    IF scalarOut THEN return, out[0] ELSE return, out
ENDIF

;;Marginalize, once again loop through the solutions bin
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
    thiszmin= alog(z_min[indx])
    thiszmax= alog(z_max[indx])
    ;;Load solution
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    thissavefilename+= '_z.sav'
    restore, filename=thissavefilename
    ;;Marginalize
    ngauss= n_elements(amp)
    ndimx= n_elements(xmean)/ngauss
    fluxxmean= xmean[1:ndimx-1,*]
    fluxxcovar= xcovar[1:ndimx-1,1:ndimx-1,*]
    zxmean= xmean[0,*]
    zxcovar= xcovar[0,0,*]
    zfluxxcovar= xcovar[0,1:ndimx-1,*]
    for jj=0L, n_elements(indx)-1 do begin
        thisout= 0D0
        for kk=0L, ngauss-1 do begin
            fluxinvxcovar= invert(fluxxcovar[*,*,kk]+ycovar[*,*,jj],/double)
            mz= zxmean[0,kk]+zfluxxcovar[0,*,kk]#(fluxinvxcovar#(ydata[*,jj]-fluxxmean[*,kk]))
            Vz= zxcovar[0,0,kk]-zfluxxcovar[0,*,kk]#(fluxinvxcovar#transpose(zfluxxcovar[0,*,kk]))
            thisout+= exp(member_prob[kk,indx[jj]])/2D0*(erf((thiszmax[jj]-mz)/sqrt(2D0*Vz))-$
                                                          erf((thiszmin[jj]-mz)/sqrt(2D0*Vz)))
        endfor
        IF ~keyword_set(log) THEN out[indx[jj]]*= thisout ELSE out[indx[jj]]+= alog(thisout)
    endfor
ENDFOR
RETURN, out
END
