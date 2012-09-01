;+
;   NAME:
;      deconvolve_all
;   PURPOSE:
;      deconvolve the 'all'  distribution function by fitting the
;      underlying distribution as a mixture of Gaussians
;   INPUT:
;      magbin - if set, use this i-magnitude bin and deconvolve fluxes
;               ('ilow_i_ihigh_ngauss')
;      datafilename - filename that holds the data (has reasonable default)
;      savefilename - filename that will hold the IDL savefile with
;                     the best-fit mixture
;      ngauss - number of Gaussians to deconvolve with (only when
;               deconvolving all colors, otherwise in magbin)
;      w - covariance prior hyperparameter
;      seed - seed for random number generator
;      splitnmerge - try splitnmerge with this depth
;   KEYWORDS:
;      dccoadd - deconvolve the coadded data, not the single-epoch data
;      rescale - rescale the fluxes such that everything has the same
;                i-band flux, i.e., that of the middle of the bin
;                (only if deconvolving in a bin)
;      initprevbin - initialize using the previous bin's solution
;                    assumes that this bin is 0.1 mag away and has a
;                    similar filename
;      nir - include NIR data
;      uv - include UV data
;      full - use full data set
;      excludes82 - exclude stripe-82 in the full fit
;      relaxedfit - use tol=1D-5 instead of tol=1D-6
;   OUTPUT:
;      saves solution to savefilename, does nothing if savefilename
;      exists!
;   BUGS/MISSING FEATURES:
;      NIR/UV data not implemented when not fitting in a bin in i-band magnitude
;   REVISION HISTORY:
;      2009-12-17 - Written for qso - Bovy (NYU)
;      2010-03-04 - Adapted for 'all' - Bovy (NYU)
;      2010-03-12 - use magnitude bin - Bovy (NYU)
;      2010-04-08 - renamed to deconvolve_all; added dccoadd keyword - Bovy (NYU)
;      2010-05-05 - Added NIR data  - Bovy
;      2010-11-26 - Added full keyword - Bovy
;-
PRO DECONVOLVE_ALL, magbin=magbin,$
                    datafilename=datafilename, $
                    savefilename=savefilename,$
                    w=w,seed=seed, ngauss=ngauss, $
                    dccoadd=dccoadd, rescale=rescale, $
                    initprevbin=initprevbin, $
                    splitnmerge=splitnmerge, nir=nir, $
                    uv=uv, full=full, relaxedfit=relaxedfit, $
                    excludes82=excludes82

IF file_test(savefilename) THEN BEGIN
    print, "Savefile exists, returning ..."
    RETURN
ENDIF
IF ~keyword_set(w) THEN w=0.
IF ~keyword_set(seed) THEN seed= -1L
;;Read the data
print, "Reading data ..."
IF ~keyword_set(datafilename) THEN BEGIN
    datafilename='$BOVYQSOEDDATA/coaddedMatch.fits'
ENDIF        
IF keyword_set(nir) THEN nirdatafilename= '$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits'
IF keyword_set(uv) THEN uvdatafilename= '$BOVYQSOEDDATA/star82-varcat-bound-ts_sdss_galex.fits'
IF ~keyword_set(full) THEN BEGIN
    IF keyword_set(dccoadd) THEN BEGIN
        alldata= mrdfits(datafilename,1)
    ENDIF ELSE BEGIN
        alldata= mrdfits(datafilename,2)
    ENDELSE
    IF keyword_set(dccoadd) THEN BEGIN
        flagstruct= mrdfits(datafilename,2)
        get_coadd_fluxes, alldata, flux, flux_ivar, extinction, $
          flagstruct=flagstruct
    ENDIF ELSE BEGIN
        ;;Trim to right flags
        indx= ed_qso_trim(alldata)
        alldata= alldata[indx]
        ;;Trim to non-varying objects
        coadddata= mrdfits(datafilename,1)
        coadddata= coadddata[indx]
        nonvarindx= where(coadddata.flux_clip_rchi2[2] LT 1.4)
        alldata= alldata[nonvarindx]
        flux= alldata.psfflux
        flux_ivar= alldata.psfflux_ivar
        extinction= alldata.extinction
        ;;Make sure that there are no objects with ivar=0.
        minivar= min(flux_ivar[where(flux_ivar NE 0.)])
        badivar= where(flux_ivar EQ 0.)
        IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
    ENDELSE
