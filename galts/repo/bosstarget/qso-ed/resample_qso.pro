;+
;   NAME:
;      resample_qso
;   PURPOSE:
;      resample the qso distribution to get a 'fair' sample
;   INPUT:
;      flux - fluxes
;      weight - weights
;   OUTPUT:
;      newflux - resampled fluxes
;   HISTORY:
;      2010-04-16 - Written - Bovy (NYU)
;-
PRO RESAMPLE_QSO, flux, flux_ivar, weight, newflux, seed=seed, $
                  indxarray=indxarray
ndata= n_elements(flux[0,*])
nfluxes= n_elements(flux[*,0])
IF ~keyword_set(seed) THEN seed=-1L
cumulweight= TOTAL(weight,/cumulative)/TOTAL(weight)
newflux= dblarr(nfluxes,ndata)
indxarray= lindgen(ndata)
FOR ii=0L, ndata-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,ndata,string(13B)
    comp= randomu(seed)
    indx= 0L
    WHILE comp GT cumulweight[indx] DO BEGIN
        indx+= 1
    ENDWHILE
    indxarray[ii]= indx
    newflux[*,ii]= flux[*,indx]+randomn(seed,nfluxes)/sqrt(flux_ivar[*,indx])/10.
ENDFOR
END
