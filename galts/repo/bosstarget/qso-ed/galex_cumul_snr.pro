;+
;   NAME:
;      galex_cumul_snr
;   PURPOSE:
;      make a plot showing the cumulative histogram of galex snr
;   INPUT:
;      galexfilename - file that holds the galex data
;      coadddatafilename - file that has the coadded data
;      imin - minimum i-band magnitude
;      imax - maximum i-band magnitude
;      plotfilename - filename for figure
;   OUTPUT:
;      figure in plotfilename
;   HISTORY:
;      2010-05-27 - Written - Bovy (NYU)
;-
PRO GALEX_CUMUL_SNR, galexfilename=galexfilename, imin=imin, imax=imax, $
                     plotfilename=plotfilename, $
                     coadddatafilename=coadddatafilename
IF ~keyword_set(galexfilename) THEN galexfilename= '$BOVYQSOEDDATA/Bovy_Likeli_everything_sdss_galex.fits'
IF ~keyword_set(coadddatafilename) THEN coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'

data= mrdfits(galexfilename,1)

data= data[where(data.nuv_fluxerr NE 0. AND data.fuv_fluxerr NE 0. and data.nuv_flux GE 0. and data.fuv_flux GE 0.)]
IF keyword_set(imin) THEN BEGIN
    IF ~keyword_set(imax) THEN BEGIN
        print, "If imin is set, imax needs to be set as well ..."
        print, "Returning ..."
        return
    ENDIF
    coadd= mrdfits(coadddatafilename,1)
    spherematch, coadd.ra, coadd.dec, data.ra, data.dec, 1/3600., match1,match2 
    data= data[match2]
    flux= sdss_deredden(coadd[match1].psfflux,coadd[match1].extinction)
    b_i = 1.8
    imags= sdss_flux2mags(flux[3,*],b_i)
    data= data[where(imags GE imin and imags LE imax)]
ENDIF
ndata= n_elements(data.ra)

nuvsnr= data.nuv_flux/data.nuv_fluxerr
fuvsnr= data.fuv_flux/data.fuv_fluxerr

sortnuv= sort(nuvsnr)
sortfuv= sort(fuvsnr)

legendcharsize= 1.5
IF keyword_set(plotfilename) THEN k_print, filename=plotfilename
djs_plot, nuvsnr[sortnuv], lindgen(ndata), xtitle='f / \sigma_f', ytitle='# objects', $
  xrange=[0,10], yrange=[0,ndata]
djs_oplot, fuvsnr[sortfuv], lindgen(ndata), linestyle=2
legend, ['NUV','FUV'], linestyle=[0,2], box=0., /right, /bottom, charsize=legendcharsize
IF keyword_set(plotfilename) THEN k_end_print
IF keyword_set(imin) THEN BEGIN
    legend, [strtrim(string(imin,format='(F4.1)'),2)+" !9l!X i !9l!X "+strtrim(string(imax,format='(F4.1)'),2)], box=0., /bottom, charsize=legendcharsize
ENDIF
END
