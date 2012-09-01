;+
;   NAME:
;      deconvolve_qso
;   PURPOSE:
;      deconvolve the qso  distribution function by fitting the
;      underlying distribution as a mixture of Gaussians
;   INPUT:
;      magbin - if set, use this i-magnitude bin and deconvolve fluxes
;               ('ilow_i_ihigh_ngauss'), must have width 0.2 and start
;               at a .1 multiple between 17.7 and 22.3
;      datafilename - filename that holds the data (has reasonable default)
;      savefilename - filename that will hold the IDL savefile with
;                     the best-fit mixture
;      ngauss - number of Gaussians to deconvolve with (only when
;               deconvolving all colors, otherwise in magbin)
;      w - covariance prior hyperparameter
;      seed - seed for random number generator
;      splitnmerge - try splitnmerge with this depth
;   KEYWORDS:
;      lowz - deconvolve the low redshift data (default: z>2.15 redshift)
;      bossz - deconvolve the high redshift data (default: z>2.15
;              redshift)
;      allz - deconvolve all quasars
;      fitz - fit the redshifts for photo-zs
;      rescale - rescale the fluxes such that everything has the same
;                i-band flux, i.e., that of the middle of the bin
;                (only if deconvolving in a bin)
;      initprevbin - initialize using the previous bin's solution
;                    assumes that this bin is 0.1 mag away and has a
;                    similar filename
;      nir - include NIR data
;      uv - include UV data
;      zfour - use z=4 as the boundary between bossz and hiz
;      pointnine - use 90 percent of the quasars
;   OUTPUT:
;      saves solution to savefilename, does nothing if savefilename exists!
;   REVISION HISTORY:
;      2010-04-19 - Written - Bovy (NYU)
;-
PRO DECONVOLVE_QSO, magbin=magbin,$
                    datafilename=datafilename, $
                    savefilename=savefilename,$
                    w=w,seed=seed, ngauss=ngauss, $
                    lowz=lowz, rescale=rescale, $
                    initprevbin=initprevbin, $
                    splitnmerge=splitnmerge, $
                    bossz=bossz, nir=nir, $
                    uv=uv, zfour=zfour, allz=allz, $
                    fitz=fitz, pointnine=pointnine

IF file_test(savefilename) THEN BEGIN
    print, "Savefile exists, returning ..."
    RETURN
ENDIF
IF ~keyword_set(w) THEN w=0.
IF ~keyword_set(datafilename) THEN BEGIN
    IF keyword_set(pointnine) THEN datafilename='$BOVYQSOEDDATA/qso_all_extreme_deconv_90.fits' ELSE datafilename='$BOVYQSOEDDATA/qso_all_extreme_deconv.fits.gz'
ENDIF        
IF keyword_set(nir) THEN nirdatafilename= '$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits'
IF keyword_set(uv) THEN uvdatafilename= '$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits'
IF ~keyword_set(seed) THEN seed= -1L
;;Read the data
print, "Reading data ..."
qsodata= mrdfits(datafilename,1)
get_qso_fluxes, qsodata, flux, flux_ivar, weight, lowz=lowz, bossz=bossz, $
  zfour=zfour, allz=allz
extinction= dblarr(n_elements(flux[*,0]),n_elements(flux[0,*]))
IF keyword_set(nir) THEN BEGIN
    nirdata= mrdfits(nirdatafilename,1)
    get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qsodata
ENDIF ELSE BEGIN
    nirflux= 0.
    nirflux_ivar= 0.
    nirextinction= 0.