ENDIF
print, "Prepping data ..."
IF keyword_set(magbin) THEN BEGIN
    x=strsplit(magbin,'_i_',/extract)
    ilow= double(x[0])
    ihigh= double(x[1])
    ngauss= long(x[2])
    IF keyword_set(full) THEN BEGIN
        fullbin= floor((ilow-12.9)/0.1)
        alldata= mrdfits(get_choppedsweeps_name(fullbin,/path),1)
        if keyword_set(excludes82) then begin
            print, "Excluding Stripe-82 ..."
            ltzero= where(alldata.ra LT 0.,cnt)
            if cnt gt 0 then alldata[ltzero].ra= alldata[ltzero].ra+360.
            s82indx= where(alldata.dec GT 1.25 or $
                           alldata.dec LT -1.25 $
                           or (alldata.ra GT 30. $
                               and alldata.ra LT 330.),cnt)
            if cnt gt 0 then alldata= alldata[s82indx]
            print, strtrim(string(n_elements(alldata.ra)),2)+" remain"
        endif else begin
            ;;get stripe-82 data and use that
            s82data= mrdfits(datafilename,1)
            spherematch, alldata.ra, alldata.dec, s82data.ra, s82data.dec, 2./3600., $
              aindx, sindx
            IF aindx[0] NE -1 THEN BEGIN
                print, "Found "+strtrim(string(n_elements(aindx)),2)+" stripe-82 matches"
                alldata[aindx].psfflux= s82data[sindx].psfflux
                alldata[aindx].psfflux_ivar= s82data[sindx].psfflux_ivar
                alldata[aindx].extinction= s82data[sindx].extinction
            ENDIF
        endelse
        ;;gather fluxes
        flux= alldata.psfflux
        flux_ivar= alldata.psfflux_ivar
        extinction= alldata.extinction
        ;;Make sure that there are no objects with ivar=0.
        minivar= min(flux_ivar[where(flux_ivar NE 0.)])
        badivar= where(flux_ivar EQ 0.)
        IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
    ENDIF ELSE BEGIN
        IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, $
          extinction=extinction, mags=mags, var_mags=ycovar ELSE $
          prep_data, flux, flux_ivar, mags=mags, var_mags=ycovar
        thisdata= where(mags[3,*] GE ilow AND mags[3,*] LT ihigh)
        alldata= alldata[thisdata]
        IF keyword_set(dccoadd) THEN BEGIN
            get_coadd_fluxes, alldata, flux, flux_ivar, extinction, indx=indx
            alldata= alldata[indx]
        ENDIF ELSE BEGIN
            flux= alldata.psfflux
            flux_ivar= alldata.psfflux_ivar
            extinction= alldata.extinction
            ;;Make sure that there are no objects with ivar=0.
            minivar= min(flux_ivar[where(flux_ivar NE 0.)])
            badivar= where(flux_ivar EQ 0.)
            IF ~(badivar[0] EQ -1) THEN flux_ivar[badivar]= minivar/1D3
        ENDELSE
    ENDELSE
    IF keyword_set(nir) THEN BEGIN
        nirdata= mrdfits(nirdatafilename,1)
        get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, alldata
    ENDIF ELSE BEGIN
        nirflux= 0.
        nirflux_ivar= 0.
        nirextinction= 0.
    ENDELSE
    IF keyword_set(uv) THEN BEGIN
        uvdata= mrdfits(uvdatafilename,1)
        get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, alldata, $
          ngalexdata=ngalexdata, /s82
    ENDIF ELSE BEGIN
        uvflux= 0.
        uvflux_ivar= 0.
        uvextinction= 0.
        ngalexdata= 0
    ENDELSE
    combine_fluxes, flux, flux_ivar, extinction, anirflux=nirflux, $
      bnirflux_ivar=nirflux_ivar, $
      cnirextinction= nirextinction, duvflux=uvflux, $
      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
      nir=nir,uv=uv, fluxout=outflux, ivarfluxout=outflux_ivar, $
      extinctionout=outextinction
    flux= outflux
    flux_ivar= outflux_ivar
    extinction= outextinction
    IF keyword_set(rescale) THEN BEGIN
        IF keyword_set(extinction) THEN prep_data, flux, $
          flux_ivar, extinction=extinction, $
          mags=ydata, var_mags=ycovar, /relfluxes ELSE $
          prep_data, flux, flux_ivar, $
          mags=ydata, var_mags=ycovar, /relfluxes
    ENDIF ELSE BEGIN
        IF keyword_set(extinction) THEN prep_data, flux, $
          flux_ivar, extinction=extinction, $
          mags=ydata, var_mags=ycovar, /fluxes ELSE $
          prep_data, flux, flux_ivar, $
          mags=ydata, var_mags=ycovar, /fluxes
    ENDELSE
    ndim= n_elements(ydata[*,0])
    ndata= n_elements(ydata[0,*])
    print, "Fitting "+strtrim(string(ndata),2)+" points"
