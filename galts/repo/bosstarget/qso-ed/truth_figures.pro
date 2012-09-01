;+
;   NAME:
;      truth_figures
;   PURPOSE:
;      make a few figures of the distribution of the QSOs selected
;   INPUT:
;      savefilename - name of the file that holds the targets
;      plotfilename
;      chunk - 1 or 2
;   OPTIONAL INPUT:
;      lumfunc - QSO luminosity function to use ('HRH07' or 'R06';
;                default= 'HRH07')
;      galexfilename - if set, get the GALEX data from this file and
;                      make UV plots as well
;   OUTPUT:
;      a few plots
;   BUGS:
;      paths not universal
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU) 
;-
PRO TRUTH_FIGURES, savefilename=savefilename, plotfilename=plotfilename, $
                   treshold=treshold, chunk=chunk, lumfunc=lumfunc, $
                   galexfilename=galexfilename
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
print, savefilename
IF ~keyword_set(treshold) THEN treshold= 20
in=mrdfits(savefilename,1)
sortindx= REVERSE(SORT(in.pqso))
data= mrdfits(datafilename,1)
targetindx= sortindx[0:floor(treshold*area)]
indx= where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5,complement=fails)
;indx= where(data[targetindx].zem GE 2.2,complement=fails)
print, n_elements(indx)/specarea
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags, var_mags=ycovar
missedindx= sortindx[floor(treshold*area)+1:n_elements(sortindx)-1]
indxmissed= where(data[missedindx].zem GE 2.2 and data[missedindx].zem LE 3.5)

IF keyword_set(galexfilename) THEN BEGIN
    galex= 1B
    galexdata= mrdfits(galexfilename,1)
    combineddata= add_data(data,galexdata=galexdata)
ENDIF ELSE BEGIN
    galex= 0B
ENDELSE

failed= data[targetindx[fails]]
failedcomb= combineddata[targetindx[fails]]
;; Add J. Hennawi's high-z tags for the objects in the catalog
X2_struct  = add_x2_tags(failed)
;failed = struct_addtags(failed, X2_struct)

missed= data[missedindx[indxmissed]]
IF galex THEN missedcombined= combineddata[missedindx[indxmissed]]

data=data[targetindx[indx]]
IF galex THEN combineddata= combineddata[targetindx[indx]]

prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=imags,var_mags=var_mags

k_print, filename=plotfilename

hogg_plothist, data.zem, /totalweight, xtitle='redshift', $
  ytitle='Number of QSO',title=strtrim(string(treshold),2)+" fibers per square degree", $
  xrange=[2.2,3.6]

hogg_plothist, imags[3,*], /totalweight, xtitle='i [mag]', $
  ytitle='Number of QSO',title=strtrim(string(treshold),2)+" fibers per square degree"


phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .5*cos(phi), .5*sin(phi), /fill

targetin= in[targetindx]
successin= targetin[indx]
djs_plot, successin.bossqsolike*successin.bossqsonumber, $
  successin.everythinglike*successin.everythingnumber, psym=8, $
  xtitle='Numerator',ytitle='STAR denominator'

;hogg_scatterplot, mags[2,*], mags[3,*], $
;djs_plot, in[indx].z, in[indx].pqso, psym=8,$
;  ytitle=textoidl('P_{QSO}'),xtitle=textoidl('redshift'), xrange=[2.15,5.],$
;  yrange=[0,2.]             ;, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[0,*], mags[1,*], $
djs_plot, mags[0,*], mags[1,*], psym=8,title='successes',$
  xtitle=textoidl('u-g'),ytitle=textoidl('g-r'), xrange=[-1,5],$
  yrange=[-.6,4];,/outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[1,*], mags[2,*], $
djs_plot, mags[1,*], mags[2,*], psym=8,$
  xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), xrange=[-.6,4],$
  yrange=[-.6,2.6];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
djs_plot, mags[2,*], mags[3,*], psym=8,$
  ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), xrange=[-.5,2.5],$
  yrange=[-.5,1.5];, /outliers, outcolor=djs_icolor('black')

