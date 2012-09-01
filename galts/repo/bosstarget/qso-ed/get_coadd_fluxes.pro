;+
;   NAME:
;      get_coadd_fluxes
;   PURPOSE:
;      prepare the co-added fluxes for the analysis
;   INPUT:
;      data - structure straight from the fits-file
;   OPTIONAL INPUT:
;      chi2cut - cut for variability (remove these objects!)
;      nobadclip - don't clip out the bad clip_rms objects
;      old - old method (for wrong file)
;      flagstruct - structure that contains the flags (for new get)
;   OUTPUT:
;      flux, flux_ivar, extinction
;   HISTORY:
;      2010-04-08 - Written, long overdue - Bovy (NYU)
;-
PRO GET_COADD_FLUXES, data, flux, flux_ivar, extinction, chi2cut=chi2cut, $
                      nobadclip=nobadclip, indx=indx, old=old, $
                      flagstruct=flagstruct
IF keyword_set(old) THEN BEGIN
    IF ~keyword_set(chi2cut) THEN chi2cut= 1.4
    ndata= n_elements(data.flux_mean[0])
    IF ~keyword_set(nobadclip) THEN BEGIN
        nonvarindx= where(data.flux_rchi2[2] LT chi2cut AND data.flux_clip_rms[0] NE 0. $
                          AND data.flux_clip_rms[1] NE 0. AND data.flux_clip_rms[2] NE 0. $
                          AND data.flux_clip_rms[3] NE 0. AND data.flux_clip_rms[4] NE 0.)
    ENDIF ELSE BEGIN
        nonvarindx= where(data.flux_rchi2[2] LT chi2cut)
    ENDELSE
    data= data[nonvarindx]
    flux= data.flux_clip_mean
    flux_ivar= data.flux_ngood/data.flux_clip_rms^2D0
    extinction= data.extinction
;;Make sure that there are no objects with ivar=0.
    minivar= min(flux_ivar[where(flux_ivar NE 0.)])
    badivar= where(flux_ivar EQ 0.)
    IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
    IF arg_present(indx) THEN indx= nonvarindx
ENDIF ELSE BEGIN
    ;;First perform the magnitude cut
    ;prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, mags=mags, var_mags=ycovar
    ;indx= where((mags[1,*] LT 22 OR mags[2,*] LT 21.85)); AND mags[3,*]  GT 17.8,complement=nindx)
    ;data= data[indx]
    ;;First perform the flag cuts
    IF keyword_set(flagstruct) THEN BEGIN
        indx= ed_qso_trim(flagstruct)
        data= data[indx]
    ENDIF
    IF ~keyword_set(chi2cut) THEN chi2cut= 1.4
    ndata= n_elements(data.psfflux[0])
    nonvarindx= where(data.flux_clip_rchi2[2] LT chi2cut)
    data= data[nonvarindx]
    flux= data.psfflux
    flux_ivar= data.psfflux_ivar
    extinction= data.extinction
;;Make sure that there are no objects with ivar=0.
    minivar= min(flux_ivar[where(flux_ivar NE 0.)])
    badivar= where(flux_ivar EQ 0.)
    IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
    IF arg_present(indx) THEN indx= nonvarindx
ENDELSE
END
