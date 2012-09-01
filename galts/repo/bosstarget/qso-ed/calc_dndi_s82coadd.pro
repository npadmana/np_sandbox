;+
;   NAME:
;      calc_dndi_s82coadd
;   PURPOSE:
;      calculate the differential number counts per square degree for
;      the coadded catalog on stripe82 and save them
;   INPUT:
;      savefilename - name of the file that will hold the dndi
;   OPTIONAL INPUT:
;      datafilename - name of the file that holds the data
;   OUTPUT:
;      (none; writes the savefile)
;   HISTORY:
;     2010-04-23 - Written for 'everything' - Bovy (NYU)
;     2010-04-23 - Adapted for S82 coadd - Bovy (NYU)
;-
PRO CALC_DNDI_S82COADD, savefilename
_AREA= 278.502
_IMIN=14.0
_IMAX=34.0
_ISTEP= 0.05
nbins= long((_IMAX-_IMIN)/_ISTEP)+1

data= read_s82coadd()
i= dblarr(nbins)
dndi= dblarr(nbins)

FOR ii=0L, nbins-1 DO BEGIN
    indx= where(data.i GE (_IMIN+(ii-0.5)*_ISTEP) AND $
                data.i LT (_IMIN+(ii+0.5)*_ISTEP))
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
