;+
;   NAME:
;      get_qso_fluxes
;   PURPOSE:
;      prepare the qso fluxes for the analysis
;   INPUT:
;      data - structure straight from the fits-file
;   OPTIONAL INPUT:
;      lowz - if set, return low redshift objects (default: z>2.15 redshift)
;      bossz - if set, return BOSS redshift range  objects (default: z>2.15 redshift)
;      allz - if set, deconvolve all quasars
;      zfour - use z=4 as the boundary between bossz and hiz
;   OUTPUT:
;      flux, flux_ivar, weight
;   HISTORY:
;      2010-04-16 - Written - Bovy (NYU)
;-
PRO GET_QSO_FLUXES, data, flux, flux_ivar, weight, lowz=lowz, bossz=bossz, $
                    zfour=zfour, allz=allz
IF keyword_set(allz) THEN BEGIN
    data= data
ENDIF ELSE IF keyword_set(lowz) THEN BEGIN
    data= data[where(data.z LT 2.2)]
ENDIF ELSE IF keyword_set(bossz) THEN BEGIN
    IF keyword_set(zfour) THEN BEGIN
        data= data[where(data.z GE 2.2 AND data.z LE 4.0)]
        print, "using z=4 as boundary"
    ENDIF ELSE BEGIN
        data= data[where(data.z GE 2.2 AND data.z LE 3.5)]
    ENDELSE
ENDIF ELSE BEGIN
    IF keyword_set(zfour) THEN BEGIN
        data= data[where(data.z GT 4.0)]
        print, "using z=4 as boundary"
    ENDIF ELSE BEGIN
        data= data[where(data.z GT 3.5)]
    ENDELSE
ENDELSE
indx= where(finite(data.psfflux_ivar[0]) AND finite(data.psfflux_ivar[1]) $
            AND finite(data.psfflux_ivar[2]) AND finite(data.psfflux_ivar[3])$
            AND finite(data.psfflux_ivar[4]))
data= data[indx]
ndata= n_elements(data.psfflux[0])
flux= data.psfflux
flux_ivar= data.psfflux_ivar
weight= data.weight
weight= weight/total(weight)*ndata
;;Make sure that there are no objects with ivar=0.
minivar= min(flux_ivar[where(flux_ivar NE 0.)])
badivar= where(flux_ivar EQ 0.)
IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
END
