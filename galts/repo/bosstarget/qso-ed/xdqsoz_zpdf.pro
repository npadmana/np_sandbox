;+
;   NAME:
;      xdqsoz_zpdf
;   PURPOSE:
;      calculate the photometric redshift pdf for XDQSOZ
;   INPUT:
;      flux - [5] or [5,ndata] array of fluxes
;      flux_ivar - [5] or [5,ndata] array of flux_ivars
;   KEYWORDS:
;      galex - use GALEX fits
;      ukidss - use UKIDSS
;   OUTPUT:
;      zmean - [ngauss,ndata] array of means
;      zcovar - [ngauss,ndata] array of covars
;      zamp - [ngauss,ndata] array of amplitudes
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;-
PRO XDQSOZ_ZPDF, flux, flux_ivar, galex=galex, ukidss=ukidss, $
                 zmean=zmean, zcovar=zcovar, zamp=zamp
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
ndim= n_elements(flux)/nfi-1

if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(flux[3,*],b)
zamp= dblarr(_NGAUSS,nfi)
zmean= dblarr(_NGAUSS,nfi)
zcovar= dblarr(_NGAUSS,nfi)
;;Just loop through the solutions bin
FOR ii=0L, nbins-1 DO BEGIN
    indx= where(mi GE (_IMIN+(ii+0.5)*_ISTEP) AND $
                mi LT (_IMIN+(ii+1.5)*_ISTEP))
    IF indx[0] EQ -1 THEN CONTINUE ;;Nothing here
    ;;Prep the data
    if scalarOut THEN prep_data, flux, flux_ivar, mags=ydata,var_mags=ycovar, $
      /relfluxes ELSE $
      prep_data, flux[*,indx], flux_ivar[*,indx], mags=ydata,var_mags=ycovar, $
      /relfluxes
    ndata= n_elements(ydata[0,*])
    ;;Load solution
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    thissavefilename+= '_z.sav'
    ;thissavefilename+= '_z_point9.sav'
    restore, filename=thissavefilename
    ;;Marginalize over redshift first
    ngauss= n_elements(amp)
    ndimx= n_elements(xmean)/ngauss
    thisxmean= xmean[1:ndimx-1,*]
    thisxcovar= xcovar[1:ndimx-1,1:ndimx-1,*]
    calc_membership_prob, thismember_prob, ydata, ycovar,thisxmean,thisxcovar,amp, loglike=thisnorm
    zamp[*,indx]= exp(thismember_prob)
    ;;Now get the means and covars
    fluxxmean= xmean[1:ndimx-1,*]
    fluxxcovar= xcovar[1:ndimx-1,1:ndimx-1,*]
    zxmean= xmean[0,*]
    zxcovar= xcovar[0,0,*]
    zfluxxcovar= xcovar[0,1:ndimx-1,*]
    for jj=0L, n_elements(indx)-1 do begin
        for kk=0L, ngauss-1 do begin
            fluxinvxcovar= invert(fluxxcovar[*,*,kk]+ycovar[*,*,jj],/double)
            zmean[kk,indx[jj]]= zxmean[0,kk]+zfluxxcovar[0,*,kk]#(fluxinvxcovar#(ydata[*,jj]-fluxxmean[*,kk]))
            zcovar[kk,indx[jj]]= zxcovar[0,0,kk]-zfluxxcovar[0,*,kk]#(fluxinvxcovar#transpose(zfluxxcovar[0,*,kk]))
        endfor
    endfor
ENDFOR
if scalarOut then begin
    zmean= zmean[*,0]
    zamp= zamp[*,0]
    zcovar= zcovar[*,0]
endif
END
