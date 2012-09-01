;+
;   NAME:
;      plot_all_data_magbin
;   PURPOSE:
;      plot the 'all' data as a set of color-color plots in an i-band
;      magnitude bin
;   INPUT:
;      ilow, ihigh - lower and upper limit for the mag bin (*not*
;                    according to astronomers)
;      datafilename - filename that holds the data
;      basefilename - base filename for the color-color plots
;   OPTIONAL INPUTS:
;      nsamples - only plot a random subset of this size
;      uvdatafilename - name of the file that holds the uv data
;      nirdatafilename - name of the file that holds the nir data
;      charsize - charsize for plots
;      legendcharsize - charsize to use for legend in plots
;      noutliers - number of outliers
;   KEYWORDS:
;      coadd - plot the coadded data
;      hoggscatter - hogg_scatterplot instead of straight scatter plot
;      plotfluxes - plot fluxes, not colors
;      normcoadd - normalize the single epoch fluxes using the
;                  co-added i-band flux
;      normcenter - normalize to the center of the bin (only for
;                   co-add at this point)
;                   has preference over normcoadd
;      galex - also plot galex data
;      ukidss - also plot ukidss data
;      full - use the full data set
;   OUTPUT:
;      .ps plots
;   REVISION HISTORY:
;      2010-03-11 - Written - Bovy (NYU)
;      2010-05-25 - Added galex - Bovy
;-
PRO PLOT_ALL_DATA_MAGBIN, lowhigh, hoggscatter=hoggscatter,$
                          datafilename=datafilename, $
                          basefilename=basefilename, $
                          coadd=coadd, nsamples=nsamples, $
                          plotfluxes=plotfluxes, normcoadd=normcoadd, $
                          normcenter=normcenter, $
                          galex=galex, uvdatafilename=uvdatafilename, $
                          ukidss=ukidss, nirdatafilename=nirdatafilename, $
                          charsize=charsize, legendcharsize=legendcharsize, $
                          full=full, noutliers=noutliers

IF ~keyword_set(charsize) THEN charsize= 1.15
IF ~keyword_set(legendcharsize) THEN legendcharsize= 1.6
IF ~keyword_set(noutliers) THEN noutliers= 5000

x=strsplit(lowhigh,'_i_',/extract)
ilow= double(x[0])
ihigh= double(x[1])

IF ~keyword_set(datafilename) THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
ENDIF
IF ~keyword_set(uvdatafilename) THEN uvdatafilename= '$BOVYQSOEDDATA/Bovy_Likeli_everything_sdss_galex.fits'
;;Open file
IF ~keyword_set(full) THEN BEGIN
    IF keyword_set(coadd) THEN BEGIN
        alldata= mrdfits(datafilename,1)
    ENDIF ELSE BEGIN
        alldata= mrdfits(datafilename,2)
    ENDELSE
    if keyword_set(nsamples) THEN BEGIN
        ndata= n_elements(alldata.ra)
        randindx= floor(randomu(seed,nsamples)*ndata)
        alldata= alldata[randindx]
    ENDIF
    IF keyword_set(coadd) THEN BEGIN
        flagstruct= mrdfits(datafilename,2)
        get_coadd_fluxes, alldata, flux, flux_ivar, extinction, flagstruct=flagstruct
        title= 'co-added data'
    ENDIF ELSE BEGIN
        ;;Trim to right flags
        indx= ed_qso_trim(alldata)
        alldata= alldata[indx]
        ;;Trim to non-varying objects
        coadddata= mrdfits(datafilename,1)
        coadddata= coadddata[indx]
        nonvarindx= where(coadddata.flux_clip_rchi2[2] LT 1.4)
        alldata= alldata[nonvarindx]
        flux= alldata.psfflux
        flux_ivar= alldata.psfflux_ivar
        extinction= alldata.extinction
        title= 'single-epoch data'
    ENDELSE
    IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, $
      extinction=extinction, mags=mags, var_mags=ycovar, /nbyncovar ELSE $
      prep_data, flux, flux_ivar, $
      mags=mags, var_mags=ycovar, /nbyncovar      
    thisdata= where(mags[3,*] GE ilow AND mags[3,*] LT ihigh)
    alldata= alldata[thisdata]
    IF keyword_set(coadd) THEN BEGIN
        get_coadd_fluxes, alldata, flux, flux_ivar, extinction
    ENDIF ELSE BEGIN
        flux= alldata.psfflux
        flux_ivar= alldata.psfflux_ivar
        extinction= alldata.extinction
    ENDELSE