ENDIF ELSE BEGIN
    ;;NO MAGBIN NOT NIR, UV, OR FULL EDITED
    IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, $
      extinction=extinction, mags=ydata, var_mags=ycovar, /colors ELSE $
      prep_data, flux, flux_ivar, mags=ydata, var_mags=ycovar, /colors
    ndim= 4
    ngauss= ngauss
ENDELSE
;;Initialize
IF keyword_set(initprevbin) THEN BEGIN
    offset= 0.1
    pos= STRPOS(savefilename,magbin)
    prevbin_magbin= strtrim(string(ilow-0.1,format='(F4.1)'),2)+'_i_'+$
      strtrim(string(ihigh-0.1,format='(F4.1)'),2)+'_'+strtrim(string(ngauss),2)
    prevbin_savefilename= savefilename
    STRPUT, prevbin_savefilename, prevbin_magbin, pos
    IF file_test(prevbin_savefilename) THEN BEGIN
        print, "Restoring previous bin's solution as initial condition ..."
        tmp_ndata= ndata
        tmp_ngalexdata= ngalexdata
        restore, filename=prevbin_savefilename
        skip_init= 1
        ilow+= offset
        ihigh+= offset
        ndata= tmp_ndata
        ngalexdata= tmp_ngalexdata
        avgloglikedata= -(machar(/double)).xmax
    ENDIF
ENDIF
IF ~keyword_set(skip_init) THEN BEGIN
    amp= dblarr(ngauss)+1./ngauss
    magsmeans= dblarr(ndim)
    FOR ii=0L, ndim-1 DO magsmeans[ii]= mean(ydata[ii,*],/double,/nan)
    magsstddevs= dblarr(ndim)
    FOR ii=0L, ndim-1 DO magsstddevs[ii]= stddev(ydata[ii,*],/double,/nan)
    xmean= dblarr(ndim,ngauss)
    xcovar= dblarr(ndim,ndim,ngauss)
    FOR kk=0L, ngauss-1 DO BEGIN
        FOR jj=0L, ndim-1 DO BEGIN
            ;;Dumb initialization
            xmean[jj,kk]= magsmeans[jj]+(2.*randomu(seed)-1.)*magsstddevs[jj]
            xcovar[jj,jj,kk]= magsstddevs[jj]^2.
        ENDFOR
    ENDFOR
ENDIF

;;Run EM algorithm
if keyword_set(relaxedfit) then tol= 1.D-5 else tol= 1.D-6
projected_gauss_mixtures_c, ngauss, ydata, ycovar,$
  amp, xmean, xcovar, avgloglikedata=avgloglikedata, $
  logfile='tmplog'+strtrim(string(ngauss),2)+'_'+strtrim(string(ilow),2), $
  splitnmerge=splitnmerge, tol=tol

;;Save
IF keyword_set(magbin) THEN BEGIN
    save, filename=savefilename, amp, xmean, xcovar, avgloglikedata, ilow, ihigh, ndata, ngalexdata
ENDIF ELSE BEGIN
    save, filename=savefilename, amp, xmean, xcovar, avgloglikedata
ENDELSE
;;Done!
END
