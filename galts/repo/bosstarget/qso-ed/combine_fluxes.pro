;+
;   NAME:
;      combine_fluxes
;   PURPOSE:
;      combine the sdss, NIR, and UV fluxes
;   INPUT:
;      flux - sdss flux
;      flux_ivar - sdss flux_ivar
;      extinction - sdss extinction
;      nirflux -
;      nirflux_ivar
;      nirextinction
;      uvflux -
;      uvflux_ivar
;      uvextinction
;   KEYWORDS:
;      nir - NIR included
;      uv - UV included
;   OUTPUT:
;      outflux, outflux_ivar, outextinction - combination of inputs
;   HISTORY:
;      2010-05-05 - Written - Bovy (NYU)
;-
PRO COMBINE_FLUXES, flux, flux_ivar, extinction, anirflux=anirflux, $
                    bnirflux_ivar=bnirflux_ivar, $
                    cnirextinction= cnirextinction, duvflux=duvflux, $
                    euvflux_ivar=euvflux_ivar, fuvextinction=fuvextinction, $
                    nir=nir,uv=uv, fluxout=fluxout, $
                    ivarfluxout=ivarfluxout, extinctionout=extinctionout
_NSDSS= 5
_NNIR= 4
_NUV= 2
IF keyword_set(nir) AND keyword_set(uv) THEN BEGIN
    nfluxes= _NSDSS+_NNIR+_NUV
ENDIF ELSE IF keyword_set(nir) THEN BEGIN
    nfluxes= _NSDSS+_NNIR
ENDIF ELSE IF keyword_set(uv) THEN BEGIN
    nfluxes= _NSDSS+_NUV
ENDIF ELSE BEGIN
    nfluxes= _NSDSS
ENDELSE
ndata= n_elements(flux[0,*])
outflux= dblarr(nfluxes,ndata)
outflux_ivar= dblarr(nfluxes,ndata)
outextinction= dblarr(nfluxes,ndata)

outflux[0:4,*]= flux[*,*]
outflux_ivar[0:4,*]= flux_ivar[*,*]
outextinction[0:4,*]= extinction[*,*]
IF keyword_set(uv) THEN BEGIN
    outflux[5:6,*]= duvflux[*,*]
    outflux_ivar[5:6,*]= euvflux_ivar[*,*]
    outextinction[5:6,*]= fuvextinction[*,*]
    IF keyword_set(nir) THEN BEGIN
        outflux[7:10,*]= anirflux[*,*]
        outflux_ivar[7:10,*]= bnirflux_ivar[*,*]
        outextinction[7:10,*]= cnirextinction[*,*]
    ENDIF 
ENDIF ELSE IF keyword_set(nir) THEN BEGIN
    outflux[5:8,*]= anirflux[*,*]
    outflux_ivar[5:8,*]= bnirflux_ivar[*,*]
    outextinction[5:8,*]= cnirextinction[*,*]
ENDIF
fluxout= outflux
ivarfluxout= outflux_ivar
extinctionout= outextinction
END


