;+
;   NAME:
;      qsoed_calculate_prob
;   PURPOSE:
;      calculate the extreme-deconvolution likelihood ratio
;   INPUT:
;      in - structure containing PSFFLUX, PSFFLUX_IVAR, EXTINCTION
;   OPTIONAL INPUT:
;      lumfunc - QSO luminosity function to use ('HRH07' or 'R06';
;                default= 'HRH07')
;      galex - if set, psfflux, ..., contains galex info, use it
;      nocuts - don't perform the magnitude cuts
;   KEYWORDS:
;      galex - GALEX fluxes are included in psfflux, psfflux_ivar, and
;              extinction; use them
;      ukidss - use UKIDSS (like /galex)
;      zfour - use z=4 as the boundary between bossz and hiz
;      multi - parallelize calculations to 4 processors
;      full - use full DR8 fits
;      verbose - print irrelevant warnings and what the code is doing
;   OUTPUT:
;      out - structure containing pqso, ...
;   HISTORY:
;      2010-04-30 - Written - Bovy (NYU)
;      2010-05-29 - Added Galex - Bovy
;      2010-10-30 - Added UKIDSS - Bovy
;      2010-11-02 - Added zfour - Bovy
;      2010-12-16 - Started testing 'full' - Bovy
;-
FUNCTION QSOED_CALCULATE_PROB, in, lumfunc=lumfunc, galex=galex, $
                               nocuts=nocuts, ukidss=ukidss, zfour=zfour, $
                               multi=multi, verbose=verbose, full=full


;;Prep the data
prep_data, in.psfflux, in.psfflux_ivar, extinction=in.extinction, $
  mags=mags, var_mags=ycovar
indx= where((mags[1,*] LT 22 OR mags[2,*] LT 21.85) AND mags[3,*]  GT 17.8,complement=nindx)
;data= data[indx]
ndata= n_elements(in.psfflux[0])
flux= sdss_deredden(in.psfflux,in.extinction)
flux_ivar=sdss_deredden_error(in.psfflux_ivar,in.extinction)

;;Read the differential number counts
dataDir= '$BOSSTARGET_DIR/data/qso-ed/numcounts/'
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07'
IF keyword_set(zfour) THEN BEGIN
    dndi_qsobosszfile= dndipath(2.2,4.,lumfunc)
    dndi_qsofile= dndipath(4.,6.,lumfunc)
ENDIF ELSE BEGIN
    dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
    dndi_qsofile= dndipath(3.5,6.,lumfunc)
ENDELSE
dndi_qsolowzfile= dndipath(0.3,2.2,lumfunc)
dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'

read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything

;;Now calculate all of the factors in turn
IF keyword_set(multi) THEN BEGIN
    ;;initialize
    bosso= obj_new('IDL_IDLBridge')
    qsoo= obj_new('IDL_IDLBridge')
    qsolowzo= obj_new('IDL_IDLBridge')
    everythingo= obj_new('IDL_IDLBridge')
    ;;setVar
    ;if ~keyword_set(galex) then galex= 0
    ;if ~keyword_set(ukidss) then ukidss= 0
    if ~keyword_set(zfour) then zfour= 0
    if ~keyword_set(full) then full= 0
    bosso->SetVar, "flux", flux
    bosso->SetVar, "flux_ivar", flux_ivar
    bosso->SetVar, "i_qsobossz", i_qsobossz
    bosso->SetVar, "dndi_qsobossz", dndi_qsobossz
    bosso->SetVar, "galex", keyword_set(galex)
    bosso->SetVar, "ukidss", keyword_set(ukidss)
    bosso->SetVar, "zfour", zfour
    qsoo->SetVar, "flux", flux
    qsoo->SetVar, "flux_ivar", flux_ivar
    qsoo->SetVar, "i_qso", i_qso
    qsoo->SetVar, "dndi_qso", dndi_qso
    qsoo->SetVar, "galex", keyword_set(galex)
    qsoo->SetVar, "ukidss", keyword_set(ukidss)
    qsoo->SetVar, "zfour", zfour
    qsolowzo->SetVar, "flux", flux
    qsolowzo->SetVar, "flux_ivar", flux_ivar
    qsolowzo->SetVar, "galex", keyword_set(galex)
    qsolowzo->SetVar, "ukidss", keyword_set(ukidss)
    qsolowzo->SetVar, "zfour", zfour
    qsolowzo->SetVar, "i_qsolowz", i_qsolowz
    qsolowzo->SetVar, "dndi_qsolowz", dndi_qsolowz
    everythingo->SetVar, "flux", flux
    everythingo->SetVar, "flux_ivar", flux_ivar
    everythingo->SetVar, "i_everything", i_everything
    everythingo->SetVar, "dndi_everything", dndi_everything
    everythingo->SetVar, "galex", keyword_set(galex)
    everythingo->SetVar, "ukidss", keyword_set(ukidss)
    everythingo->SetVar, "zfour", zfour
    everythingo->SetVar, "full", full
    ;;execute likelihoods
    count= 0
    catch, err_status
    IF err_status NE 0 THEN BEGIN  
        IF keyword_set(verbose) THEN BEGIN
            PRINT, 'Error index: ', err_status  
            PRINT, 'Error message: ', !ERROR_STATE.MSG  
        ENDIF
        count+= 1
        if count EQ 4 then CATCH, /CANCEL  
    ENDIF
    IF keyword_set(verbose) THEN print, "Calculating likelihoods ..."
    IF count LT 1 THEN bosso->Execute, 'bossqsolike= eval_colorprob(flux,flux_ivar,/qso,/bossz,galex=galex,ukidss=ukidss,zfour=zfour)', /nowait
    IF count LT 2 THEN qsoo->Execute, "qsolike= eval_colorprob(flux,flux_ivar,/qso,galex=galex,ukidss=ukidss,zfour=zfour)", /nowait
    IF count LT 3 THEN qsolowzo->Execute, "qsolowzlike= eval_colorprob(flux,flux_ivar,/qso,/lowz,galex=galex,ukidss=ukidss,zfour=zfour)", /nowait
    IF count LT 4 THEN everythingo->Execute, "everythinglike= eval_colorprob(flux,flux_ivar,galex=galex,ukidss=ukidss,zfour=zfour,full=full)", /nowait
    catch, /cancel
    ;;check status
    while (bosso->Status() EQ 1 or qsoo->Status() EQ 1 or qsolowzo->Status() EQ 1 or everythingo->Status() EQ 1) do wait, 2
    ;;execute number counts
    err_status= 0
    count= 0
    catch, err_status
    IF err_status NE 0 THEN BEGIN  
        if keyword_set(verbose) then begin
            PRINT, 'Error index: ', err_status  
            PRINT, 'Error message: ', !ERROR_STATE.MSG
        endif
        count+= 1
        if count EQ 4 then CATCH, /CANCEL  
    ENDIF
    if keyword_set(verbose) then print, "Calculating number counts ..."
    IF count LT 1 THEN bosso->Execute, "bossqsonumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)", /nowait
    IF count LT 2 THEN qsoo->Execute, "qsonumber= eval_iprob(flux[3,*],i_qso,dndi_qso)", /nowait
    IF count LT 3 THEN qsolowzo->Execute, "qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)", /nowait
    IF count LT 4 THEN everythingo->Execute, "everythingnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)", /nowait
    while (bosso->Status() EQ 1 or qsoo->Status() EQ 1 or qsolowzo->Status() EQ 1 or everythingo->Status() EQ 1) do wait, 2
    ;;Get variables back
    bossqsolike= bosso->GetVar("bossqsolike")
    bossqsonumber= bosso->GetVar("bossqsonumber")
    qsolike= qsoo->GetVar("qsolike")
    qsonumber= qsoo->GetVar("qsonumber")
    qsolowzlike= qsolowzo->GetVar("qsolowzlike")
    qsolowznumber= qsolowzo->GetVar("qsolowznumber")
    everythinglike= everythingo->GetVar("everythinglike")
    everythingnumber= everythingo->GetVar("everythingnumber")
    obj_destroy, bosso
    obj_destroy, qsoo
    obj_destroy, qsolowzo
    obj_destroy, everythingo
