;+
;   NAME:
;      plot_qso_data_magbin
;   PURPOSE:
;      plot the qso data as a set of color-color plots in an i-band
;      magnitude bin
;   INPUT:
;      lowhigh - lower and upper limit for the mag bin-string (*not*
;                    according to astronomers)
;      datafilename - filename that holds the data
;      basefilename - base filename for the color-color plots
;      uvdatafilename - name of the file that holds the uv data
;      nirdatafilename - name of the file that holds the nir data
;      charsize - charsize for plots
;      legendcharsize - charsize for legends
;   KEYWORDS:
;      lowz - plot the low-redshift data
;      bossz - plot the BOSS-redshift range data
;      allz - plot all the QSOs
;      hoggscatter - hogg_scatterplot instead of straight scatter plot
;      plotfluxes - plot fluxes, not colors
;      galex - also plot galex data
;      ukidss - also plot ukidss data
;      zfour - use z=4 as the boundary between bossz and hiz
;      fitz - we are fitting redshift as well, so plot it
;      nomaglabel - don't put the magnitude label and number of
;                   objects in the figure
;   OUTPUT:
;      .ps plots
;   REVISION HISTORY:
;      2010-04-19 - Written - Bovy (NYU)
;      2010-05-25 - Added galex - Bovy
;-
PRO PLOT_QSO_DATA_MAGBIN, lowhigh, hoggscatter=hoggscatter,$
                          datafilename=datafilename, basefilename=basefilename, $
                          plotfluxes=plotfluxes, lowz=lowz, bossz=bossz, $
                          galex=galex, uvdatafilename=uvdatafilename, $
                          ukidss=ukidss, nirdatafilename=nirdatafilename, $
                          charsize=charsize, legendcharsize=legendcharsize, $
                          zfour=zfour, allz=allz, fitz=fitz, $
                          nomaglabel=nomaglabel
IF ~keyword_set(charsize) THEN charsize= 1.3
IF ~keyword_set(legendcharsize) THEN legendcharsize= 1.6
IF ~keyword_set(lowz) THEN levels= errorf(0.5*(dindgen(2)+1))

x=strsplit(lowhigh,'_i_',/extract)
ilow= double(x[0])
ihigh= double(x[1])

IF ~keyword_set(datafilename) THEN BEGIN
      datafilename= '$BOVYQSOEDDATA/qso_all_extreme_deconv.fits.gz'
ENDIF
IF ~keyword_set(uvdatafilename) THEN uvdatafilename= '$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits'
IF ~keyword_set(nirdatafilename) THEN nirdatafilename= '$BOVYQSOEDDATA/dr7qso_join_ukidss_dr8_20101027a.fits'
;;Open file
qsodata= mrdfits(datafilename,1)
get_qso_fluxes, qsodata, flux, flux_ivar, weight,lowz=lowz, bossz=bossz, $
  zfour=zfour, allz=allz
IF keyword_set(ukidss) THEN BEGIN
    nirdata= mrdfits(nirdatafilename,1)
    get_nir_fluxes, nirdata, nirflux, nirflux_ivar, nirextinction, qsodata
ENDIF ELSE BEGIN
    nirflux= 0.
    nirflux_ivar= 0.
    nirextinction= 0.
ENDELSE
IF keyword_set(galex) THEN BEGIN
    uvdata= mrdfits(uvdatafilename,1)
    get_uv_fluxes, uvdata, uvflux, uvflux_ivar, uvextinction, qsodata, /old
ENDIF ELSE BEGIN
    uvflux= 0.
    uvflux_ivar= 0.
    uvextinction= 0.
ENDELSE
combine_fluxes, flux, flux_ivar, 0., anirflux=nirflux, $
  bnirflux_ivar=nirflux_ivar, $
  cnirextinction= nirextinction, duvflux=uvflux, $
  euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
  nir=ukidss,uv=galex, fluxout=outflux, ivarfluxout=outflux_ivar, $
  extinctionout=outextinction
