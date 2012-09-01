PRO PLOT_S82_FRACEXTENDED, plotfile=plotfile, coadd=coadd
;;read point-sources
point= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
;;read co-added galaxy catalog
if ~keyword_set(coadd) then $
  coadd= mrdfits('$BOVYQSOEDDATA/stripe82.galaxies.fits',1)
badra= where(coadd.ra GT 360.,cnt)
if cnt gt 0 then coadd[badra].ra-= 360.
;;match
spherematch, coadd.ra, coadd.dec, point.ra, point.dec, 2./3600., $
  cindx, pindx
;;determine which one is actually a point source
coadd_point= bytarr(n_elements(point))
coadd_point[pindx]= 1B
;;plot the fraction as a function of magnitude
prep_data, point.psfflux, point.psfflux_ivar, extinction=point.extinction, $
  mags=mags,var_mags=v
;;also get PQSO for these objects
xdqsoz_sdss= mrdfits('chunk11_xdqsoz_z4.fits',1)
pqsoall= xdqsoz_sdss.allqsolike*xdqsoz_sdss.qsonumber
indx= where(pqsoall ne 0.,cnt)
if cnt gt 0 then pqsoall[indx]= pqsoall[indx]/(pqsoall[indx]+xdqsoz_sdss[indx].everythinglike*xdqsoz_sdss[indx].everythingnumber) 
;;plot
nbins= 31
xrange=[17.8,22.5]
dx= (xrange[1]-xrange[0])/float(nbins-1)
xs= dindgen(nbins)*dx+xrange[0]-dx/2.
frac= dblarr(nbins)
xdfrac= dblarr(nbins)
xd2frac= dblarr(nbins)
for ii=0L, nbins-1 do begin
    indx= where(mags[3,*] GE (17.8+ii*dx) $
      AND mags[3,*] LT (17.8+(ii+1)*dx),cnt)
    if cnt eq 0 then frac[ii]= -1 $
      else frac[ii]= total(coadd_point[indx])/float(cnt)
    indx= where(mags[3,*] GE (17.8+ii*dx) $
                AND mags[3,*] LT (17.8+(ii+1)*dx) $
                AND pqsoall GE 0.5,cnt2)
    if cnt2 eq 0 then xdfrac[ii]= 0. $
      else xdfrac[ii]= total(coadd_point[indx])/float(cnt)
    if cnt2 eq 0 then xd2frac[ii]= 0. $
      else xd2frac[ii]= cnt2/float(cnt)
endfor
if keyword_set(plotfile) then k_print, filename=plotfile
djs_plot, xs, frac,   xtickformat='(A1)', $
  xrange=[xrange[0]-dx/2.,xrange[1]+dx/2.],yrange=[0.,.499], $
  position=[.1,.5,.9,.9]
legend, ['all'], box=0., charsize=1.4, $
      /top, /left
djs_plot, xs, xdfrac, xtitle='i [mag]', $
  xrange=[xrange[0]-dx/2.,xrange[1]+dx/2.],yrange=[0.,0.499], $
  position=[.1,.1,.9,.5], $
  /noerase 
djs_oplot, xs, xd2frac, linestyle=2
xyouts, 17.2, 0.06, 'fraction of point sources that are galaxies', $
  charsize=1.6, orientation=90.
legend, ['XDQSOz P(quasar) !9b!x 0.5',$
         ' ', $
        'fraction of all point sources w/ P(quasar) !9b!x 0.5'], $
  box=0., charsize=1.4, $
  /top, /left
plots, [20.,21.8],[0.33,0.26],/data
if keyword_set(plotfile) then k_end_print
END
