;+
;   NAME:
;      plot_deconvolved_all
;   PURPOSE:
;      plot the deconvolved 'all' distribution, either as a
;      contour plot, or a sampling
;   INPUT:
;      savefilename - filename of the savefile that holds the
;                     deconvolved color distribution
;      basefilename - base filename for the output plots
;      nsamples - number of samples to plot if plotting a sampling
;      datafilename - name of the file that holds the data (for
;                     'resampledata')
;      seed - seed for random number generator
;      charsize - charsize for plots
;      legendcharsize - charsize for legend
;      noutliers - number of outliers to plot
;   KEYWORDS:
;      sampling - plot a sampling
;      resampledata - use the data's uncertainties in the
;                     sampling NOT ADAPTED FOR ALL YET!
;                     when using fluxes, set magbin to speed this
;                     process up
;      fluxes - if set, you deconvolved fluxes and wish to sample
;               fluxes and plot their colors
;      plotfluxes - if fluxes is set, plot fluxes instead of colors
;      hoggscatter - hogg_scatterplot instead of djs_plot
;      rescaled - indicates that the fit was done to rescaled fluxes
;                 and that this is what should be plotted
;      qso - if set, this is a sampling from a qso deconvolution
;      lowz - if set, use low-z qsos
;      bossz - if set, use BOSS-redshift qsos
;      allz - if set, use all qsos
;      fitz - if set, we fit the redshift as well
;      galex - include galex fluxes
;      ukidss - include ukidss fluxes
;      zfour - use z=4 as the boundary between bossz and hiz
;      full - use full "everything" data set
;      fitz - we fit redshift as well, plot it
;      nomaglabels - don't put the magnitude bin and objects labels
;   OUTPUT:
;      various projections of the deconvolved distribution
;   REVISION HISTORY:
;      2009-12-17 - Written for qso - Bovy (NYU)
;      2010-03-04 - Adapted for all - Bovy
;      2010-04-08 - renamed to plot_deconvolved_all - Bovy
;      2010-04-16 - Adapted for qso! - Bovy (NYU)
;      2010-05-25 - Adapted to use Galex - Bovy
;-
PRO PLOT_DECONVOLVED_ALL, savefilename=savefilename, $
                          basefilename=basefilename, $
                          sampling=sampling, nsamples=nsamples, $
                          resampledata=resampledata,$
                          datafilename=datafilename, seed=seed, $
                          fluxes=fluxes, plotfluxes=plotfluxes, $
                          magbin=magbin, hoggscatter=hoggscatter, $
                          rescaled=rescaled, qso=qso, lowz=lowz, $
                          bossz=bossz, galex=galex, ukidss=ukidss, $
                          charsize=charsize, legendcharsize=legendcharsize, $
                          zfour=zfour, full=full, noutliers=noutliers, $
                          allz=allz, fitz=fitz, nomaglabel=nomaglabel
IF ~keyword_set(charsize) THEN charsize= 1.3
IF ~keyword_set(legendcharsize) THEN legendcharsize= 1.6
IF ~keyword_set(seed) THEN seed= -1L
IF ~keyword_set(noutliers) THEN noutliers= 5000
IF keyword_set(qso) AND ~keyword_set(lowz) AND ~keyword_set(allz) THEN levels= errorf(0.5*(dindgen(2)+1))
IF keyword_set(qso) THEN uvdatafilename= '$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits' ELSE $
  uvdatafilename= '$BOVYQSOEDDATA/star82-varcat-bound-ts_sdss_galex.fits'
IF keyword_set(qso) THEN nirdatafilename= '$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits' ELSE $
  nirdatafilename= '$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits'
