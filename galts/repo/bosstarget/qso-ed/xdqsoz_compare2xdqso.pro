PRO XDQSOZ_COMPARE2XDQSO, plotfile, efficiency=efficiency

IF keyword_set(efficiency) THEN BEGIN
    effthick= 3.
    legendcharsize=1.4
    charsize=1.2
    xrange=[0.,60.]
    yrange=[0.,29.9999]
    ywidth=0.2
    xwidth=(xrange[1]-xrange[0])/(yrange[1]-yrange[0])*ywidth
    xs= dindgen(1001)/1000*(xrange[1]-xrange[0])+xrange[0]
    nxs= n_elements(xs)
    specarea= 205.12825
    area= specarea
    data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
    ;;GALEX+UKIDSS
    ;;restore probabilities
    xdqso= mrdfits('chunk11_extreme_deconv_galex_ukidss_ugriz.fits',1)
    xdqsoz= mrdfits('chunk11_xdqsoz_galex_ukidss.fits',1)
    xdqsoz_sdss= mrdfits('chunk11_xdqsoz_z4.fits',1)
    ;;calculate efficiency
    sortxdqso= reverse(sort(xdqso.pqso))
    sortxdqsoz= reverse(sort(xdqsoz.pqso))
    sortxdqsoz_sdss= reverse(sort(xdqsoz_sdss.pqso))
    ysone= dblarr(nxs)
    ystwo= dblarr(nxs)
    ysthree= dblarr(nxs)
    FOR ii=0L, nxs-1 DO BEGIN
        targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
        ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
        targetindx= sortxdqso[0:floor(xs[ii]*area)]
        ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
        targetindx= sortxdqsoz_sdss[0:floor(xs[ii]*area)]
        ysthree[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    ENDFOR
    k_print, filename=plotfile, xsize=15,ysize=15
    djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', linestyle=0, $
      position=[0.1,0.1,0.1+xwidth,0.1+ywidth], charsize=charsize, $
      xrange=xrange, yrange=yrange
    djs_oplot, xs, ystwo, linestyle=1
    djs_oplot, xs, ysthree, linestyle=0, color=djs_icolor('gray')
    djs_oplot, xrange, 0.5*xrange, color='gray',thick=effthick
    legend, ['+ GALEX UV + UKIDSS NIR'], box=0., charsize=legendcharsize, $
      /top, /left
    ;;UKIDSS
    ;;restore probabilities
    xdqso= mrdfits('chunk11_extreme_deconv_ukidss_ugriz.fits',1)
    xdqsoz= mrdfits('chunk11_xdqsoz_ukidss.fits',1)
    ;;calculate efficiency
    sortxdqso= reverse(sort(xdqso.pqso))
    sortxdqsoz= reverse(sort(xdqsoz.pqso))
    ysone= dblarr(nxs)
    ystwo= dblarr(nxs)
    FOR ii=0L, nxs-1 DO BEGIN
        targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
        ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
        targetindx= sortxdqso[0:floor(xs[ii]*area)]
        ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    ENDFOR
    djs_plot, xs, ysone, linestyle=0, $
      position=[0.1,0.1+ywidth,0.1+xwidth,0.1+2.*ywidth], charsize=charsize, xtickformat='(A1)', /noerase, $
      xrange=xrange, yrange=yrange
    djs_oplot, xs, ystwo, linestyle=1
    djs_oplot, xrange, 0.5*xrange, color='gray',thick=effthick
    djs_oplot, xs, ysthree, linestyle=0, color=djs_icolor('gray')
    legend, ['+ UKIDSS NIR'], box=0., charsize=legendcharsize, $
      /top, /left
    xyouts, -7., 6., textoidl('# 2.2 !9l!x z !9l!x 4.0 quasar [deg^{-2}]'), charsize=1.5*charsize, orientation=90.
    ;;GALEX
    ;;restore probabilities
    xdqso= mrdfits('chunk11_extreme_deconv_galex_ugriz.fits',1)
    xdqsoz= mrdfits('chunk11_xdqsoz_galex.fits',1)
    ;;calculate efficiency
    sortxdqso= reverse(sort(xdqso.pqso))
    sortxdqsoz= reverse(sort(xdqsoz.pqso))
    ysone= dblarr(nxs)
    ystwo= dblarr(nxs)
    FOR ii=0L, nxs-1 DO BEGIN
        targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
        ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
        targetindx= sortxdqso[0:floor(xs[ii]*area)]
        ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    ENDFOR
    djs_plot, xs, ysone, linestyle=0, $
      position=[0.1,0.1+2.*ywidth,0.1+xwidth,0.1+3.*ywidth], charsize=charsize, xtickformat='(A1)', /noerase, $
      xrange=xrange, yrange=yrange
    djs_oplot, xs, ystwo, linestyle=1
    djs_oplot, xs, ysthree, linestyle=0, color=djs_icolor('gray')
    djs_oplot, xrange, 0.5*xrange, color='gray',thick=effthick
    legend, ['+ GALEX UV'], box=0., charsize=legendcharsize, $
      /top, /left
    ;;SDSS
    ;;restore probabilities
    xdqso= mrdfits('chunk11_extreme_deconv_z4.fits',1)
    xdqsoz= mrdfits('chunk11_xdqsoz_z4.fits',1)
    ;;calculate efficiency
    sortxdqso= reverse(sort(xdqso.pqso))
    sortxdqsoz= reverse(sort(xdqsoz.pqso))
    ysone= dblarr(nxs)
    ystwo= dblarr(nxs)
    FOR ii=0L, nxs-1 DO BEGIN
        targetindx= sortxdqsoz[0:floor(xs[ii]*area)]
        ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
        targetindx= sortxdqso[0:floor(xs[ii]*area)]
        ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 4.))/specarea
    ENDFOR
    djs_plot, xs, ysone, linestyle=0, $
      position=[0.1,0.1+3.*ywidth,0.1+xwidth,0.1+4.*ywidth], charsize=charsize, xtickformat='(A1)', /noerase, $
      xrange=xrange, yrange=yrange
    djs_oplot, xs, ystwo, linestyle=1
    djs_oplot, xrange, 0.5*xrange, color='gray',thick=effthick
    xyouts, 46., 24., '50 %', charsize=1.2*charsize, orientation=atan((yrange[1]-yrange[0])/(xrange[1]-xrange[0]))/!dpi*180., color=djs_icolor('gray')
    legend, ['SDSS ugriz'], box=0., charsize=legendcharsize, $
      /top, /left
    legend, ['XDQSOz','XDQSO'], box=0., charsize=legendcharsize, $
      /bottom, /right, linestyle=[0,1]
    k_end_print
ENDIF ELSE BEGIN
    ;;restore probabilities
    xdqso= mrdfits('chunk11_extreme_deconv_z4.fits',1)
    xdqsoz= mrdfits('chunk11_xdqsoz_z4.fits',1)
    ;;plot
    k_print, filename=plotfile
    hogg_scatterplot, xdqso.pqso, xdqsoz.pqso-xdqso.pqso, $
      xtitle='XDQSO P(2.2 !9l!x z !9l!x 4.0 quasar)', $
      ytitle='XDQSOz - XDQSO', $
      xrange=[0.,1.], yrange=[-.1,.1], /nogreyscale, $
      /conditional, quantiles=[0.25,.5,.75], position=[0.1,0.1,0.5,0.5], $
      charsize=0.7
    hogg_scatterplot, xdqso.pqso, xdqsoz.pqso, $
        ytitle='XDQSOz P(2.2 !9l!x z !9l!x 4.0 quasar)', $
        xrange=[0.,1.], yrange=[0.,1.], /nogreyscale, $
        /conditional, quantiles=[0.25,.5,.75], position=[0.1,0.5,0.5,0.9], $
        /noerase, xtickformat='(A1)', charsize=0.7
    k_end_print
ENDELSE
END
