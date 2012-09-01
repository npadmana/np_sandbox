PRO XDQSOZ_PLOTALTQSO_ZSPECZPHOT, plotfile=plotfile, $
                                  hoggscatter=hoggscatter, conditional=conditional
width= 0.2
charsize= 1.2
legendcharsize=1.4
symsize=0.01
imin=20.1
IF keyword_set(plotfile) THEN k_print, filename=plotfile, xsize=20,ysize=20
;;GALEX+UKIDSS, DR7
position=[0.1,0.1,0.1+width,0.1+width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_galex_ukidss.sav', $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position, outliers_psym=3, outliers_symsize=symsize, $
  imin=imin
;;UKIDSS, ALL
position=[0.1,0.1+width,0.1+width,0.1+2.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_ukidss.sav', $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, imin=imin
;;label
xyouts, -.8, 3., $
  'photometric redshift', orientation=90., charsize=charsize*2.
;;GALEX, ALL
position=[0.1,0.1+2.*width,0.1+width,0.1+3.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_galex.sav', $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, imin=imin
;;SDSS, ALL
position=[0.1,0.1+3.*width,0.1+width,0.1+4.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks.sav', $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, imin=imin
;;label
xyouts, .825, 6.2, $
  textoidl('DR7QSO i >')+strtrim(string(imin,format='(F4.1)'),2), charsize=charsize*1.7

;;GALEX+UKIDSS, ONEPEAK
position=[0.1+width,0.1,0.1+2.*width,0.1+width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_galex_ukidss.sav', $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position,/onepeak,/noerase, ytickformat='(A1)', imin=imin
;;label
xyouts, 2.75, -1.7, $
  'spectroscopic redshift', charsize=charsize*2.
;;UKIDSS, ONEPEAK
position=[0.1+width,0.1+width,0.1+2.*width,0.1+2.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_ukidss.sav', $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', imin=imin
;;GALEX, ONEPEAK
position=[0.1+width,0.1+2.*width,0.1+2.*width,0.1+3.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_galex.sav', $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', imin=imin
;;SDSS, ONEPEAK
position=[0.1+width,0.1+3.*width,0.1+2.*width,0.1+4.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks.sav', $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', imin=imin
;;label
xyouts, -0.2, 6.2, $
  textoidl('one peak DR7QSO i > ')+strtrim(string(imin,format='(F4.1)'),2), charsize=charsize*1.7




;;GALEX+UKIDSS, DR7
position=[0.1+2.*width,0.1,0.1+3.*width,0.1+width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_galex_ukidss.sav', $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position, outliers_psym=3, outliers_symsize=symsize, $
  /altqso, ytickformat='(A1)',/noerase
;;UKIDSS, ALL
position=[0.1+2.*width,0.1+width,0.1+3.*width,0.1+2.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_ukidss.sav', $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /altqso, ytickformat='(A1)'
;;GALEX, ALL
position=[0.1+2.*width,0.1+2.*width,0.1+3.*width,0.1+3.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_galex.sav', $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /altqso, ytickformat='(A1)'
;;SDSS, ALL
position=[0.1+2.*width,0.1+3.*width,0.1+3.*width,0.1+4.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso.sav', $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /altqso, ytickformat='(A1)'
;;label
xyouts, 1.5, 6.2, $
  textoidl('2SLAQ+BOSS'), charsize=charsize*1.8

;;GALEX+UKIDSS, ONEPEAK
position=[0.1+3.*width,0.1,0.1+4.*width,0.1+width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_galex_ukidss.sav', $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position,/onepeak,/noerase, ytickformat='(A1)', /altqso
;;UKIDSS, ONEPEAK
position=[0.1+3.*width,0.1+width,0.1+4.*width,0.1+2.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_ukidss.sav', $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', /altqso
;;GALEX, ONEPEAK
position=[0.1+3.*width,0.1+2.*width,0.1+4.*width,0.1+3.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso_galex.sav', $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', /altqso
;;SDSS, ONEPEAK
position=[0.1+3.*width,0.1+3.*width,0.1+4.*width,0.1+4.*width]
xdqsoz_plotzspeczphot, tmpfile='xdqsoz_peaks_altqso.sav', $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', /altqso
;;label
xyouts, .25, 6.2, $
  textoidl('one peak 2SLAQ+BOSS'), charsize=charsize*1.7

IF keyword_set(plotfile) THEN k_end_print

END
