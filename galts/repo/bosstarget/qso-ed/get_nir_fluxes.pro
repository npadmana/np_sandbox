;+
;   NAME:
;      get_nir_fluxes
;   PURPOSE:
;      get the NIR fluxes (matched to coadded data)
;   INPUT:
;      uvdata
;      alldata - coadded data structure
;   OUTPUT:
;      uvflux - NIR fluxes (YJHK)
;      uvflux_ivar - inverse variances
;      uvflux_extinction - extinctions (zero?)
;   HISTORY:
;      2010-05-24 - Written - Bovy (NYU)
;      2010-06-07 - switched to new GALEX format - Bovy (NYU)
;      2010-10-27 - started on UKIDSS - Bovy
;      2011-01-12 - Match by id if /byid, ESS (BNL)
;-
PRO GET_NIR_FLUXES, nirdata, nirflux, nirflux_ivar, nirextinction, alldata, $
                   matchlength=matchlength, nukidssdata=nukidssdata, byid=byid,$
                   raw_matches=match_all

IF ~keyword_set(matchlength) THEN matchlength= 2./3600.

_SITONMGY= 1D35/3631
_BIGVAR= 1D5

;;First match
if keyword_set(byid) then begin
    print, "Matching NIR data to SDSS data by photoid..."
    sphoto_match, nirdata, alldata, match_nir, match_all
endif else begin
    print, "SphereMatching NIR data to SDSS data by ..."
    spherematch, nirdata.ra, nirdata.dec, alldata.ra, alldata.dec, matchlength, match_nir, match_all
endelse

IF match_nir[0] EQ -1 THEN begin
    print, "Found 0 matches out of "+strtrim(string(n_elements(alldata.ra)),2) 
endif ELSE begin 
    print, "Found "+strtrim(string(n_elements(match_all)),2)+" matches out of "+strtrim(string(n_elements(alldata.ra)),2)
endelse

ndata= n_elements(alldata.ra)
nfluxes= 4
nirflux= dblarr(nfluxes,ndata)
nirflux_ivar= dblarr(nfluxes,ndata)+1./_BIGVAR
nirextinction= dblarr(nfluxes,ndata)

IF match_nir[0] EQ -1 THEN BEGIN
    IF arg_present(nukidssdata) THEN nukidssdata= 0
    RETURN
ENDIF
;;Y
nirflux[0,match_all]= nirdata[match_nir].APERCSIFLUX3_Y*_SITONMGY
nirflux_ivar[0,match_all]= 1D0/(nirdata[match_nir].APERCSIFLUX3ERR_Y*_SITONMGY)^2D0
bad= where(nirflux[0,*] LT -_BIGVAR,cnt);;HACK
IF cnt GT 0 THEN BEGIN
    nirflux[0,bad]= 0D0
    nirflux_ivar[0,bad]= 1D0/_BIGVAR
ENDIF

;;J
nirflux[1,match_all]= nirdata[match_nir].APERCSIFLUX3_J*_SITONMGY
nirflux_ivar[1,match_all]= 1D0/(nirdata[match_nir].APERCSIFLUX3ERR_J*_SITONMGY)^2D0
bad= where(nirflux[1,*] LT -_BIGVAR,cnt);;HACK
IF cnt GT 0 THEN BEGIN
    nirflux[1,bad]= 0D0
    nirflux_ivar[1,bad]= 1D0/_BIGVAR
ENDIF

;;H
nirflux[2,match_all]= nirdata[match_nir].APERCSIFLUX3_H*_SITONMGY
nirflux_ivar[2,match_all]= 1D0/(nirdata[match_nir].APERCSIFLUX3ERR_H*_SITONMGY)^2D0
bad= where(nirflux[2,*] LT -_BIGVAR,cnt);;HACK
IF cnt GT 0 THEN BEGIN
    nirflux[2,bad]= 0D0
    nirflux_ivar[2,bad]= 1D0/_BIGVAR
ENDIF

;;K
nirflux[3,match_all]= nirdata[match_nir].APERCSIFLUX3_K*_SITONMGY
nirflux_ivar[3,match_all]= 1D0/(nirdata[match_nir].APERCSIFLUX3ERR_K*_SITONMGY)^2D0
bad= where(nirflux[3,*] LT -_BIGVAR,cnt);;HACK
IF cnt GT 0 THEN BEGIN
    nirflux[3,bad]= 0D0
    nirflux_ivar[3,bad]= 1D0/_BIGVAR
ENDIF

IF tag_exist(alldata,'extinction') THEN BEGIN
    nirextinction[0,match_all]= alldata[match_all].extinction[0]/5.155D0*1.259D0
    nirextinction[1,match_all]= alldata[match_all].extinction[0]/5.155D0*0.920D0
    nirextinction[2,match_all]= alldata[match_all].extinction[0]/5.155D0*0.597D0
    nirextinction[3,match_all]= alldata[match_all].extinction[0]/5.155D0*0.369D0
ENDIF

;indx= where(finite(nirflux_ivar,/infinity))
;if indx[0] NE -1 THEN nirflux_ivar[indx]= 1./_BIGVAR
;indx= where(nirflux_ivar EQ 0.)
;if indx[0] NE -1 THEN nirflux_ivar[indx]= 1./_BIGVAR

wbad=where(finite(nirflux) eq 0 or finite(nirflux_ivar) eq 0 or nirflux_ivar eq 0, nbad)
if nbad ne 0 then begin
    nirflux[wbad] = 0d
    nirflux_ivar[wbad] = 1d/_BIGVAR
    nirextinction[wbad]= 0d
endif

IF arg_present(nukidssdata) THEN nukidssdata= n_elements(match_nir)

END
