;+
;   NAME:
;      convert_xdqsozsavs_fits
;   PURPOSE:
;      convert the XDQSOz savefiles to a single fits file
;   INPUT:
;      qso, lowz, bossz - like in eval_colorprob
;   OUTPUT:
;   HISTORY:
;      2010-09-26 - Written - Bovy (NYU)
;-
PRO CONVERT_XDQSOZSAVS_FITS, outname, galex=galex, ukidss=ukidss
_SAVEDIR= '$BOSSTARGET_DIR/data/qso-ed/zfits/'
basesavefilename= 'dc_qso_allz_fluxdist_'

_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 60
nbins= (_IMAX-_IMIN)/_ISTEP
IF keyword_set(galex) and keyword_set(ukidss) THEN BEGIN
    ndim= 11
ENDIF ELSE IF keyword_set(galex) THEN BEGIN
    ndim= 7
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    ndim= 9
ENDIF ELSE BEGIN
    ndim= 5
ENDELSE

outStruct= {imin:0D, imax:0D, xmean:dblarr(ndim,_NGAUSS), $
            xcovar:dblarr(ndim,ndim,_NGAUSS), xamp:dblarr(_NGAUSS)}

FOR ii=0L, nbins-1 DO BEGIN
    this_imin= _IMIN+(ii+0.5)*_ISTEP
    this_imax= _IMIN+(ii+1.5)*_ISTEP
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    thissavefilename+= '_z.sav'
    restore, filename=thissavefilename
    thisout= replicate(outStruct,1)
    thisout.imin= this_imin
    thisout.imax= this_imax
    thisout.xmean= xmean
    thisout.xcovar= xcovar
    thisout.xamp= amp
    mwrfits, thisout, outname
ENDFOR

END