;;Restore savefile
restore, filename=savefilename
IF keyword_set(galex) and keyword_set(qso) THEN ngalexdata= 62628
IF keyword_set(ukidss) and keyword_set(qso) THEN nukidssdata= 25510
;;Plot contours or a sampling
title= 'extreme-deconvolution'
IF keyword_set(fluxes) THEN BEGIN
    ;;Sample nsamples from the deconvolved color distribution
    nsamples= ndata
    sample_gaussians, nsamples=nsamples, mean=xmean, covar=xcovar, $
          amp=amp, sample=sample, seed=seed
    nfluxes= n_elements(sample[*,0])
    IF keyword_set(fitz) THEN BEGIN
        ;;bookkeeping
        nfluxes= nfluxes-1
        zsample= exp(sample[0,*])
        nozsample= sample[1:nfluxes,*]
        sample= nozsample
    ENDIF
    IF keyword_set(plotfluxes) THEN BEGIN
        IF keyword_set(resampledata) THEN BEGIN
            IF keyword_set(qso) THEN title= 'extreme-deconvolution with data errors' ELSE $
              title= 'extreme-deconvolution with co-add errors'
            IF keyword_set(full) THEN title= 'extreme-deconvolution with data errors'
            ;;Load the data
            IF keyword_set(qso) THEN BEGIN
                coadddatafilename= '$BOVYQSOEDDATA/qso_all_extreme_deconv.fits.gz'
            ENDIF ELSE IF keyword_set(full) THEN BEGIN
                x=strsplit(magbin,'_i_',/extract)
                ilow= double(x[0])
                ihigh= double(x[1])
                fullbin= floor((ilow-12.9)/0.1)
                coadddatafilename= get_choppedsweeps_name(fullbin,/path)
            ENDIF ELSE BEGIN
                coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
            ENDELSE
            coadddata= mrdfits(coadddatafilename,1)
            IF keyword_set(magbin) THEN BEGIN
                x=strsplit(magbin,'_i_',/extract)
                ilow= double(x[0])-0.1 ;;Make sure you don't miss any
                ihigh= double(x[1])+0.1
                IF keyword_set(qso) THEN BEGIN
                    get_qso_fluxes, coadddata, coflux, coflux_ivar, weight, $
                      lowz=lowz, bossz=bossz, zfour=zfour, allz=allz
                    coextinction= dblarr(n_elements(coflux[*,0]),n_elements(coflux[0,*]))
                    IF keyword_set(ukidss) THEN BEGIN
                        nirdata= mrdfits(nirdatafilename,1)
                        get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, coadddata
                    ENDIF ELSE BEGIN
                        nirflux= 0.
                        nirflux_ivar= 0.
                        nirextinction= 0.
                    ENDELSE
                    IF keyword_set(galex) THEN BEGIN
                        uvdata= mrdfits(uvdatafilename,1)
                        old= keyword_set(qso)
                        get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, coadddata, old=old
                    ENDIF ELSE BEGIN
                        uvflux= 0.
                        uvflux_ivar= 0.
                        uvextinction= 0.
                    ENDELSE
                    combine_fluxes, coflux, coflux_ivar, coextinction, anirflux=nirflux, $
                      bnirflux_ivar=nirflux_ivar, $
                      cnirextinction= nirextinction, duvflux=uvflux, $
                      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
                      nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
                      extinctionout=outextinction
                    coflux= outflux
                    coflux_ivar= outflux_ivar
                    coextinction= outextinction
                ENDIF ELSE IF keyword_set(full) THEN BEGIN
                    ;;get random sample
                    x= lindgen(n_elements(coadddata.ra))
                    y= randomu(seed,n_elements(coadddata.ra))
                    z= x[sort(y)]
                    n= 50000
                    z= z[0:n-1]
                    coadddata= coadddata[z]
                    coflux= coadddata.psfflux
                    coflux_ivar= coadddata.psfflux_ivar
                    coextinction= coadddata.extinction
                ENDIF ELSE BEGIN
                    get_coadd_fluxes, coadddata, coflux, coflux_ivar, $
                      coextinction
                    prep_data, coflux, coflux_ivar, extinction=coextinction,$
                      mags=mags, var_mags=ycovar
                    thiscoadddata= where(mags[3,*] GE ilow AND $
                                         mags[3,*] LT ihigh)
                    coadddata= coadddata[thiscoadddata]
                    get_coadd_fluxes, coadddata, coflux, coflux_ivar, $
                      coextinction
                    IF keyword_set(ukidss) THEN BEGIN
                        nirdata= mrdfits(nirdatafilename,1)
                        get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, coadddata
                    ENDIF ELSE BEGIN
                        nirflux= 0.
                        nirflux_ivar= 0.
                        nirextinction= 0.
                    ENDELSE
                    IF keyword_set(galex) THEN BEGIN
                        uvdata= mrdfits(uvdatafilename,1)
                        old= keyword_set(qso)
                        get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, coadddata, old=old
                    ENDIF ELSE BEGIN
                        uvflux= 0.
                        uvflux_ivar= 0.
                        uvextinction= 0.
                    ENDELSE
                    combine_fluxes, coflux, coflux_ivar, coextinction, anirflux=nirflux, $
                      bnirflux_ivar=nirflux_ivar, $
                      cnirextinction= nirextinction, duvflux=uvflux, $
                      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
                      nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
                      extinctionout=outextinction
                    coflux= outflux
                    coflux_ivar= outflux_ivar
                    coextinction= outextinction
                ENDELSE
                IF keyword_set(galex) THEN BEGIN
                    goodivar= where(coflux_ivar[5,*] NE 1./1D5 and coflux[6,*] NE 1./1D5)
                    coflux= coflux[*,goodivar]
                    coextinction= coextinction[*,goodivar]
                    coflux_ivar= coflux_ivar[*,goodivar]
                ENDIF
                IF keyword_set(ukidss) THEN BEGIN
                    goodivar= where(coflux_ivar[5,*] NE 1./1D5 and coflux[6,*] NE 1./1D5 AND $
                                    coflux_ivar[7,*] NE 1./1D5 and coflux[8,*] NE 1./1D5)
                    coflux= coflux[*,goodivar]
                    coextinction= coextinction[*,goodivar]
                    coflux_ivar= coflux_ivar[*,goodivar]
                ENDIF
                ilow+= 0.1
                ihigh-= 0.1
                IF keyword_set(rescaled) THEN BEGIN
                    IF keyword_set(coextinction) THEN prep_data, coflux, $
                      coflux_ivar, extinction=coextinction,$
                      mags=mags, var_mags=ycovar, /relfluxes ELSE $
                      prep_data, coflux, coflux_ivar,$
                      mags=mags, var_mags=ycovar, /relfluxes
                    coflux= mags
                    nobjs= n_elements(coflux[0,*])
                    coflux_var= ycovar
                ENDIF
            ENDIF
            ;;for each sample, find the data point in the co-added
            ;;catalog with the closest sdss-flux match
            nfluxes= n_elements(coflux[*,0])
            FOR jj=0L, ndata-1 DO BEGIN
                print, format = '("Working on ",i7," of ",i7,a1,$)', $
                  jj+1,ndata,string(13B)
                IF keyword_set(rescaled) THEN BEGIN
                    IF keyword_set(galex) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.,sub)
                    ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.+(coflux[6,*]-sample[6,jj])^2.+(coflux[7,*]-sample[7,jj])^2.,sub)
                    ENDIF ELSE BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.,sub)
                ENDELSE
                    lower= coflux_var[*,*,sub]
                    LA_CHOLDC, lower
                    sample[*,jj]+= lower#RANDOMN(seed,nfluxes)
                ENDIF ELSE BEGIN
                    IF keyword_set(galex) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.+(coflux[6,*]-sample[6,jj])^2.,sub)
                    ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.+(coflux[6,*]-sample[6,jj])^2.+(coflux[7,*]-sample[7,jj])^2.+(coflux[8,*]-sample[8,jj])^2.,sub)
                    ENDIF ELSE BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.,sub)
                    ENDELSE
                    FOR kk=0L, nfluxes-1 DO sample[kk,jj]+= RANDOMN(seed)*coflux_ivar[kk,sub]^(-0.5)
                ENDELSE
            ENDFOR
        ENDIF
        IF keyword_set(rescaled) THEN BEGIN
            mags= sample
        ENDIF ELSE BEGIN
            ;;divide by i-band
            mags= dblarr(nfluxes-1,ndata)
            for ii=0L, ndata-1 DO BEGIN
                mags[0,ii]= sample[0,ii]/sample[3,ii]
                mags[1,ii]= sample[1,ii]/sample[3,ii]
                mags[2,ii]= sample[2,ii]/sample[3,ii]
                FOR kk=3L, nfluxes-2 DO mags[kk,ii]= $
                  sample[kk+1,ii]/sample[3,ii]
            ENDFOR
        ENDELSE
        ;;Now plot the sampling
        ;;u vs g
        k_print, filename=basefilename+'g_u.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, mags[0,*], mags[1,*], $
              title=title, $
              xtitle=textoidl('f_u'),ytitle=textoidl('f_g'), $
              xrange=[-0.7,2], yrange=[-0.5,2], $
              xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, mags[0,ioutliers], $
              mags[1,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[0,*], $
              mags[1,*], $
              xtitle=textoidl('f_u'),ytitle=textoidl('f_g'), psym=3, $
              title=title, xrange=[-0.7,2], yrange=[-0.5,2], $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize ELSE $
              djs_plot, mags[0,*], mags[1,*], $
              xtitle='f_u',ytitle='f_g', psym=3, title=title, xrange=[-0.7,2], $
              yrange=[-0.5,2],charsize=charsize
        ENDELSE
        ;;Title
;        IF keyword_set(resampledata) THEN BEGIN
        IF keyword_set(qso) THEN BEGIN
            xyouts, 0., 2.5, 'extreme-deconvolution with', charsize=1.8
            xyouts, 1., 2.2, 'data errors', charsize=1.8
        ENDIF ELSE BEGIN
            xyouts, 0., 2.2, 'extreme-deconvolution', charsize=1.8
        ENDELSE
        IF ~keyword_set(nomaglabel) THEN BEGIN
            legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
              box= 0., /left, charsize=legendcharsize
            legend, [strtrim(string(ndata),2)+' objects'], $
              box= 0., /right, charsize=legendcharsize
        ENDIF
        k_end_print
        ;;r-i vs. g-r
        k_print, filename=basefilename+'r_g.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, mags[1,*], mags[2,*], $
              ytitle=textoidl('f_r'),xtitle=textoidl('f_g'), $
              yrange=[0.,1.5], xrange=[-0.5,2], $
              xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, mags[1,ioutliers], $
              mags[2,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[1,*], mags[2,*], $
              xtitle=textoidl('f_g'),ytitle=textoidl('f_r'), psym=3, xrange=[-0.5,2], yrange=[0.,1.5], $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize  ELSE $
              djs_plot, mags[1,*], mags[2,*], $
              xtitle='f_g',ytitle='f_r', psym=3, xrange=[-0.5,2], yrange=[0.,1.5],charsize=charsize
        ENDELSE
        k_end_print
        ;;i-z vs. r-i
        k_print, filename=basefilename+'z_r.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, mags[2,*], mags[3,*], $
              xtitle=textoidl('f_r'),ytitle=textoidl('f_z'), $
              xrange=[0.,1.5], yrange=[0.,3.], $
              xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, mags[2,ioutliers], $
              mags[3,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[2,*], $
              mags[3,*], ytitle=textoidl('f_z'),xtitle=textoidl('f_r'), psym=3, $
              xrange=[0.,1.5], yrange=[0,3.], $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize  ELSE $
              djs_plot, mags[2,*], mags[3,*], $
              ytitle='f_z',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,3.],charsize=charsize
        ENDELSE
        k_end_print
        IF keyword_set(galex) THEN BEGIN
            ;;First subsample ngalexdata points
            randindx= randomu(seed,ndata);;Clever way of getting random permutation
            randindx= (SORT(randindx))[0:min([ndata,ngalexdata])-1];;Hack, since we messed up ngalexdata in the .sav files
            IF ~keyword_set(qso) THEN mags[4:5,randindx]= (mags[4:5,randindx] > 0.)
            ;;nuv vs r
            k_print, filename=basefilename+'nuv_r.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              mags[2,randindx], mags[4,randindx], $
              ytitle=textoidl('f_{NUV}'),xtitle=textoidl('f_r'), $
              psym=3, xrange=[0.,1.5], yrange=[0,.01], $
              /outliers, outcolor=djs_icolor('black'),charsize=charsize ELSE $
              djs_plot, mags[2,randindx], mags[4,randindx], $
              ytitle='f_{NUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], $
              yrange=[0,.01],charsize=charsize
            legend, [strtrim(string(ngalexdata),2)+' objects'], $
              box= 0., /right, charsize=legendcharsize
            k_end_print
            ;;fuv vs r
            k_print, filename=basefilename+'fuv_r.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              mags[2,randindx], mags[5,randindx], $
              ytitle=textoidl('f_{FUV}'),xtitle=textoidl('f_r'), psym=3, $
              xrange=[0.,1.5], yrange=[0,0.005], $
              /outliers, outcolor=djs_icolor('black'),charsize=charsize ELSE $
              djs_plot, plotthis[2,randindx], plotthis[5,randindx], $
              ytitle='f_{FUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], $
              yrange=[0,.005],charsize=charsize
            legend, [strtrim(string(ngalexdata),2)+' objects'], $
              box= 0., /right, charsize=legendcharsize
            k_end_print
        ENDIF
    ;;plot redshifts if /fitz
    IF keyword_set(fitz) THEN BEGIN
        ;;u vs z
        k_print, filename=basefilename+'u_z.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
          mags[0,*], $
          xtitle='redshift',ytitle=textoidl('u flux / i flux'), psym=3, $
          yrange=[-0.3,1.3], xrange=[0.,5.5], /nogreyscale, $
          /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, zsample, mags[0,*], $
          xtitle='redshift',ytitle='u flux / i flux', psym=3, $
          xrange=[0.,5.5],yrange=[-0.3,1.3], charsize=charsize
        overplot_speclines, 'u'
        overplot_speclines, 'i'
        ;;Title
        IF keyword_set(resampledata) THEN BEGIN
            xyouts, 0., 1.4, 'extreme-deconvolution with', charsize=2.05
            xyouts, 1.65, 1.32, 'data errors', charsize=2.05
        ENDIF ELSE BEGIN
            xyouts, .85, 1.32, 'extreme-deconvolution', charsize=2.05
        ENDELSE
        IF ~keyword_set(nomaglabel) THEN BEGIN
            legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
              box= 0., /left, charsize=legendcharsize
            legend, [strtrim(string(ndata),2)+' objects'], $
              box= 0., /right, charsize=legendcharsize
        ENDIF
        k_end_print
        ;;g vs. z
        k_print, filename=basefilename+'g_z.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
          mags[1,*], $
          xtitle='redshift',ytitle=textoidl('g flux / i flux'), psym=3, $
          xrange=[0.,5.5],yrange=[-0.5,2], /nogreyscale, $
          /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, zsample, mags[1,*], $
          xtitle='redshift',ytitle='g flux / i flux', psym=3, $
          xrange=[0.,5.5],yrange=[-0.5,2], charsize=charsize
        overplot_speclines, 'g'
        overplot_speclines, 'i'
        k_end_print
        ;;r vs. z
        k_print, filename=basefilename+'r_z.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample,$
          mags[2,*], $
          xtitle='redshift', ytitle=textoidl('r flux / i flux'), psym=3, $
          xrange=[0.,5.5], yrange=[0.,1.5], /nogreyscale, $
          /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, zsample, mags[2,*], $
          xtitle='redshift', ytitle='r flux / i flux', psym=3, $
          xrange=[0.,5.5], yrange=[0.,1.5], charsize=charsize
        overplot_speclines, 'r'
        overplot_speclines, 'i'
        k_end_print
        ;;z vs. z
        k_print, filename=basefilename+'z_z.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
          mags[3,*], $
          xtitle='redshift', ytitle=textoidl('z flux / i flux'), psym=3, $
          xrange=[0.,5.5], yrange=[0,3.], /nogreyscale, $
          /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, zsample, mags[3,*], $
          xtitle='redshift', ytitle='z flux / i flux',psym=3, $
          xrange=[0.,5.5], yrange=[0,3.], charsize=charsize
        overplot_speclines, 'z'
        overplot_speclines, 'i'
        k_end_print
        IF keyword_set(galex) THEN BEGIN
            ;;First subsample ngalexdata points
            randindx= randomu(seed,ndata) ;;Clever way of getting random permutation
            randindx= (SORT(randindx))[0:min([ndata,ngalexdata])-1] ;;Hack, since we messed up ngalexdata in the .sav files
            IF ~keyword_set(qso) THEN mags[4:5,randindx]= (mags[4:5,randindx] > 0.)
            ;;nuv vs. z
            k_print, filename=basefilename+'nuv_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[4,randindx], $
              ytitle=textoidl('NUV flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[4,randindx], $
              ytitle='NUV flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.1,1.],charsize=charsize
            overplot_speclines, 'NUV', /lylim
            overplot_speclines, 'i'
            k_end_print
            k_print, filename=basefilename+'fuv_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[5,randindx], $
              ytitle=textoidl('FUV flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[5,randindx], $
              ytitle='FUV flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.1,1.],charsize=charsize
            overplot_speclines, 'FUV', /lylim
            overplot_speclines, 'i'
            ;;Title
            IF keyword_set(resampledata) THEN BEGIN
                xyouts, 0., 1.06875, 'extreme-deconvolution with', charsize=2.05
                xyouts, 1.65, 1.01375, 'data errors', charsize=2.05
            ENDIF ELSE BEGIN
                xyouts, 0., 2.2, 'extreme-deconvolution', charsize=1.8
            ENDELSE
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(ndata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
        ENDIF
        IF keyword_set(ukidss) THEN BEGIN
            ;;First subsample nukidssdata points
            randindx= randomu(seed,ndata) ;;Clever way of getting random permutation
            randindx= (SORT(randindx))[0:min([ndata,nukidssdata])-1] ;;Hack, since we messed up ngalexdata in the .sav files
            IF ~keyword_set(qso) THEN mags[4:7,randindx]= (mags[4:7,randindx] > 0.)
            ;;Y vs. z
            k_print, filename=basefilename+'Y_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[4,randindx], $
              ytitle=textoidl('Y flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.,2.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[4,randindx], $
              ytitle='Y flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.5,1.],charsize=charsize
            overplot_speclines, 'Y'
            overplot_speclines, 'i'
            ;;Title
            IF keyword_set(resampledata) THEN BEGIN
                xyouts, 0., 2.65625, 'extreme-deconvolution with', charsize=2.05
                xyouts, 1.65, 2.53125, 'data errors', charsize=2.05
            ENDIF ELSE BEGIN
                xyouts, 0., 2.2, 'extreme-deconvolution', charsize=2.15
            ENDELSE
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(nukidssdata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
            k_print, filename=basefilename+'J_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[5,randindx], $
              ytitle=textoidl('J flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.,2.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[5,randindx], $
              ytitle='J flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.5,1.],charsize=charsize
            overplot_speclines, 'J'
            overplot_speclines, 'i'
            k_end_print
            k_print, filename=basefilename+'H_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[6,randindx], $
              ytitle=textoidl('H flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.,3.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[6,randindx], $
              ytitle='H flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.5,1.],charsize=charsize
            overplot_speclines, 'H'
            overplot_speclines, 'i'
            k_end_print
            k_print, filename=basefilename+'K_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              zsample[randindx], mags[7,randindx], $
              ytitle=textoidl('K flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.,3.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, zsample[randindx], mags[7,randindx], $
              ytitle='K flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], $
              yrange=[-0.5,1.],charsize=charsize
            overplot_speclines, 'K'
            overplot_speclines, 'i'
            k_end_print
        ENDIF
    ENDIF
ENDIF ELSE BEGIN
        nfluxes= n_elements(sample[*,0])
        IF keyword_set(resampledata) THEN BEGIN
            IF keyword_set(qso) THEN title= 'extreme-deconvolution with data errors' ELSE $
              title= 'extreme-deconvolution with co-add errors'
            IF keyword_set(full) THEN title= 'extreme-deconvolution with data errors'
            ;;Load the coadded data
            IF keyword_set(qso) THEN BEGIN
                coadddatafilename= '$BOVYQSOEDDATA/qso_all_extreme_deconv.fits.gz'
            ENDIF ELSE IF keyword_set(full) THEN BEGIN
                x=strsplit(magbin,'_i_',/extract)
                ilow= double(x[0])
                ihigh= double(x[1])
                fullbin= floor((ilow-12.9)/0.1)
                coadddatafilename= get_choppedsweeps_name(fullbin,/path)
            ENDIF ELSE IF keyword_set(full) THEN BEGIN
                x=strsplit(magbin,'_i_',/extract)
                ilow= double(x[0])
                ihigh= double(x[1])
                fullbin= floor((ilow-12.9)/0.1)
                coadddatafilename= get_choppedsweeps_name(fullbin,/path)
            ENDIF ELSE BEGIN
                coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
            ENDELSE
            coadddata= mrdfits(coadddatafilename,1)
            IF keyword_set(magbin) THEN BEGIN
                x=strsplit(magbin,'_i_',/extract)
                ilow= double(x[0])-0.1 ;;Make sure you don't miss any
                ihigh= double(x[1])+0.1
                IF keyword_set(qso) THEN BEGIN
                    get_qso_fluxes, coadddata, coflux, coflux_ivar, weight, lowz=lowz, bossz=bossz, zfour=zfour, allz=allz
                    coextinction= dblarr(n_elements(coflux[*,0]),n_elements(coflux[0,*]))
                    IF keyword_set(ukidss) THEN BEGIN
                        nirdata= mrdfits(nirdatafilename,1)
                        get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, coadddata
                    ENDIF ELSE BEGIN
                        nirflux= 0.
                        nirflux_ivar= 0.
                        nirextinction= 0.
                    ENDELSE
                    IF keyword_set(galex) THEN BEGIN
                        uvdata= mrdfits(uvdatafilename,1)
                        old= keyword_set(qso)
                        get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, coadddata, old=old
                    ENDIF ELSE BEGIN
                        uvflux= 0.
                        uvflux_ivar= 0.
                        uvextinction= 0.
                    ENDELSE
                    combine_fluxes, coflux, coflux_ivar, coextinction, anirflux=nirflux, $
                      bnirflux_ivar=nirflux_ivar, $
                      cnirextinction= nirextinction, duvflux=uvflux, $
                      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
                      nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
                      extinctionout=outextinction
                    coflux= outflux
                    coflux_ivar= outflux_ivar
                    coextinction= outextinction
                ENDIF ELSE IF keyword_set(full) THEN BEGIN
                    ;;get random sample
                    x= lindgen(n_elements(coadddata.ra))
                    y= randomu(seed,n_elements(coadddata.ra))
                    z= x[sort(y)]
                    n= 50000
                    z= z[0:n-1]
                    coadddata= coadddata[z]
                    coflux= coadddata.psfflux
                    coflux_ivar= coadddata.psfflux_ivar
                    coextinction= coadddata.extinction
                ENDIF ELSE BEGIN
                    get_coadd_fluxes, coadddata, coflux, coflux_ivar, coextinction
                    prep_data, coflux, coflux_ivar, extinction=coextinction,$
                      mags=mags, var_mags=ycovar
                    thiscoadddata= where(mags[3,*] GE ilow AND mags[3,*] LT ihigh)
                    coadddata= coadddata[thiscoadddata]
                    get_coadd_fluxes, coadddata, coflux, coflux_ivar, coextinction
                    IF keyword_set(ukidss) THEN BEGIN
                        nirdata= mrdfits(nirdatafilename,1)
                        get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, coadddata
                    ENDIF ELSE BEGIN
                        nirflux= 0.
                        nirflux_ivar= 0.
                        nirextinction= 0.
                    ENDELSE
                    IF keyword_set(galex) THEN BEGIN
                        uvdata= mrdfits(uvdatafilename,1)
                        old= keyword_set(qso)
                        get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, coadddata, old=old
                    ENDIF ELSE BEGIN
                        uvflux= 0.
                        uvflux_ivar= 0.
                        uvextinction= 0.
                    ENDELSE
                    combine_fluxes, coflux, coflux_ivar, coextinction, anirflux=nirflux, $
                      bnirflux_ivar=nirflux_ivar, $
                      cnirextinction= nirextinction, duvflux=uvflux, $
                      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
                      nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
                      extinctionout=outextinction
                    coflux= outflux
                    coflux_ivar= outflux_ivar
                    coextinction= outextinction
                ENDELSE
                IF keyword_set(galex) THEN BEGIN
                    goodivar= where(coflux_ivar[5,*] NE 1./1D5 and coflux[6,*] NE 1./1D5)
                    coflux= coflux[*,goodivar]
                    coextinction= coextinction[*,goodivar]
                    coflux_ivar= coflux_ivar[*,goodivar]
                ENDIF
                ilow+= 0.1
                ihigh-= 0.1
                IF keyword_set(rescaled) THEN BEGIN
                    IF keyword_set(coextinction) THEN prep_data, coflux, coflux_ivar, extinction=coextinction,$
                      mags=mags, var_mags=ycovar, /relfluxes ELSE $
                      prep_data, coflux, coflux_ivar,$
                      mags=mags, var_mags=ycovar, /relfluxes
                    coflux= mags
                    coflux_var= ycovar
                ENDIF
            ENDIF
            ;;for each sample, find the data point in the co-added
            ;;catalog with the closest 5d-flux match
            nfluxes= n_elements(coflux[*,0])
            FOR jj=0L, ndata-1 DO BEGIN
                print, format = '("Working on ",i7," of ",i7,a1,$)', $
                  jj+1,ndata,string(13B)
                IF keyword_set(rescaled) THEN BEGIN
                    IF keyword_set(galex) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.,sub)
                    ENDIF ELSE BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.,sub)
                    ENDELSE
                    lower= coflux_var[*,*,sub]
                    LA_CHOLDC, lower
                    sample[*,jj]+= lower#RANDOMN(seed,nfluxes)
                ENDIF ELSE BEGIN
                    IF keyword_set(galex) THEN BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.+(coflux[5,*]-sample[5,jj])^2.+(coflux[6,*]-sample[6,jj])^2.,sub)
                    ENDIF ELSE BEGIN
                        thismin= MIN((coflux[0,*]-sample[0,jj])^2.+(coflux[1,*]-sample[1,jj])^2.+(coflux[2,*]-sample[2,jj])^2.+(coflux[3,*]-sample[3,jj])^2.+(coflux[4,*]-sample[4,jj])^2.,sub)
                    ENDELSE
                    FOR kk=0L, nfluxes-1 DO sample[kk,jj]+= RANDOMN(seed)*coflux_ivar[kk,sub]^(-0.5)
                ENDELSE
            ENDFOR
        ENDIF
        fake_ivar= dblarr(nfluxes+1,nsamples)+1.
        IF keyword_set(rescaled) THEN BEGIN
            mi= (ihigh+ilow)/2.
            b_i = 1.8
            fi= sdss_mags2flux(mi,b_i)
            new_sample= dblarr(nfluxes+1,n_elements(sample)/nfluxes)
            new_sample[0,*]= sample[0,*]*fi
            new_sample[1,*]= sample[1,*]*fi
            new_sample[2,*]= sample[2,*]*fi
            new_sample[3,*]= fi
            FOR kk=3L, nfluxes-1 DO new_sample[kk+1,*]= sample[kk,*]*fi
            IF keyword_set(galex) THEN BEGIN
                new_sample[5,*]*= 1D-9
                new_sample[6,*]*= 1D-9
            ENDIF
            prep_data, new_sample, fake_ivar, mags=mags, var_mags=var_mags, /colors
        ENDIF ELSE BEGIN
            IF keyword_set(galex) THEN BEGIN
                sample[5,*]*= 1D-9
                sample[6,*]*= 1D-9
            ENDIF
            prep_data, sample, fake_ivar, mags=mags, var_mags=var_mags, /colors
        ENDELSE
        sample= mags
        ;;Now plot the sampling
        ;;g-r vs. u-g
        k_print, filename=basefilename+'gr_ug.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, sample[0,*], $
              sample[1,*], title=title, $
              ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), $
              xrange=[-1,5],$
              yrange=[-.6,4], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, sample[0,ioutliers], $
              sample[1,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, sample[0,*], sample[1,*], $
              ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), psym=3, xrange=[-1,5],yrange=[-.6,4], title=title, $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize  ELSE $
              djs_plot, sample[0,*], sample[1,*], $
              xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], title=title,charsize=charsize
        ENDELSE
        legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
          box= 0., /left, charsize=legendcharsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize=legendcharsize
        k_end_print
        ;;r-i vs. g-r
        k_print, filename=basefilename+'ri_gr.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, sample[1,*], $
              sample[2,*], $
              xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), $
              yrange=[-.6,2.6],$
              xrange=[-.6,4], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, sample[1,ioutliers], $
              sample[2,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, sample[1,*], sample[2,*], $
              xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), psym=3, xrange=[-.6,4],yrange=[-.6,2.6], $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize  ELSE $
              djs_plot, sample[1,*], sample[2,*], $
              xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6],charsize=charsize
        ENDELSE
        k_end_print
        ;;i-z vs. r-i
        k_print, filename=basefilename+'iz_ri.ps'
        IF keyword_set(full) THEN BEGIN
            hogg_scatterplot, sample[2,*], $
              sample[3,*], $
              ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), $
              xrange=[-.6,2.6],$
              yrange=[-.5,1.5], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
              /internal_weight, charsize=charsize
            sample_outliers, ioutliers, noutliers
            djs_oplot, sample[2,ioutliers], $
              sample[3,ioutliers], psym=3
        ENDIF ELSE BEGIN
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, sample[2,*], sample[3,*], $
              ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5], $
              /outliers, outcolor=djs_icolor('black'), levels=levels,charsize=charsize  ELSE $
              djs_plot, sample[2,*], sample[3,*], $
              ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5],charsize=charsize
        ENDELSE
        k_end_print
        IF keyword_set(galex) THEN BEGIN
            plotthis= where(finite(sample[4,*]))
            ngalexdata= n_elements(plotthis)
            k_print, filename=basefilename+'nu_fn.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              -sample[5,plotthis], $
              -(sample[0,plotthis]+sample[1,plotthis]+sample[2,plotthis]+$
                sample[3,plotthis]+sample[4,plotthis]), $
              /outliers, outcolor=djs_icolor('black'),$
              ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10],charsize=charsize ELSE $
              djs_plot, -sample[5,plotthis], $
              -(sample[0,plotthis]+sample[1,plotthis]+sample[2,plotthis]+$
                sample[3,plotthis]+sample[4,plotthis]), $
              ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10],charsize=charsize
            legend, [strtrim(string(ngalexdata),2)+' objects'], $
              box= 0., /right, charsize=legendcharsize
            k_end_print       
            k_print, filename=basefilename+'ug_nu.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, $
              -(sample[0,plotthis]+sample[1,plotthis]+sample[2,plotthis]+$
                sample[3,plotthis]+sample[4,plotthis]), sample[0,plotthis], $
              /outliers, outcolor=djs_icolor('black'),$
              xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7],charsize=charsize ELSE $
              djs_plot, $
              -(sample[0,plotthis]+sample[1,plotthis]+sample[2,plotthis]+$
                sample[3,plotthis]+sample[4,plotthis]), sample[0,plotthis], $
              xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7],charsize=charsize
            k_end_print       
        ENDIF
        IF keyword_set(fitz) THEN BEGIN
            ;;u-g vs. z
            k_print, filename=basefilename+'ug_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
              sample[0,*], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'),$
              xtitle='redshift', ytitle='u-g', psym=3, xrange=[0.,5.5], $
              yrange=[-1,5], charsize=charsize ELSE $
              djs_plot, zsample, sample[0,*], $
              xtitle='redshift', ytitle='u-g',psym=3, xrange=[0.,5.5],$
              yrange=[-1,5], charsize=charsize
            ;;Title
            IF keyword_set(resampledata) THEN BEGIN
                xyouts, 0., 5.375, 'extreme-deconvolution with', charsize=2.05
                xyouts, 1.65, 5.075, 'data errors', charsize=2.05
            ENDIF ELSE BEGIN
                xyouts, .85, 1.32, 'extreme-deconvolution', charsize=1.8
            ENDELSE
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(ndata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            overplot_speclines, 'u'
            overplot_speclines, 'g'
            k_end_print
            ;;g-r vs. z
            k_print, filename=basefilename+'gr_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
              sample[1,*], /nogreyscale, $
              /conditional, $
              xtitle='redshift', ytitle='g-r',psym=3, $
              xrange=[0.,5.5], yrange=[-.6,4], charsize=charsize ELSE $
              djs_plot, zsample, sample[1,*], $
              xtitle='redshift', ytitle='g-r',psym=3, $
              xrange=[0.,5.5],yrange=[-.6,4], charsize=charsize
            overplot_speclines, 'r'
            overplot_speclines, 'g'
            k_end_print
            ;;r-i vs. z
            k_print, filename=basefilename+'ri_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
              sample[2,*], /nogreyscale, $
              /conditional,$
              xtitle='redshift',ytitle='r-i', psym=3, $
              xrange=[0.,5.5], yrange=[-.5,2.5], charsize=charsize ELSE $
              djs_plot, zsample, sample[2,*], $
              xtitle='redshift', ytitle='r-i', psym=3, $
              xrange=[0.,5.5], yrange=[-.5,2.5], charsize=charsize
            overplot_speclines, 'r'
            overplot_speclines, 'i'
            k_end_print
            ;;i-z vs. z
            k_print, filename=basefilename+'iz_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, zsample, $
              sample[3,*], /nogreyscale, $
              /conditional,xtitle='redshift', ytitle='i-z',psym=3, $
              xrange=[0.,5.5], yrange=[-.5,1.5], charsize=charsize ELSE $
              djs_plot, zsample, sample[3,*], $
              xtitle='redshift', ytitle='i-z', psym=3, $
              xrange=[0.,5.5],yrange=[-.5,1.5], charsize=charsize
            overplot_speclines, 'z'
            overplot_speclines, 'i'
            k_end_print
        ENDIF
    ENDELSE
    RETURN
ENDIF ELSE IF keyword_set(sampling) THEN BEGIN
    ;;Sample nsamples from the deconvolved color distribution
    IF keyword_set(resampledata) THEN BEGIN
        IF ~keyword_set(datafilename) THEN datafilename='$BOVYQSOEDDATA/sdss_qsos.fits'
        qsodata= mrdfits(datafilename,1)
        ndata= n_elements(qsodata.z)
        sample= dblarr(4,ndata)
        FOR ii=0L, ndata-1 DO BEGIN
            thiscovar= xcovar
            FOR jj=0L, 3 DO BEGIN
                thiscovar[jj,jj]+= qsodata[ii].magerr[jj]^2.+qsodata[ii].magerr[jj+1]^2.
            ENDFOR
            sample_gaussians, nsamples=1, mean=xmean, covar=thiscovar, $
              amp=amp, sample=thissample, seed=seed
            sample[*,ii]= REFORM(thissample,4)
        ENDFOR
    ENDIF ELSE BEGIN
        sample_gaussians, nsamples=nsamples, mean=xmean, covar=xcovar, $
          amp=amp, sample=sample, seed=seed
    ENDELSE
    ;;Now plot the sampling
    ;;g-r vs. u-g
    k_print, filename=basefilename+'gr_ug.ps'
    djs_plot, sample[0,*], sample[1,*], $
      xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], title=title,charsize=charsize
    k_end_print
    ;;r-i vs. g-r
    k_print, filename=basefilename+'ri_gr.ps'
    djs_plot, sample[1,*], sample[2,*], $
      xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6],charsize=charsize
    k_end_print
    ;;i-z vs. r-i
    k_print, filename=basefilename+'iz_ri.ps'
    djs_plot, sample[2,*], sample[3,*], $
      ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5],charsize=charsize
    k_end_print
