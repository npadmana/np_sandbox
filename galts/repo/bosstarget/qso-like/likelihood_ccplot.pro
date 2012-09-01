;------------------------------------------------------------------------------
pro likelihood_ccplot, filename, plotfile=plotfile

   if (NOT keyword_set(filename)) then $
    filename = 'merge-QSO-target-000-001.fits.gz'
   if (NOT keyword_set(plotfile)) then $
    plotfile = (str_sep(filename,'.'))[0]+'.ps'
   objs = mrdfits(filename,1)
   ntot = n_elements(objs)
   ra = objs.ra - 360*(objs.ra GT 180)
   mag = 22.5 - 2.5*alog10(objs.flux_clip_mean)
   ugcolor = transpose(mag[0,*] - mag[1,*])
   grcolor = transpose(mag[1,*] - mag[2,*])
   iqso = where(objs.l_ratio GT 0.1, nqso)
   iqso1 = where(objs.l_ratio GT 0.1 AND objs.l_everything LT 1e-6, nqso1)
   iqso2 = where(objs.l_ratio GT 0.1 AND objs.l_everything GT 1e-6, nqso2)

; Plot a random-sampling of points...
;irand = randomu(1234,20000) * n_elements(objs)
;splot, ugcolor[irand], grcolor[irand], ps=3, xr=[-0.5,3], yr=[-1,2.5]
;soplot, ugcolor[iqso], grcolor[iqso], ps=3, color='red'
;soplot, ugcolor[iqso2], grcolor[iqso2], ps=3, color='green'

   nx = 350
   ny = 350
   xmin = -0.5
   ymin = -1.0
   dx = 0.01
   dy = 0.01
   xvec = xmin + dx * findgen(nx)
   yvec = ymin + dy * findgen(ny)
   image = fltarr(nx,ny)
   ix = round((ugcolor-xmin)/dx)
   iy = round((grcolor-ymin)/dy)
   populate_image, image, ix, iy
   ximg = rebin(xvec,nx,ny)
   yimg = transpose(rebin(yvec,ny,nx))

   dfpsplot, plotfile, /square, /color
   csize = 1
   contour, image, ximg, yimg, nlevel=10, $
    xrange=minmax(xvec), yrange=minmax(yvec), $
    /xstyle, /ystyle, xtitle='u-g', ytitle='g-r', charsize=csize, $
    title=filename
   djs_oplot, ugcolor[iqso1], grcolor[iqso1], psym=1, symsize=0.5, color='red'
   djs_oplot, ugcolor[iqso2], grcolor[iqso2], psym=1, symsize=0.5, color='green'
   djs_xyouts, 0, 2.10, charsize=csize, $
    'BLACK = everything  (N='+strtrim(ntot,2)+')'
   djs_xyouts, 0, 1.95, charsize=csize, $
    'RED = L_{ratio}>0 AND L_{everything}<1e-6  (N='+strtrim(nqso1,2)+')'
   djs_xyouts, 0, 1.80, charsize=csize, $
    'GREEN = L_{ratio}>0 AND L_{everything}>1e-6  (N='+strtrim(nqso2,2)+')'
   dfpsclose

   return
end
;------------------------------------------------------------------------------