ENDIF ELSE BEGIN
    fullbin= floor((ilow-12.9)/0.1)
    alldata= mrdfits(get_choppedsweeps_name(fullbin,/path),1)
    flux= alldata.psfflux
    flux_ivar= alldata.psfflux_ivar
    extinction= alldata.extinction
    title= 'single-epoch data'
ENDELSE
IF keyword_set(ukidss) THEN BEGIN
    nirdata= mrdfits(nirdatafilename,1)
    get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, alldata
ENDIF ELSE BEGIN
    nirflux= 0.
    nirflux_ivar= 0.
    nirextinction= 0.
ENDELSE
IF keyword_set(galex) THEN BEGIN
    uvdata= mrdfits(uvdatafilename,1)
    get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, alldata
ENDIF ELSE BEGIN
    uvflux= 0.
    uvflux_ivar= 0.
    uvextinction= 0.
ENDELSE
combine_fluxes, flux, flux_ivar, extinction, anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
flux= outflux
flux_ivar= outflux_ivar
extinction= outextinction
IF keyword_set(plotfluxes) THEN BEGIN
    IF keyword_set(normcoadd) AND ~keyword_set(coadd) THEN BEGIN
        IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, $
          extinction=extinction, mags=ydata, var_mags=ycovar, /nbyncovar, /fluxes ELSE $
          prep_data, flux, flux_ivar, mags=ydata, var_mags=ycovar, /nbyncovar, /fluxes
        mags= ydata
        ndata= n_elements(thisdata)
        plotthis= dblarr(4,ndata)
        coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
        coadddata= mrdfits(coadddatafilename,1)
        coadddata= coadddata[indx]
        coadddata= coadddata[nonvarindx]
        coadddata= coadddata[thisdata]
        coaddflux= coadddata.psfflux
        FOR ii=0L, ndata-1 DO BEGIN
            plotthis[0,ii]= mags[0,ii]/coaddflux[3,ii]
            plotthis[1,ii]= mags[1,ii]/coaddflux[3,ii]
            plotthis[2,ii]= mags[2,ii]/coaddflux[3,ii]
            plotthis[3,ii]= mags[4,ii]/coaddflux[3,ii]
        ENDFOR
    ENDIF ELSE BEGIN
        IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, $
          extinction=extinction, mags=ydata, var_mags=ycovar, /nbyncovar, /relfluxes ELSE $
          prep_data, flux, flux_ivar, mags=ydata, var_mags=ycovar, /nbyncovar, /relfluxes
        plotthis= ydata
    ENDELSE
    ndata= n_elements(plotthis[0,*])
    ;;u vs g
    k_print, filename=basefilename+lowhigh+'_g_u.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, plotthis[0,*], plotthis[1,*], $
          title=title, $
          xtitle=textoidl('f_u'),ytitle=textoidl('f_g'), $
          xrange=[-0.7,2], yrange=[-0.5,2], $
          xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, plotthis[0,ioutliers], $
          plotthis[1,ioutliers], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[0,*], plotthis[1,*], $
          xtitle=textoidl('f_u'),ytitle=textoidl('f_g'), psym=3, title=title, xrange=[-0.7,2], yrange=[-0.5,2], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[0,*], plotthis[1,*], $
          xtitle='f_u',ytitle='f_g', psym=3, title=title, xrange=[-0.7,2], yrange=[-0.5,2], charsize=charsize
    ENDELSE
    legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
      box= 0., /left, charsize=legendcharsize
    legend, [strtrim(string(ndata),2)+' objects'], $
      box= 0., /right, charsize=legendcharsize
    k_end_print
    ;;r-i vs. g-r
    k_print, filename=basefilename+lowhigh+'_r_g.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, plotthis[1,*], plotthis[2,*], $
          ytitle=textoidl('f_r'),xtitle=textoidl('f_g'), $
          yrange=[0.,1.5], xrange=[-0.5,2], $
          xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, plotthis[1,ioutliers], $
          plotthis[2,ioutliers], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[1,*], plotthis[2,*], $
          xtitle=textoidl('f_g'),ytitle=textoidl('f_r'), psym=3, xrange=[-0.5,2], yrange=[0.,1.5], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[1,*], plotthis[2,*], $
          xtitle='f_g',ytitle='f_r', psym=3, xrange=[-0.5,2], yrange=[0.,1.5], charsize=charsize
    ENDELSE
    k_end_print
    ;;i-z vs. r-i
    k_print, filename=basefilename+lowhigh+'_z_r.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, plotthis[2,*], plotthis[3,*], $
          xtitle=textoidl('f_r'),ytitle=textoidl('f_z'), $
          xrange=[0.,1.5], yrange=[0.,3.], $
          xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, plotthis[2,ioutliers], $
          plotthis[3,ioutliers], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,*], plotthis[3,*], $
          ytitle=textoidl('f_z'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,3.], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[2,*], plotthis[3,*], $
          ytitle='f_z',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,3.], charsize=charsize
    ENDELSE
    k_end_print
    IF keyword_set(galex) THEN BEGIN
        plotindx= where(flux_ivar[4,*] NE 1./1D5)
        ndata= n_elements(plotindx)
        ;;nuv vs r
        k_print, filename=basefilename+lowhigh+'_nuv_r.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,plotindx], plotthis[4,plotindx], $
          ytitle=textoidl('f_{NUV}'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,.01], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[2,plotindx], plotthis[4,plotindx], $
          ytitle='f_{NUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,.01], charsize=charsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize=legendcharsize
        k_end_print
        plotindx= where(flux_ivar[5,*] NE 1./1D5 and flux_ivar[4,*] NE 1./1D5)
        ndata= n_elements(plotindx)
        ;;fuv vs r
        k_print, filename=basefilename+lowhigh+'_fuv_r.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,plotindx], plotthis[5,plotindx], $
          ytitle=textoidl('f_{FUV}'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,0.005], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[2,plotindx], plotthis[5,plotindx], $
          ytitle='f_{FUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,.005], charsize=charsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize=legendcharsize
        k_end_print
    ENDIF