ENDIF ELSE BEGIN
    cntrlevels=[.02D,.06D,.12D,.21D,.33D,.5D,.68D,.8D,.9D,.95D,.99D,.999D]
    ;;g-r vs. u-g
    projection= dblarr(4,4)
    projection[0,0]= 2.
    projection[1,1]= 1.
    k_print, filename=basefilename+'gr_ug.ps'
    plot_projected_gaussians, xmean, xcovar, projection, amp=amp, $
      xrange=[-1,5],yrange=[-.6,4], cntrlevels=cntrlevels, $
      grid=100, xlabel='u-g',ylabel='g-r', title=title,charsize=charsize
    k_end_print
    ;;r-i vs. g-r
    projection= dblarr(4,4)
    projection[1,1]= 2.
    projection[2,2]= 1.
    k_print, filename=basefilename+'ri_gr.ps'
    plot_projected_gaussians, xmean, xcovar, projection, amp=amp, $
      xrange=[-.6,4],yrange=[-.6,2.6], cntrlevels=cntrlevels, $
      grid=100, ylabel='r-i',xlabel='g-r',charsize=charsize
    k_end_print
    ;;i-z vs. r-i
    projection= dblarr(4,4)
    projection[2,2]= 2.
    projection[3,3]= 1.
    k_print, filename=basefilename+'iz_ri.ps'
    plot_projected_gaussians, xmean, xcovar, projection, amp=amp, $
      xrange=[-.5,2.5],yrange=[-.5,1.5], cntrlevels=cntrlevels, $
      grid=100, xlabel='r-i',ylabel='i-z',charsize=charsize
    k_end_print
ENDELSE
END
