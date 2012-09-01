;+
;-
PRO HVSSELECTION, savefilename=savefilename, plotfilename=plotfilename, $
                   treshold=treshold, chunk=chunk, lumfunc=lumfunc, $
                  gcut=gcut
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07';;CHANGED
IF ~keyword_set(chunk) THEN chunk= 1
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
in=mrdfits(savefilename,1)
sortindx= REVERSE(SORT(in.pqso))
data= mrdfits(datafilename,1)
targetindx= sortindx[0:floor(treshold*area)]
indx= where(data[targetindx].zem GE 2.2,complement=fails); AND in[0:floor(treshold*area)].z LT 3.5)
print, n_elements(indx)/specarea
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags, var_mags=ycovar
;indxcut= where((mags[1,*] LT 22 OR mags[2,*] LT 21.85) AND mags[3,*]  GT 17.8,complement=nindx)
;data= data[indxcut]

failed= data[targetindx[fails]]


noz= where(failed.zem EQ -10000.000,complement=hasz)
prep_data, failed.psfflux, failed.psfflux_ivar, extinction=failed.extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, failed.psfflux, failed.psfflux_ivar, extinction=failed.extinction, $
  mags=imags,var_mags=var_mags
if keyword_set(gcut) THEN mags= mags[*,where(imags[1,*] GT 19. and imags[1,*] LT 20.5)]
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, cos(phi), sin(phi), /fill
;hogg_scatterplot, mags[0,*], mags[1,*], $
k_print, filename=plotfilename
djs_plot, mags[1,*], mags[0,*], psym=8,title='fails (non-confirmed QSOs + confirmed non-QSOs)',$
  xtitle=textoidl('g-r'),ytitle=textoidl('u-g'), xrange=[-0.4,-0.1],$
  yrange=[1.45,0.2]
IF keyword_set(gcut) THEN BEGIN
legend, ['19.0 < g < 20.5'], box=0.,/top
ENDIF
k_end_print

END