ENDIF ELSE BEGIN
    IF keyword_set(galex) THEN BEGIN
        flux[5,*]*= 1D-9
        flux[6,*]*= 1D-9
    ENDIF
    IF keyword_set(extinction) THEN prep_data, flux, flux_ivar, extinction=extinction, $
      mags=mags, var_mags=var_mags ELSE $
      prep_data, flux, flux_ivar, mags=mags, var_mags=var_mags
    thisdata= where(mags[3,*] GE ilow AND mags[3,*] LT ihigh)
    ;;g-r vs. u-g
    k_print, filename=basefilename+lowhigh+'_gr_ug.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, mags[0,thisdata]-mags[1,thisdata], $
          mags[1,thisdata]-mags[2,thisdata], title=title, $
          ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), $
          xrange=[-1,5],$
          yrange=[-.6,4], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, mags[0,thisdata[ioutliers]]-mags[1,thisdata[ioutliers]], $
          mags[1,thisdata[ioutliers]]-mags[2,thisdata[ioutliers]], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[0,thisdata]-mags[1,thisdata], $
          mags[1,thisdata]-mags[2,thisdata], title=title, /outliers,outcolor=djs_icolor('black'),$
          xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], charsize=charsize ELSE $
          djs_plot, mags[0,thisdata]-mags[1,thisdata], mags[1,thisdata]-mags[2,thisdata], title=title,$
          xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], charsize=charsize
    ENDELSE
    legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
      box= 0., /left, charsize=legendcharsize
    legend, [strtrim(string(n_elements(thisdata)),2)+' objects'], $
      box= 0., /right, charsize=legendcharsize
    k_end_print
   ;;r-i vs. g-r
    k_print, filename=basefilename+lowhigh+'_ri_gr.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, mags[1,thisdata]-mags[2,thisdata], $
          mags[2,thisdata]-mags[3,thisdata], $
          xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), $
          yrange=[-.6,2.6],$
          xrange=[-.6,4], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, mags[1,thisdata[ioutliers]]-mags[2,thisdata[ioutliers]], $
          mags[2,thisdata[ioutliers]]-mags[3,thisdata[ioutliers]], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[1,thisdata]-mags[2,thisdata], $
          mags[2,thisdata]-mags[3,thisdata], /outliers, outcolor=djs_icolor('black'), $
          xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6], charsize=charsize ELSE $
          djs_plot, mags[1,thisdata]-mags[2,thisdata], mags[2,thisdata]-mags[3,thisdata], $
          xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6], charsize=charsize
    ENDELSE
    k_end_print
   ;;i-z vs. r-i
    k_print, filename=basefilename+lowhigh+'_iz_ri.ps'
    IF keyword_set(full) THEN BEGIN
        hogg_scatterplot, mags[2,thisdata]-mags[3,thisdata], $
          mags[3,thisdata]-mags[4,thisdata], $
          ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), $
          xrange=[-.6,2.6],$
          yrange=[-.5,1.5], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
          /internal_weight, charsize=charsize
        sample_outliers, ioutliers, noutliers
        djs_oplot, mags[2,thisdata[ioutliers]]-mags[3,thisdata[ioutliers]], $
          mags[3,thisdata[ioutliers]]-mags[4,thisdata[ioutliers]], psym=3
    ENDIF ELSE BEGIN
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[2,thisdata]-mags[3,thisdata], $
          mags[3,thisdata]-mags[4,thisdata], /outliers, outcolor=djs_icolor('black'),$
          ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5], charsize=charsize ELSE $
          djs_plot, mags[2,thisdata]-mags[3,thisdata], mags[3,thisdata]-mags[4,thisdata], $
          ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5], charsize=charsize
    ENDELSE
    k_end_print
    IF keyword_set(galex) THEN BEGIN
        plotthis= where(flux_ivar[5,thisdata] NE 1./1D5 AND flux_ivar[6,thisdata] NE 1./1D5 and finite(mags[5,thisdata]) and finite(mags[6,thisdata]))
        thisdata= thisdata[plotthis]
        ndata= n_elements(plotthis)
        k_print, filename=basefilename+lowhigh+'_nu_fn.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[6,thisdata]-mags[5,thisdata], $
          mags[5,thisdata]-mags[0,thisdata], /outliers, outcolor=djs_icolor('black'),$
          ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10], charsize=charsize ELSE $
        djs_plot, mags[6,thisdata]-mags[5,thisdata], mags[5,thisdata]-mags[0,thisdata], $
          ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10], charsize=charsize
        legend, [strtrim(string(n_elements(thisdata)),2)+' objects'], $
          box= 0., /right, charsize=legendcharsize
        k_end_print       
        k_print, filename=basefilename+lowhigh+'_ug_nu.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[5,thisdata]-mags[0,thisdata], $
          mags[0,thisdata]-mags[1,thisdata], /outliers, outcolor=djs_icolor('black'),$
          xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7], charsize=charsize ELSE $
        djs_plot, mags[5,thisdata]-mags[0,thisdata], mags[0,thisdata]-mags[1,thisdata], $
          xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7], charsize=charsize
        k_end_print       
    ENDIF
ENDELSE
END
