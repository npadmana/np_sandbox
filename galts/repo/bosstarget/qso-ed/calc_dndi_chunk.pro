;+
;   NAME:
;      calc_dndi_chunk
;   PURPOSE:
;      calculate the differential number counts per square degree for
;      a chunk and save
;   INPUT:
;      safefilename - name of the file that will hold the dndi
;   OPTIONAL INPUT:
;      datafilename - name of the file that holds the data
;   OUTPUT:
;      (none; writes the savefile)
;   HISTORY:
;     2010-04-27 - Written - Bovy (NYU)
;-
PRO CALC_DNDI_CHUNK, savefilename, datafilename=datafilename
_AREA= 143.66
_IMIN=14.0
_IMAX=24.0
_ISTEP= 0.05
nbins= long((_IMAX-_IMIN)/_ISTEP)+1

IF ~keyword_set(datafilename) THEN datafilename='../data/chunk2truth_200410_ADM.fits'
data= mrdfits(datafilename,1)
flux= data.psfflux
flux_ivar= data.psfflux_ivar
extinction= data.extinction
prep_data, flux, flux_ivar, extinction=extinction, mags=mags, var_mags=ycovar
indx= where((mags[1,*] LT 22 OR mags[2,*] < 21.85) AND mags[3,*]  GT 17.8,complement=nindx)
mags= mags[*,indx]
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