IF galex THEN BEGIN
    combineddata.psfflux[5]*= 1D-9
    combineddata.psfflux[6]*= 1D-9
    prep_data, combineddata.psfflux, combineddata.psfflux_ivar, extinction=combineddata.extinction, $
      mags=mags,var_mags=var_mags
    plotthis= where(combineddata.psfflux_ivar[5] NE 1./1D5 and finite(mags[5,*]))
    thisdata= plotthis
    print, n_elements(plotthis)
    djs_plot, mags[5,thisdata]-mags[0,thisdata], $
      mags[0,thisdata]-mags[1,thisdata], $
      xtitle='NUV-u',ytitle='u-g', psym=8, yrange=[-1,5],xrange=[-3,7], $
      title='successful QSOs'
    plotthis= where(combineddata.psfflux_ivar[5] NE 1./1D5 AND combineddata.psfflux_ivar[6] NE 1./1D5 and finite(mags[5,*]) and finite(mags[6,*]))
    thisdata= plotthis
    print, n_elements(plotthis)
    djs_plot, mags[6,thisdata]-mags[5,thisdata], $
      mags[5,thisdata]-mags[0,thisdata], $
      ytitle='NUV-u',xtitle='FUV-NUV', psym=8, yrange=[-3,7],xrange=[-7.5,10]
ENDIF


;;FAILED
noz= where(failed.zem EQ -10000.000,complement=hasz)
print, strtrim(string(n_elements(hasz)))+" confirmed non-QSOs"
prep_data, failed[noz].psfflux, failed[noz].psfflux_ivar, extinction=failed[noz].extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, failed[noz].psfflux, failed[noz].psfflux_ivar, extinction=failed[noz].extinction, $
  mags=imags,var_mags=var_mags
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .1*cos(phi), .1*sin(phi), /fill
;hogg_scatterplot, mags[0,*], mags[1,*], $
djs_plot, mags[0,*], mags[1,*], psym=8,title='fails (non-confirmed QSOs)',$
  xtitle=textoidl('u-g'),ytitle=textoidl('g-r'), xrange=[-1,5],$
  yrange=[-.6,4];,/outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[1,*], mags[2,*], $
djs_plot, mags[1,*], mags[2,*], psym=8,$
  xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), xrange=[-.6,4],$
  yrange=[-.6,2.6];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
djs_plot, mags[2,*], mags[3,*], psym=8,$
  ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), xrange=[-.5,2.5],$
  yrange=[-.5,1.5];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
;djs_plot, in[fails].z, in[fails].pqso, psym=8,$
;  ytitle=textoidl('P_{QSO}'),xtitle=textoidl('redshift'), xrange=[0,2.15],$
;  yrange=[0,2.];, /outliers, outcolor=djs_icolor('black')

djs_plot, X2_struct.z_phot, imags[3,*], psym=8,$
  ytitle=textoidl('i [mag]'),xtitle=textoidl('photometric redshift')

;djs_plot, X2_struct.z_phot, in[fails].pqso, psym=8,$
;  ytitle=textoidl('P_{QSO}'),xtitle=textoidl('photometric redshift'), xrange=[0,5.5], $
;  yrange=[0,2.]             ;, /outliers, outcolor=djs_icolor('black')

;hogg_plothist, in[fails].pqso, /totalweight, xtitle=textoidl('P_{QSO}'), range=[0.,2.],$
;  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

hogg_plothist, imags[3,*], /totalweight, xtitle='i [mag]', $
  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

hogg_plothist, X2_struct.z_phot, xrange=[0.,5.5],/totalweight, xtitle='photometric redshift', $
  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

djs_plot, X2_struct[noz].z_phot, imags[3,*], psym=8,$
  ytitle=textoidl('i [mag]'),xtitle=textoidl('photometric redshift')

failedin= targetin[noz]
djs_plot, failedin.bossqsolike*failedin.bossqsonumber, $
  failedin.everythinglike*failedin.everythingnumber, psym=8, $
  xtitle='Numerator',ytitle='STAR denominator';, /ylog, /xlog




;;CONFIRMED FAILS
prep_data, failed[hasz].psfflux, failed[hasz].psfflux_ivar, extinction=failed[hasz].extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, failed[hasz].psfflux, failed[hasz].psfflux_ivar, extinction=failed[hasz].extinction, $
  mags=imags,var_mags=var_mags
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .5*cos(phi), .5*sin(phi), /fill
;hogg_scatterplot, mags[0,*], mags[1,*], $
djs_plot, mags[0,*], mags[1,*], psym=8,title='fails (confirmed non-QSOs)',$
  xtitle=textoidl('u-g'),ytitle=textoidl('g-r'), xrange=[-1,5],$
  yrange=[-.6,4];,/outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[1,*], mags[2,*], $
djs_plot, mags[1,*], mags[2,*], psym=8,$
  xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), xrange=[-.6,4],$
  yrange=[-.6,2.6];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
djs_plot, mags[2,*], mags[3,*], psym=8,$
  ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), xrange=[-.5,2.5],$
  yrange=[-.5,1.5];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
;djs_plot, in[fails].z, in[fails].pqso, psym=8,$
;  ytitle=textoidl('P_{QSO}'),xtitle=textoidl('redshift'), xrange=[0,2.15],$
;  yrange=[0,2.];, /outliers, outcolor=djs_icolor('black')

