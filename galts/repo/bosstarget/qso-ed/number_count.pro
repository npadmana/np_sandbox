;+
;-
PRO NUMBER_COUNT, plotfilename=plotfilename, band=band
datafilename= '../data/coaddedMatch.fits'
coadd= mrdfits(datafilename,1)
flux= coadd.flux_clip_mean
flux_ivar= coadd.flux_mean_ivar
extinction= coadd.extinction
prep_data, flux, flux_ivar, extinction=extinction, $
  mags=mags,var_mags=var_mags
imag= mags[band,*]
nc= dblarr(57*3)
nnc= n_elements(nc)
isamples= dindgen(nnc)/(nnc-1.)*(25.3-17.7)+17.7
FOR ii=0L, nnc-1 DO nc[ii]= n_elements(where(imag LT isamples[ii]))
nc= nc/109.75

datafilename= '../data/singleEpochMatch.fits'
single= mrdfits(datafilename,1)
flux= single.psfflux
flux_ivar= single.psfflux_ivar
extinction= single.extinction
prep_data, flux, flux_ivar, extinction=extinction, $
  mags=mags,var_mags=var_mags
imag= mags[band,*]
ncs= dblarr(57*3)
nncs= n_elements(ncs)
FOR ii=0L, nncs-1 DO ncs[ii]= n_elements(where(imag LT isamples[ii]))
ncs= ncs/109.75

if band EQ 0 THEN BEGIN
    xtitle= 'u [mag]'
    ytitle= 'N(<u) [objects deg^{-2}]'
ENDIF ELSE IF band EQ 1 THEN BEGIN
    xtitle= 'g [mag]'
    ytitle= 'N(<g) [objects deg^{-2}]'
ENDIF ELSE IF band EQ 2 THEN BEGIN
    xtitle= 'r [mag]'
    ytitle= 'N(<r) [objects deg^{-2}]'
ENDIF ELSE IF band EQ 3 THEN BEGIN
    xtitle= 'i [mag]'
    ytitle= 'N(<i) [objects deg^{-2}]'
ENDIF ELSE BEGIN
    xtitle= 'z [mag]'
    ytitle= 'N(<z) [objects deg^{-2}]'
ENDELSE

k_print, filename=plotfilename
djs_plot, isamples, nc, xtitle=xtitle, ytitle=ytitle
djs_oplot, isamples, ncs, linestyle=2
k_end_print
END
