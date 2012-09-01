;+
;   NAME:
;      calc_dndi_everything
;   PURPOSE:
;      calculate the differential number counts per square degree for
;      the everything catalog and save them
;   INPUT:
;      savefilename - name of the file that will hold the dndi
;   OPTIONAL INPUT:
;      datafilename - name of the file that holds the data
;   OUTPUT:
;      (none; writes the savefile)
;   HISTORY:
;     2010-04-23 - Written - Bovy (NYU)
;-
PRO CALC_DNDI_EVERYTHING, savefilename, datafilename=datafilename
_AREA= 109.75
_IMIN=14.0
_IMAX=24.0
_ISTEP= 0.05
nbins= long((_IMAX-_IMIN)/_ISTEP)+1

IF ~keyword_set(datafilename) THEN datafilename='$BOVYQSOEDDATA/coaddedMatch.fits'
data= mrdfits(datafilename,1)
flagstruct= mrdfits(datafilename,2)
get_coadd_fluxes, data, flux, flux_ivar, extinction, /nobadclip, chi2cut=100, flagstruct=flagstruct
print, n_elements(flux[0,*])
prep_data, flux, flux_ivar, extinction=extinction, mags=mags, var_mags=ycovar
;indx= where((mags[1,*] LT 22 OR mags[2,*] LT 21.85) AND mags[3,*]  GT 17.8,complement=nindx)
;mags= mags[*,indx]
i= dblarr(nbins)
dndi= dblarr(nbins)

FOR ii=0L, nbins-1 DO BEGIN
    indx= where(mags[3,*] GE (_IMIN+(ii-0.5)*_ISTEP) AND $
                mags[3,*] LT (_IMIN+(ii+0.5)*_ISTEP))
    i[ii]= _IMIN+ii*_ISTEP
    if indx[0] EQ -1 THEN CONTINUE
    dndi[ii]= n_elements(indx)
ENDFOR
;;Normalize dndi
dndi= dndi/_ISTEP/_AREA

;;Write to file
OPENW, lun, savefilename, /GET_LUN
hdr= "FORPRINT: "+systime()
PRINTF, lun, hdr
FOR ii=0L, nbins-1 DO BEGIN
    PRINTF, lun, i[ii], dndi[ii]
ENDFOR
CLOSE, lun
END
