;+
;   NAME:
;      plot_all_data
;   PURPOSE:
;      plot the 'all' data as a set of color-color plots
;   INPUT:
;      datafilename - filename that holds the data
;      basefilename - base filename for the color-color plots
;   OPTIONAL INPUTS:
;      nsamples - only plot a random subset of this size
;   KEYWORDS:
;      coadd - plot the coadded data
;   OUTPUT:
;      .ps plots
;   REVISION HISTORY:
;      2010-03-04 - Written - Bovy (NYU)
;-
PRO PLOT_ALL_DATA, datafilename=datafilename, basefilename=basefilename, $
                   coadd=coadd, nsamples=nsamples

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
    get_coadd_fluxes, alldata, flux, flux_ivar, extinction
    title= 'co-added data'
ENDIF ELSE BEGIN
    flux= alldata.psfflux
    flux_ivar= alldata.psfflux_ivar
    extinction= alldata.extinction
    title= 'single-epoch data'
ENDELSE
prep_data, flux, flux_ivar, extinction=extinction, $
  mags=mags, var_mags=var_mags
;;g-r vs. u-g
k_print, filename=basefilename+'gr_ug.ps'
djs_plot, mags[0,*]-mags[1,*], mags[1,*]-mags[2,*], title=title,$
  xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4]
k_end_print
;;r-i vs. g-r
k_print, filename=basefilename+'ri_gr.ps'
djs_plot, mags[1,*]-mags[2,*], mags[2,*]-mags[3,*], $
  xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6]
k_end_print
;;i-z vs. r-i
k_print, filename=basefilename+'iz_ri.ps'
djs_plot, mags[2,*]-mags[3,*], mags[3,*]-mags[4,*], $
  ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5]
k_end_print
END