ENDIF ELSE BEGIN
    if keyword_set(verbose) then splog,'calculating bossqsolike'
    bossqsolike= eval_colorprob(flux,flux_ivar,/qso,/bossz,galex=galex,ukidss=ukidss,zfour=zfour)

    if keyword_set(verbose) then splog,'calculating bossqsonumber'
    bossqsonumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)

    if keyword_set(verbose) then splog,'calculating qsolike'
    qsolike= eval_colorprob(flux,flux_ivar,/qso,galex=galex,ukidss=ukidss,zfour=zfour)

    if keyword_set(verbose) then splog,'calculating qsonumber'
    qsonumber= eval_iprob(flux[3,*],i_qso,dndi_qso)

    if keyword_set(verbose) then splog,'calculating qsolowzlike'
    qsolowzlike= eval_colorprob(flux,flux_ivar,/qso,/lowz,galex=galex,ukidss=ukidss,zfour=zfour)

    if keyword_set(verbose) then splog,'calculating qsolowznumber'
    qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)

    if keyword_set(verbose) then splog,'calculating everythinglike'
    everythinglike= eval_colorprob(flux,flux_ivar,galex=galex,ukidss=ukidss,zfour=zfour,full=full)

    if keyword_set(verbose) then splog,'calculating everythingnumber'
    everythingnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)

ENDELSE
;;Calculate the probability that a target is a high-redshift QSO
pqso= (bossqsolike*bossqsonumber)
nonzero= where(pqso NE 0.)
IF keyword_set(full) THEN BEGIN
    IF nonzero[0] NE -1 THEN pqso[nonzero]= pqso[nonzero]/(everythinglike[nonzero]*everythingnumber[nonzero]+$
                                                           pqso[nonzero])
ENDIF ELSE BEGIN
    IF nonzero[0] NE -1 THEN pqso[nonzero]= pqso[nonzero]/(qsolike[nonzero]*qsonumber[nonzero]+$
                                                           qsolowzlike[nonzero]*qsolowznumber[nonzero]+$
                                                           everythinglike[nonzero]*everythingnumber[nonzero]+$
                                                           pqso[nonzero])
ENDELSE
IF ~keyword_set(nocuts) AND nindx[0] NE -1 THEN $
  pqso[nindx]= 0. ;;Outside of the magnitude-bounds

;;Create output structure
outStruct= {pqso:0.D, $
            bossqsolike:0.D,bossqsonumber:0.D,$
            qsolike:0.D,qsonumber:0.D,$
            qsolowzlike:0.D,qsolowznumber:0.D,$
            everythinglike:0.D,everythingnumber:0.D}
out= replicate(outStruct,ndata)
out.pqso= pqso
out.bossqsolike= bossqsolike
out.bossqsonumber= bossqsonumber
out.qsolike= qsolike
out.qsonumber= qsonumber
out.qsolowzlike= qsolowzlike
out.qsolowznumber= qsolowznumber
out.everythinglike= everythinglike
out.everythingnumber= everythingnumber
RETURN, out
END
