;+
;   NAME:
;      convert_xdsavs_fits
;   PURPOSE:
;      convert the XD savefiles to a single fits file for each class
;   INPUT:
;      qso, lowz, bossz - like in eval_colorprob
;   OUTPUT:
;   HISTORY:
;      2010-09-26 - Written - Bovy (NYU)
;-
PRO CONVERT_XDSAVS_FITS, outname, qso=qso, lowz=lowz, bossz=bossz, $
                         galex=galex, ukidss=ukidss
                         
_SAVEDIR= '$BOSSTARGET_DIR/data/qso-ed/fits/'
IF keyword_set(qso) AND keyword_set(lowz) THEN BEGIN
    basesavefilename= 'dc_qso_lowz_fluxdist_'
ENDIF ELSE IF keyword_set(qso) AND keyword_set(bossz) THEN BEGIN
    basesavefilename= 'dc_qso_bossz_fluxdist_'
ENDIF ELSE IF keyword_set(qso) THEN BEGIN
    basesavefilename= 'dc_qso_fluxdist_'
ENDIF ELSE BEGIN
    basesavefilename= 'dc_fluxdist_'
ENDELSE

_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 20
nbins= (_IMAX-_IMIN)/_ISTEP
IF keyword_set(galex) and keyword_set(ukidss) THEN BEGIN
    ndim= 10
ENDIF ELSE IF keyword_set(galex) THEN BEGIN
    ndim= 6
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    ndim= 8
ENDIF ELSE BEGIN
    ndim= 4
ENDELSE

outStruct= {imin:0D, imax:0D, xmean:dblarr(ndim,_NGAUSS), $
            xcovar:dblarr(ndim,ndim,_NGAUSS), xamp:dblarr(_NGAUSS)}

FOR ii=0L, nbins-1 DO BEGIN
    this_imin= _IMIN+(ii+0.5)*_ISTEP
    this_imax= _IMIN+(ii+1.5)*_ISTEP
    thissavefilename= _SAVEDIR+basesavefilename+strtrim(string(_IMIN+ii*_ISTEP,format='(F4.1)'),2)+'_i_'+strtrim(string(_IMIN+ii*_ISTEP+_IWIDTH,format='(F4.1)'),2)+'_'+strtrim(string(_NGAUSS),2)
    IF keyword_set(galex) THEN thissavefilename+= '_galex'
    IF keyword_set(ukidss) THEN thissavefilename+= '_ukidss'
    thissavefilename+= '.sav'
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
