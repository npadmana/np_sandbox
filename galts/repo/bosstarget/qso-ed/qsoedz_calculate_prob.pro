;+
;   NAME:
;      qsoedz_calculate_prob
;   PURPOSE:
;      calculate the extreme-deconvolution likelihood ratio,
;      marginalizing over an arbitrary redshift range
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
;      multi - parallelize calculations to 4 processors
;      full - use full DR8 fits
;   OUTPUT:
;      out - structure containing pqso, ...
;   HISTORY:
;      2010-04-30 - Written - Bovy (NYU)
;      2010-05-29 - Added Galex - Bovy
;      2010-10-30 - Added UKIDSS - Bovy
;      2010-11-02 - Added zfour - Bovy
;      2010-12-16 - Started testing 'full' - Bovy
;-
FUNCTION QSOEDZ_CALCULATE_PROB, in, z_min, z_max, $
                               lumfunc=lumfunc, galex=galex, $
                               nocuts=nocuts, ukidss=ukidss, $
                               multi=multi, full=full
_DEFAULTZMIN=0.3
_DEFAULTZMAX=5.5
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
dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
dndi_qsofile= dndipath(3.5,6.,lumfunc)
dndi_qsolowzfile= dndipath(0.3,2.2,lumfunc)
dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'

read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything

;;Now calculate all of the factors in turn
IF keyword_set(multi) THEN BEGIN
    print, "Multi-threading currently not implemented ..."
    print, "Returning ..."
    return, -1
ENDIF ELSE BEGIN
    qsolike= marginalize_colorzprob(z_min,z_max,flux,flux_ivar,galex=galex,ukidss=ukidss,norm=allqsolike)
    bossqsonumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)
    qsonumber= eval_iprob(flux[3,*],i_qso,dndi_qso)
    qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)
    qsonumber= bossqsonumber+qsonumber+qsolowznumber
    everythinglike= eval_colorprob(flux,flux_ivar,galex=galex,ukidss=ukidss,full=full)
    everythingnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)
ENDELSE
;;Calculate the probability that a target is a high-redshift QSO
pqso= (qsolike*qsonumber)
nonzero= where(pqso NE 0.)
IF keyword_set(full) THEN BEGIN
    IF nonzero[0] NE -1 THEN pqso[nonzero]= pqso[nonzero]/(everythinglike[nonzero]*everythingnumber[nonzero])
ENDIF ELSE BEGIN
    IF nonzero[0] NE -1 THEN pqso[nonzero]= pqso[nonzero]/(everythinglike[nonzero]*everythingnumber[nonzero]+$
                                                           allqsolike[nonzero]*qsonumber[nonzero])
ENDELSE
IF ~keyword_set(nocuts) AND nindx[0] NE -1 THEN $
  pqso[nindx]= 0. ;;Outside of the magnitude-bounds

;;Create output structure
outStruct= {pqso:0.D, $
            allqsolike:0D,$
            qsonumber:0.D,$
            everythinglike:0.D,everythingnumber:0.D}
out= replicate(outStruct,ndata)
out.pqso= pqso
out.qsonumber= qsonumber
out.allqsolike= allqsolike
out.everythinglike= everythinglike
out.everythingnumber= everythingnumber
RETURN, out
END
