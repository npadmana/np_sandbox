;+
;   NAME:
;      get_uv_fluxes
;   PURPOSE:
;      get the UV fluxes (matched to coadded data)
;   INPUT:
;      uvdata
;      alldata - coadded data structure
;   KEYWORDS:
;      s82 - use stripe-82 format
;      byid - match by photoid
;   OUTPUT:
;      uvflux - UV fluxes
;      uvflux_ivar - inverse variances
;      uvflux_extinction - extinctions (zero?)
;   HISTORY:
;      2010-05-24 - Written - Bovy (NYU)
;      2010-06-07 - switched to new GALEX format - Bovy (NYU)
;-
PRO GET_UV_FLUXES, uvdata, uvflux, uvflux_ivar, uvextinction, alldata, $
                   matchlength=matchlength, ngalexdata=ngalexdata, old=old, $
                   s82=s82, byid=byid, raw_matches=match2
IF ~keyword_set(matchlength) THEN matchlength= 2./3600.
_BIGVAR= 1D5
;;First match
if keyword_set(byid) then begin
    print, "Matching UV data to SDSS data by photoid..."
    sphoto_match, uvdata, alldata, match1, match2
endif else begin
    print, "Spherematching UV data to SDSS data ..."
    spherematch, uvdata.ra, uvdata.dec, alldata.ra, alldata.dec, matchlength, match1, match2
endelse

IF match1[0] EQ -1 THEN print, "Found 0 matches out of "+strtrim(string(n_elements(alldata.ra)),2) ELSE print, "Found "+strtrim(string(n_elements(match2)),2)+" matches out of "+strtrim(string(n_elements(alldata.ra)),2)

ndata= n_elements(alldata.ra)
nfluxes= 2
uvflux= dblarr(nfluxes,ndata)
uvflux_ivar= dblarr(nfluxes,ndata)+1./_BIGVAR
uvextinction= dblarr(nfluxes,ndata)

IF match1[0] EQ -1 THEN BEGIN
    IF arg_present(ngalexdata) THEN ngalexdata= 0
    RETURN
ENDIF
IF ~keyword_set(old) and ~keyword_set(s82) THEN BEGIN
    uvflux[0,match2]= uvdata[match1].nuv
    uvflux[1,match2]= uvdata[match1].fuv
ENDIF ELSE BEGIN
    uvflux[0,match2]= uvdata[match1].nuv_flux
    uvflux[1,match2]= uvdata[match1].fuv_flux
ENDELSE
IF keyword_set(old) THEN BEGIN
    uvflux_ivar[0,match2]= 1D0/uvdata[match1].nuv_fluxerr^2D0
    uvflux_ivar[1,match2]= 1D0/uvdata[match1].fuv_fluxerr^2D0
ENDIF ELSE IF keyword_set(s82) THEN BEGIN
    uvflux_ivar[0,match2]= uvdata[match1].nuv_invar
    uvflux_ivar[1,match2]= uvdata[match1].fuv_invar
ENDIF ELSE BEGIN
    uvflux_ivar[0,match2]= uvdata[match1].nuv_ivar
    uvflux_ivar[1,match2]= uvdata[match1].fuv_ivar
ENDELSE
IF tag_exist(alldata,'extinction') THEN BEGIN
    uvextinction[0,match2]= alldata[match2].extinction[0]/5.155D0*8.18D
    uvextinction[1,match2]= alldata[match2].extinction[0]/5.155D0*8.29D
ENDIF

; do by bandpass so we can tell how many objects
for band=0,1 do begin

    indx= where(finite(uvflux_ivar[band,*],/infinity), ninf)
    if ninf ne 0 then begin
        splog,format='("found infinite ivar(band=",i0,"):",i0,"/",i0)',band,ninf,ndata
        uvflux_ivar[band,indx]= 1./_BIGVAR
    endif
    indx= where(uvflux_ivar[band,*] EQ 0., nzero)

    if nzero ne 0 then begin
        splog,format='("found zero ivar(band=",i0,"):",i0,"/",i0)',band,nzero,ndata
        uvflux_ivar[band,indx]= 1./_BIGVAR
    endif

endfor



;indx= where(finite(uvflux_ivar,/infinity), ninf)
;if ninf ne 0 then begin
;    splog,format='("found invinite ivar:",i0,"/",i0)',ninf,ndata
;    uvflux_ivar[indx]= 1./_BIGVAR
;endif
;indx= where(uvflux_ivar EQ 0., nzero)

;if nzero ne 0 then begin
;    splog,format='("found zero ivar:",i0,"/",i0)',nzero,ndata
;    uvflux_ivar[indx]= 1./_BIGVAR
;endif

IF arg_present(ngalexdata) THEN ngalexdata= n_elements(match1)

END