ENDELSE
IF keyword_set(uv) THEN BEGIN
    uvdata= mrdfits(uvdatafilename,1)
    get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qsodata, $
      ngalexdata=ngalexdata, /old
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
extinction= outextinction;;This is zero, since all of the input fluxes are (should be) extinction corrected
print, "Prepping data ..."
IF keyword_set(magbin) THEN BEGIN
    x=strsplit(magbin,'_i_',/extract)
    ilow= double(x[0])
    ihigh= double(x[1])
    ngauss= long(x[2])
    windx= long((ilow-17.7)/0.1)
    weight= weight[windx,*]
    print, "n_weight= ", n_elements(weight)
    IF keyword_set(rescale) THEN BEGIN
        prep_data, flux, flux_ivar, $
          mags=ydata, var_mags=ycovar, /relfluxes
    ENDIF ELSE BEGIN
        prep_data, flux, flux_ivar, $
          mags=ydata, var_mags=ycovar, /fluxes
    ENDELSE
    ndim= n_elements(ydata[*,0])
    ndata= n_elements(ydata[0,*])
    IF keyword_set(fitz) THEN BEGIN
        zydata= dblarr(ndim+1,ndata)
        ;;adjust weights
        ;print, "Adjusting weights to keep the redshift prior ..."
        ;weight/= qsodata.z
        IF keyword_set(allz) THEN BEGIN
            zydata[0,*]= alog(qsodata.z)
        ENDIF ELSE IF keyword_set(bossz) THEN BEGIN
            zydata[0,*]= alog((qsodata.z-2.2)/1.3)-alog(1-(qsodata.z-2.2)/1.3)
        ENDIF ELSE IF keyword_set(lowz) THEN BEGIN
            zydata[0,*]= alog((qsodata.z)/2.2)-alog(1-(qsodata.z)/2.2)
        ENDIF ELSE BEGIN
            zydata[0,*]= alog((qsodata.z-3.5)/2.)-alog(1-(qsodata.z-3.5)/2.)
        ENDELSE
        zydata[1:ndim,*]= ydata
        IF keyword_set(rescale) THEN BEGIN
            zycovar= dblarr(ndim+1,ndim+1,ndata)
            zycovar[1:ndim,1:ndim,*]= ycovar
        ENDIF ELSE BEGIN
            zycovar= dblarr(ndim+1,ndata)
            zycovar[1:ndim,*]= ycovar
        ENDELSE
        ydata= zydata
        ycovar= zycovar
    ENDIF
    ndim= n_elements(ydata[*,0])
    ndata= n_elements(ydata[0,*])
    print, "Fitting "+strtrim(string(ndata),2)+" points"
ENDIF ELSE BEGIN
    ;;NO MAGBIN NOT NIR or UV EDITED, OR FITZ
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
if keyword_set(lowz) THEN BEGIN
    logfile= 'tmplog_qso_lowz'+strtrim(string(ngauss),2)+'_'+strtrim(string(ilow),2)
ENDIF ELSE IF keyword_set(bossz) THEN BEGIN
    logfile= 'tmplog_qso_bossz'+strtrim(string(ngauss),2)+'_'+strtrim(string(ilow),2)
ENDIF ELSE IF keyword_set(allz) THEN BEGIN
    logfile= 'tmplog_qso_all'+strtrim(string(ngauss),2)+'_'+strtrim(string(ilow),2)
ENDIF ELSE BEGIN
  logfile= 'tmplog_qso'+strtrim(string(ngauss),2)+'_'+strtrim(string(ilow),2)
ENDELSE
IF keyword_set(weight) THEN projected_gauss_mixtures_c, ngauss, ydata, ycovar,$
  amp, xmean, xcovar, avgloglikedata=avgloglikedata, $
  logfile=logfile, $
  splitnmerge=splitnmerge, weight=weight ELSE $
  projected_gauss_mixtures_c, ngauss, ydata, ycovar,$
  amp, xmean, xcovar, avgloglikedata=avgloglikedata, $
  logfile=logfile, $
  splitnmerge=splitnmerge

;;Save
IF keyword_set(magbin) THEN BEGIN
    save, filename=savefilename, amp, xmean, xcovar, avgloglikedata, ilow, ihigh, ndata, ngalexdata
ENDIF ELSE BEGIN
    save, filename=savefilename, amp, xmean, xcovar, avgloglikedata
ENDELSE
;;Done!
END
