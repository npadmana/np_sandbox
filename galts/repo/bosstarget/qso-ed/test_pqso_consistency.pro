;+
;   NAME:
;      test_pqso_consistency
;   PURPOSE:
;      test whether the QSOs found are consistent with the calculated
;      probabilities p(QSO)
;   INPUT:
;      chunk - chunk
;      plotfilename - filename for plot
;      treshold - targetting treshold
;      bins - number of bins in pqso to consider
;      lumfunc - QSO luminosity function to use ('HRH07' or 'R06';
;                default= 'HRH07')
;   KEYWORDS:
;      confirmed - only use confirmed non-QSO
;   OUTPUT:
;      figure
;   HISTORY:
;      2010-05-11 - Written - Bovy (NYU)
;-
PRO TEST_PQSO_CONSISTENCY, chunk, confirmed=confirmed, treshold=treshold, $
                           bins=bins, plotfilename=plotfilename, $
                           lumfunc=lumfunc, savefilename=savefilename
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07';;CHANGED
IF chunk EQ 1 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits'
    IF ~keyword_set(savefilename) THEN savefilename= 'chunk1_extreme_deconv_'+lumfunc+'.fits'
    specarea= 81.2
    area= 219.93
ENDIF ELSE IF chunk EQ 2 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits'
    IF ~keyword_set(savefilename) THEN savefilename= 'chunk2_extreme_deconv_'+lumfunc+'.fits'
    specarea= 95.7
    area= 143.66
ENDIF ELSE BEGIN
    print, "No chunk "+strtrim(chunk)
    print, "returning ..."
    RETURN
ENDELSE

IF ~keyword_set(treshold) THEN treshold= 20
IF ~keyword_set(bins) THEN bins= 10

in=mrdfits(savefilename,1)
sortindx= REVERSE(SORT(in.pqso))
data= mrdfits(datafilename,1)
targetindx= sortindx[0:floor(treshold*area)]
indx= where(data[targetindx].zem GE 2.2 AND data[targetindx].zem LE 3.5,complement=fails)
print, n_elements(indx)/specarea
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags, var_mags=ycovar

failed= data[targetindx[fails]]

ptres= in[targetindx[n_elements(targetindx)-1]].pqso
pbins= dindgen(bins+1)/bins*(1.-ptres)+ptres
pbins[bins]= 10000
frac= dblarr(bins)
FOR ii=0L, bins-1 DO BEGIN
    indx= where(in[targetindx].pqso GT pbins[ii] AND $
                in[targetindx].pqso LE pbins[ii+1])
    print, double(n_elements(where(data[targetindx[indx]].zem GE 2.2 AND data[targetindx[indx]].zem LE 3.5))), n_elements(indx)
    frac[ii]= double(n_elements(where(data[targetindx[indx]].zem GE 2.2 AND $
                                           data[targetindx[indx]].zem LE 3.5)))/$
      n_elements(indx)/specarea*area
ENDFOR

plotpbins= dblarr(bins)
FOR ii=0L, bins-1 DO plotpbins[ii]= (pbins[ii]+pbins[ii+1])/2.
plotpbins[bins-1]= 1.
k_print, filename=plotfilename
djs_plot, plotpbins, frac, xtitle='p(QSO)',ytitle='# QSO/# targets'
k_end_print
END