flux= outflux
flux_ivar= outflux_ivar
extinction= outextinction
IF keyword_set(galex) THEN BEGIN
    indx= where(flux_ivar[5,*] NE 1./1D5 AND flux_ivar[6,*] NE 1./1D5)
    flux= flux[*,indx]
    flux_ivar= flux_ivar[*,indx]
    extinction= extinction[*,indx]
    weight= weight[*,indx]
    qsodata= qsodata[indx]
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    indx= where(flux_ivar[5,*] NE 1./1D5 AND flux_ivar[6,*] NE 1./1D5 AND $
                flux_ivar[7,*] NE 1./1D5 AND flux_ivar[8,*] NE 1./1D5)
    flux= flux[*,indx]
    flux_ivar= flux_ivar[*,indx]
    extinction= extinction[*,indx]
    weight= weight[*,indx]
    qsodata= qsodata[indx]
ENDIF

title= 'resampled quasar data'

;;Resample and down-sample
windx= long((ilow-17.7)/0.1)
resample_qso, flux, flux_ivar, weight[windx,*], newflux, indxarray=indxarray
qsodata= qsodata[indxarray]

IF keyword_set(plotfluxes) THEN BEGIN
    mags= newflux
    ndata= n_elements(mags[0,*])
    nfluxes= n_elements(mags[*,0])
    plotthis= dblarr(nfluxes-1,ndata)
    ;;divide by i-band
    FOR ii=0L, ndata-1 DO BEGIN
        plotthis[0,ii]= mags[0,ii]/mags[3,ii]
        plotthis[1,ii]= mags[1,ii]/mags[3,ii]
        plotthis[2,ii]= mags[2,ii]/mags[3,ii]
        plotthis[3,ii]= mags[4,ii]/mags[3,ii]
        IF keyword_set(galex) THEN BEGIN
            plotthis[4,ii]= mags[5,ii]/mags[3,ii]
            plotthis[5,ii]= mags[6,ii]/mags[3,ii]
        ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
            plotthis[4,ii]= mags[5,ii]/mags[3,ii]
            plotthis[5,ii]= mags[6,ii]/mags[3,ii]
            plotthis[6,ii]= mags[7,ii]/mags[3,ii]
            plotthis[7,ii]= mags[8,ii]/mags[3,ii]
        ENDIF
    ENDFOR
    if ~keyword_set(galex) and ~keyword_set(ukidss) then begin
        ;;u vs g
        k_print, filename=basefilename+lowhigh+'_g_u.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[0,*], plotthis[1,*], $
          xtitle=textoidl('f_u'),ytitle=textoidl('f_g'), psym=3, title=title, xrange=[-0.7,2], yrange=[-0.5,2], $
          /outliers, outcolor=djs_icolor('black'), levels=levels, charsize=charsize ELSE $
          djs_plot, plotthis[0,*], plotthis[1,*], $
          xtitle='f_u',ytitle='f_g', psym=3, title=title, xrange=[-0.7,2], yrange=[-0.5,2], charsize=charsize
        IF ~keyword_set(nomaglabel) THEN BEGIN
            legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
              box= 0., /left, charsize= legendcharsize
            legend, [strtrim(string(ndata),2)+' objects'], $
              box= 0., /right, charsize= legendcharsize
        ENDIF
        k_end_print
        ;;r-i vs. g-r
        k_print, filename=basefilename+lowhigh+'_r_g.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[1,*], plotthis[2,*], $
          xtitle=textoidl('f_g'),ytitle=textoidl('f_r'), psym=3, xrange=[-0.5,2], yrange=[0.,1.5], $
          /outliers, outcolor=djs_icolor('black'), levels=levels, charsize=charsize ELSE $
          djs_plot, plotthis[1,*], plotthis[2,*], $
          xtitle='f_g',ytitle='f_r', psym=3, xrange=[-0.5,2], yrange=[0.,1.5], charsize=charsize
        k_end_print
        ;;i-z vs. r-i
        k_print, filename=basefilename+lowhigh+'_z_r.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,*], plotthis[3,*], $
          ytitle=textoidl('f_z'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,3.], $
          /outliers, outcolor=djs_icolor('black'), levels=levels, charsize=charsize ELSE $
          djs_plot, plotthis[2,*], plotthis[3,*], $
          ytitle='f_z',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,3.], charsize=charsize
        k_end_print
    endif
    IF keyword_set(galex) THEN BEGIN
        ;;nuv vs r
        k_print, filename=basefilename+lowhigh+'_nuv_r.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,*], plotthis[4,*], $
          ytitle=textoidl('f_{NUV}'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,.01], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[2,*], plotthis[4,*], $
          ytitle='f_{NUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,.01], charsize=charsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize= legendcharsize
        k_end_print
        ;;fuv vs r
        k_print, filename=basefilename+lowhigh+'_fuv_r.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, plotthis[2,*], plotthis[5,*], $
          ytitle=textoidl('f_{FUV}'),xtitle=textoidl('f_r'), psym=3, xrange=[0.,1.5], yrange=[0,0.005], $
          /outliers, outcolor=djs_icolor('black'), charsize=charsize ELSE $
          djs_plot, plotthis[2,*], plotthis[5,*], $
          ytitle='f_{FUV}',xtitle='f_r', psym=3, xrange=[0.,1.5], yrange=[0,.005], charsize=charsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize= legendcharsize
        k_end_print
    ENDIF
    ;;plot redshifts if /fitz
    IF keyword_set(fitz) THEN BEGIN
        if ~keyword_set(galex) and ~keyword_set(ukidss) then begin
            ;;u vs z
            k_print, filename=basefilename+lowhigh+'_u_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              plotthis[0,*], $
              xtitle='redshift',ytitle=textoidl('u flux / i flux'), psym=3, $
              yrange=[-0.3,1.3], xrange=[0.,5.5], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[0,*], $
              xtitle='redshift',ytitle='u flux / i flux', $
              psym=3, $
              xrange=[0.,5.5],yrange=[-0.3,1.3], charsize=charsize
            ;;Title
            xyouts, 0.65, 1.32, title, charsize=2.05
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(ndata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
            ;;g vs. z
            k_print, filename=basefilename+lowhigh+'_g_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              plotthis[1,*], $
              xtitle='redshift',ytitle=textoidl('g flux / i flux'), psym=3, $
              xrange=[0.,5.5],yrange=[-0.5,2], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[1,*], $
              xtitle='redshift',ytitle='g flux / i flux', psym=3, $
              xrange=[0.,5.5],yrange=[-0.5,2], charsize=charsize
            k_end_print
            ;;r vs. z
            k_print, filename=basefilename+lowhigh+'_r_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z,$
              plotthis[2,*], $
              xtitle='redshift', ytitle=textoidl('r flux / i flux'), psym=3, $
              xrange=[0.,5.5], yrange=[0.,1.5], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[2,*], $
              xtitle='redshift', ytitle='r flux / i flux', psym=3, $
              xrange=[0.,5.5], yrange=[0.,1.5], charsize=charsize
            k_end_print
            ;;z vs. z
            k_print, filename=basefilename+lowhigh+'_z_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              plotthis[3,*], $
              xtitle='redshift', ytitle=textoidl('z flux / i flux'), psym=3, $
              xrange=[0.,5.5], yrange=[0,3.], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'), charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[3,*], $
              xtitle='redshift', ytitle='z flux / i flux',psym=3, $
              xrange=[0.,5.5], yrange=[0,3.], charsize=charsize
            k_end_print
        endif ELSE IF keyword_set(galex) THEN BEGIN
            ;;nuv vs r
            k_print, filename=basefilename+lowhigh+'_nuv_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[4,*], $
              ytitle=textoidl('NUV flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[4,*], $
              ytitle='NUV flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], charsize=charsize
            k_end_print
            ;;fuv vs z
            k_print, filename=basefilename+lowhigh+'_fuv_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[5,*], $
              ytitle=textoidl('FUV flux / i flux'),xtitle=textoidl('redshift'),$
              psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[5,*], title=title, $
              ytitle='FUV flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0.1,1.], charsize=charsize
            ;;Title
            xyouts, 0.65, 1.01375, title, charsize=2.05
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(ndata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
        endif ELSE IF keyword_set(ukidss) THEN BEGIN
            ;;Y vs z
            k_print, filename=basefilename+lowhigh+'_Y_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[4,*], $
              ytitle=textoidl('Y flux / i flux'),xtitle=textoidl('redshift'), $
              psym=3, xrange=[0.,5.5], yrange=[0.,2.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[4,*], $
              ytitle='Y flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0,1.], charsize=charsize
            ;;Title
            xyouts, 0.65, 2.53125, title, charsize=2.05
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(nukidssdata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
            ;;J vs z
            k_print, filename=basefilename+lowhigh+'_J_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[5,*], $
              ytitle=textoidl('J flux / i flux'),xtitle=textoidl('redshift'),$
              psym=3, xrange=[0.,5.5], yrange=[-0.,2.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[5,*], title=title, $
              ytitle='J flux / i flux}',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0,1.], charsize=charsize
            k_end_print
            ;;H vs z
            k_print, filename=basefilename+lowhigh+'_H_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[6,*], $
              ytitle=textoidl('H flux / i flux'),xtitle=textoidl('redshift'),$
              psym=3, xrange=[0.,5.5], yrange=[-0.,3.], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[6,*], title=title, $
              ytitle='H flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0,1.], charsize=charsize
            k_end_print
            ;;K vs z
            k_print, filename=basefilename+lowhigh+'_K_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, plotthis[7,*], $
              ytitle=textoidl('K flux / i flux'),xtitle=textoidl('redshift'),$
              psym=3, xrange=[0.,5.5], yrange=[-0.,3.5], /nogreyscale, $
              /conditional, charsize=charsize ELSE $
              djs_plot, qsodata.z, plotthis[7,*], title=title, $
              ytitle='K flux / i flux',xtitle='redshift', psym=3, xrange=[0.,5.5], yrange=[-0,1.], charsize=charsize
            k_end_print
        ENDIF
    ENDIF
ENDIF ELSE BEGIN
    ndata= n_elements(newflux[0,*])
    nfluxes= n_elements(newflux[*,0])
    b_i = 1.8
    fi= sdss_mags2flux(qsodata[0].ivec[windx],b_i)
    FOR ii=0L, ndata-1 DO BEGIN
        factor= fi/newflux[3,ii]
        newflux[0,ii]= newflux[0,ii]*factor
        newflux[1,ii]= newflux[1,ii]*factor
        newflux[2,ii]= newflux[2,ii]*factor
        newflux[3,ii]= fi
        newflux[4,ii]= newflux[4,ii]*factor
        IF keyword_set(galex) THEN BEGIN
            newflux[5,ii]= newflux[5,ii]*factor
            newflux[6,ii]= newflux[6,ii]*factor
        ENDIF
    ENDFOR
    fake_ivar= dblarr(nfluxes,ndata)+1.
    IF keyword_set(galex) THEN BEGIN
        newflux[5,*]*= 1D-9
        newflux[6,*]*= 1D-9
    ENDIF
    prep_data, newflux, fake_ivar,mags=mags,var_mags=var_mags
    if ~keyword_set(galex) then begin
        ;;g-r vs. u-g
        k_print, filename=basefilename+lowhigh+'_gr_ug.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[0,*]-mags[1,*], $
          mags[1,*]-mags[2,*], title=title, /outliers,outcolor=djs_icolor('black'),$
          xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], levels=levels, charsize=charsize ELSE $
          djs_plot, mags[0,*]-mags[1,*], mags[1,*]-mags[2,*], title=title,$
          xtitle='u-g',ytitle='g-r', psym=3, xrange=[-1,5],yrange=[-.6,4], charsize=charsize
        legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
          box= 0., /left, charsize= legendcharsize
        legend, [strtrim(string(ndata),2)+' objects'], $
          box= 0., /right, charsize= legendcharsize
        k_end_print
        ;;r-i vs. g-r
        k_print, filename=basefilename+lowhigh+'_ri_gr.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[1,*]-mags[2,*], $
          mags[2,*]-mags[3,*], /outliers, outcolor=djs_icolor('black'), $
          xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6], levels=levels, charsize=charsize ELSE $
          djs_plot, mags[1,*]-mags[2,*], mags[2,*]-mags[3,*], $
          xtitle='g-r',ytitle='r-i', psym=3, xrange=[-.6,4],yrange=[-.6,2.6], charsize=charsize
        k_end_print
        ;;i-z vs. r-i
        k_print, filename=basefilename+lowhigh+'_iz_ri.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[2,*]-mags[3,*], $
          mags[3,*]-mags[4,*], /outliers, outcolor=djs_icolor('black'),$
          ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5], levels=levels, charsize=charsize ELSE $
          djs_plot, mags[2,*]-mags[3,*], mags[3,*]-mags[4,*], $
          ytitle='i-z',xtitle='r-i', psym=3, xrange=[-.5,2.5],yrange=[-.5,1.5], charsize=charsize
        k_end_print
    endif
    IF keyword_set(galex) THEN BEGIN
        k_print, filename=basefilename+lowhigh+'_nu_fn.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[6,*]-mags[5,*], $
          mags[5,*]-mags[0,*], /outliers, outcolor=djs_icolor('black'),$
          ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10], charsize=charsize ELSE $
          djs_plot, mags[6,*]-mags[5,*], mags[5,*]-mags[0,*], $
          ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10], charsize=charsize
        legend, [strtrim(string(n_elements(mags[6,*])),2)+' objects'], $
          box= 0., /right, charsize= legendcharsize
        k_end_print       
        k_print, filename=basefilename+lowhigh+'_ug_nu.ps'
        IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[5,*]-mags[0,*], $
          mags[0,*]-mags[1,*], /outliers, outcolor=djs_icolor('black'),$
          xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7], charsize=charsize ELSE $
          djs_plot, mags[5,*]-mags[0,*], mags[0,*]-mags[1,*], $
          xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7], charsize=charsize
        k_end_print       
    ENDIF
    IF keyword_set(fitz) THEN BEGIN
        if ~keyword_set(galex) then begin
            ;;g-r vs. u-g
            k_print, filename=basefilename+lowhigh+'_ug_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              mags[0,*]-mags[1,*], /nogreyscale, $
              /conditional, outcolor=djs_icolor('black'),$
              xtitle='redshift', ytitle='u-g', psym=3, xrange=[0.,5.5], $
              yrange=[-1,5], charsize=charsize ELSE $
              djs_plot, qsodata.z, mags[0,*]-mags[1,*], $
              xtitle='redshift', ytitle='u-g',psym=3, xrange=[0.,5.5],$
              yrange=[-1,5], charsize=charsize
            ;;Title
            xyouts, 0.65, 5.075, title, charsize=2.05
            IF ~keyword_set(nomaglabel) THEN BEGIN
                legend, [strtrim(string(ilow,format='(F4.1)'),2)+' !9l!x i < '+strtrim(string(ihigh,format='(F4.1)'),2)], $
                  box= 0., /left, charsize=legendcharsize
                legend, [strtrim(string(ndata),2)+' objects'], $
                  box= 0., /right, charsize=legendcharsize
            ENDIF
            k_end_print
            ;;r-i vs. g-r
            k_print, filename=basefilename+lowhigh+'_gr_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              mags[1,*]-mags[2,*], /nogreyscale, $
              /conditional, $
              xtitle='redshift', ytitle='g-r',psym=3, $
              xrange=[0.,5.5], yrange=[-.6,4], charsize=charsize ELSE $
              djs_plot, qsodata.z, mags[1,*]-mags[2,*], $
              xtitle='redshift', ytitle='g-r',psym=3, $
              xrange=[0.,5.5],yrange=[-.6,4], charsize=charsize
            k_end_print
            ;;i-z vs. r-i
            k_print, filename=basefilename+lowhigh+'_ri_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              mags[2,*]-mags[3,*], /nogreyscale, $
              /conditional,$
              xtitle='redshift',ytitle='r-i', psym=3, $
              xrange=[0.,5.5], yrange=[-.5,2.5], charsize=charsize ELSE $
              djs_plot, qsodata.z, mags[2,*]-mags[3,*], $
              xtitle='redshift', ytitle='r-i', psym=3, $
              xrange=[0.,5.5], yrange=[-.5,2.5], charsize=charsize
            k_end_print
            ;;i-z vs. r-i
            k_print, filename=basefilename+lowhigh+'_iz_z.ps'
            IF keyword_set(hoggscatter) THEN hogg_scatterplot, qsodata.z, $
              mags[3,*]-mags[4,*], /nogreyscale, $
              /conditional,xtitle='redshift', ytitle='i-z',psym=3, $
              xrange=[0.,5.5], yrange=[-.5,1.5], charsize=charsize ELSE $
              djs_plot, qsodata.z, mags[3,*]-mags[4,*], $
              xtitle='redshift', ytitle='i-z', psym=3, $
              xrange=[0.,5.5],yrange=[-.5,1.5], charsize=charsize
            k_end_print
        endif
    ENDIF
ENDELSE
END