djs_plot, X2_struct[hasz].z_phot, imags[3,*], psym=8,$
  ytitle=textoidl('i [mag]'),xtitle=textoidl('photometric redshift')

;djs_plot, X2_struct.z_phot, in[fails].pqso, psym=8,$
;  ytitle=textoidl('P_{QSO}'),xtitle=textoidl('photometric redshift'), xrange=[0,5.5], $
;  yrange=[0,2.]             ;, /outliers, outcolor=djs_icolor('black')

;hogg_plothist, in[fails].pqso, /totalweight, xtitle=textoidl('P_{QSO}'), range=[0.,2.],$
;  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

hogg_plothist, failed[hasz].zem, xrange=[0.,2.2],/totalweight, xtitle='redshift', $
  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

hogg_plothist, imags[3,*], /totalweight, xtitle='i [mag]', $
  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"

hogg_plothist, X2_struct[hasz].z_phot, xrange=[0.,5.5],/totalweight, xtitle='photometric redshift', $
  ytitle='Number',title=strtrim(string(treshold),2)+" fibers per square degree"


;targetin= in[targetindx]
failedin= targetin[hasz]

djs_plot, failedin.bossqsolike*failedin.bossqsonumber, $
  failedin.everythinglike*failedin.everythingnumber, psym=8, $
  xtitle='Numerator',ytitle='STAR denominator';, /ylog, /xlog




;;MISSED
print, strtrim(string(n_elements(missed.psfflux[0])),2)+" missed QSOs = "+strtrim(string(n_elements(missed.psfflux[0])/specarea,format='(F4.1)'),2)+" QSO / deg^2"

prep_data, missed.psfflux, missed.psfflux_ivar, extinction=missed.extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, missed.psfflux, missed.psfflux_ivar, extinction=missed.extinction, $
  mags=imags,var_mags=var_mags

hogg_plothist, missed.zem, /totalweight, xtitle='redshift', $
  ytitle='Number of QSO missed',title=strtrim(string(treshold),2)+" fibers per square degree", $
  xrange=[2.2,3.6]

hogg_plothist, imags[3,*], /totalweight, xtitle='i [mag]', $
  ytitle='Number of QSO missed',title=strtrim(string(treshold),2)+" fibers per square degree"


phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .5*cos(phi), .5*sin(phi), /fill


;hogg_scatterplot, mags[0,*], mags[1,*], $
djs_plot, mags[0,*], mags[1,*], psym=8,title='misses',$
  xtitle=textoidl('u-g'),ytitle=textoidl('g-r'), xrange=[-1,5],$
  yrange=[-.6,4];,/outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[1,*], mags[2,*], $
djs_plot, mags[1,*], mags[2,*], psym=8,$
  xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), xrange=[-.6,4],$
  yrange=[-.6,2.6];, /outliers, outcolor=djs_icolor('black')

;hogg_scatterplot, mags[2,*], mags[3,*], $
djs_plot, mags[2,*], mags[3,*], psym=8,$
  ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), xrange=[-.5,2.5],$
  yrange=[-.5,1.5];, /outliers, outcolor=djs_icolor('black')

IF galex THEN BEGIN
    missedcombined.psfflux[5]*= 1D-9
    missedcombined.psfflux[6]*= 1D-9
    prep_data, missedcombined.psfflux, missedcombined.psfflux_ivar, extinction=missedcombined.extinction, $
      mags=mags,var_mags=var_mags
    plotthis= where(missedcombined.psfflux_ivar[5] NE 1./1D5 and finite(mags[5,*]))
    thisdata= plotthis
    print, n_elements(plotthis)
    IF thisdata[0] NE -1 THEN djs_plot, mags[5,thisdata]-mags[0,thisdata], $
      mags[0,thisdata]-mags[1,thisdata], $
      xtitle='NUV-u',ytitle='u-g', psym=8, yrange=[-1,5],xrange=[-3,7], $
      title='missed QSOs'
    plotthis= where(missedcombined.psfflux_ivar[5] NE 1./1D5 AND missedcombined.psfflux_ivar[6] NE 1./1D5 and finite(mags[5,*]) and finite(mags[6,*]))
    thisdata= plotthis
    print, n_elements(plotthis)
    IF plotthis[0] NE -1 THEN djs_plot, mags[6,thisdata]-mags[5,thisdata], $
      mags[5,thisdata]-mags[0,thisdata], $
      ytitle='NUV-u',xtitle='FUV-NUV', psym=8, yrange=[-3,7],xrange=[-7.5,10]
ENDIF



k_end_print
END
