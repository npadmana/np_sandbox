;+
;   NAME:
;      plot_diagnostics
;   PURPOSE:
;      plot some diagnostics of the data (noise, etc) to figure out
;      what is going on!
;   INPUT:
;      datafilename - filename that holds the data
;      basefilename - base filename for the color-color plots
;   KEYWORDS:
;      coadd - plot the coadded data
;   OUTPUT:
;      various plot with basename basefilename
;   HISTORY:
;      2010-03-08 - Written - Bovy (NYU)
;-
PRO PLOT_DIAGNOSTICS, datafilename=datafilename, basefilename=basefilename, $
                   coadd=coadd
IF ~keyword_set(datafilename) THEN BEGIN
    IF keyword_set(coadd) THEN datafilename= '../data/coaddedMatch.fits' ELSE $
      datafilename= '../data/singleEpochMatch.fits'
ENDIF
;;Open file
alldata= mrdfits(datafilename,1)
if keyword_set(nsamples) THEN BEGIN
    ndata= n_elements(alldata.ra)
    randindx= floor(randomu(seed,nsamples)*ndata)
    alldata= alldata[randindx]
ENDIF
IF keyword_set(coadd) THEN BEGIN
    flux= alldata.flux_mean
    flux_ivar= alldata.flux_mean_ivar
ENDIF ELSE BEGIN
    flux= alldata.psfflux
    flux_ivar= alldata.psfflux_ivar
    extinction= alldata.extinction
ENDELSE
prep_data, flux, flux_ivar, extinction=extinction, $
  mags=mags, var_mags=var_mags, /colors

;;Noise as a function of u-g
k_print, filename=basefilename+'_noise_ug.ps'
djs_plot, mags[0,*],var_mags[0,*], $
  xtitle='u-g',ytitle='\sigma^2_{u-g}',psym=3,xrange=[-1,5], yrange=[0,2]
k_end_print
k_print, filename=basefilename+'_noise_ug_dens.ps'
bovy_density, hist_2d(mags[0,*],var_mags[0,*],bin1=.1,bin2=.05,min1=-1,max1=5,min2=0,max2=2), $
  [-1,5], [0,2], xtitle='u-g',ytitle='\sigma^2_{u-g}', grid=[60,40],/flip,/log
k_end_print

k_print, filename=basefilename+'_noise_gr_noise_ug.ps'
djs_plot, var_mags[0,*],var_mags[1,*], $
  xtitle='\sigma^2_{u-g}',ytitle='\sigma^2_{g-r}',psym=3,xrange=[0,2], yrange=[0,2]
k_end_print

END
