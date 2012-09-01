PRO XDQSOZ_PLOTALLPEAKS, plotfile, intprob=intprob
legendcharsize=2.
charsize=1.4
xwidth= 0.35
ywidth= 0.2
thick=5.
k_print, filename=plotfile, ysize=20, xsize=20
;;SDSS, ALL
position=[0.1,0.1+3.*ywidth,0.1+xwidth,0.1+4.*ywidth]
if keyword_set(intprob) then tmpfile= 'xdqsoz_peaks_intprob.sav' $
else tmpfile= 'xdqsoz_peaks.sav'
xdqsoz_plotpeaks, '', tmpfile=tmpfile, $
  position=position, $
  legendcharsize=legendcharsize, $
  charsize=charsize, $
  xtickformat='(A1)', /nolabels, $
  sdssav=sdssav, thick=thick, $
  intprob=intprob
;;UKIDSS+GALEX
if keyword_set(intprob) then tmpfile= 'xdqsoz_peaks_galex_ukidss_intprob.sav' $
  else tmpfile= 'xdqsoz_peaks_galex_ukidss.sav'
position=[0.1,0.1,0.1+xwidth,0.1+ywidth]
xdqsoz_plotpeaks, '', tmpfile=tmpfile, $
  /galex,/ukidss, xtitle='redshift', $
  position=position, /nolabels, $
  legendcharsize=legendcharsize, $
  charsize=charsize, /noerase, $
  sdssav=sdssav, thick=thick, $
  intprob=intprob
;;UKIDSS
position=[0.1,0.1+ywidth,0.1+xwidth,0.1+2.*ywidth]
if keyword_set(intprob) then tmpfile= 'xdqsoz_peaks_ukidss_intprob.sav' $
  else tmpfile= 'xdqsoz_peaks_ukidss.sav'
xdqsoz_plotpeaks, '', tmpfile=tmpfile, $
  /ukidss, /noerase, $
  position=position, $
  legendcharsize=legendcharsize, $
  charsize=charsize, $
  xtickformat='(A1)', /nolabels, $
  sdssav=sdssav, thick=thick, $
  intprob=intprob
;;label
xyouts, -.8, -.75, $
  'average number of peaks in the redshift pdf', orientation=90., charsize=charsize*2.
;;GALEX
position=[0.1,0.1+2.*ywidth,0.1+xwidth,0.1+3.*ywidth]
if keyword_set(intprob) then tmpfile= 'xdqsoz_peaks_galex_intprob.sav' $
  else tmpfile= 'xdqsoz_peaks_galex.sav'
xdqsoz_plotpeaks, '', tmpfile=tmpfile, $
  /galex, /noerase, $
  position=position, $
  legendcharsize=legendcharsize, $
  charsize=charsize, $
  xtickformat='(A1)', /nolabels, $
  sdssav=sdssav, thick=thick, $
  intprob=intprob
k_end_print
END
