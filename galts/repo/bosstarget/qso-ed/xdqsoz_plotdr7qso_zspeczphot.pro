PRO XDQSOZ_PLOTDR7QSO_ZSPECZPHOT, plotfile=plotfile, $
                                  hoggscatter=hoggscatter, conditional=conditional, $
                                  ilim=ilim, imin=imin, testqso=testqso, $
                                  intprob=intprob
width= 0.2
charsize= 1.2
legendcharsize=1.4
symsize=0.01
IF keyword_set(plotfile) THEN k_print, filename=plotfile, xsize=20,ysize=20
;;GALEX+UKIDSS, ALL
position=[0.1,0.1,0.1+width,0.1+width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_ukidss_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_ukidss_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_ukidss.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_ukidss.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position, outliers_psym=3, outliers_symsize=symsize, $
  testqso=testqso
;;label
xyouts, 2.75, -1.7, $
  'spectroscopic redshift', charsize=charsize*2.
;;UKIDSS, ALL
position=[0.1,0.1+width,0.1+width,0.1+2.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_ukidss_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_ukidss_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_ukidss.sav' ELSE $
      tmpfile='xdqsoz_peaks_ukidss.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, $
  testqso=testqso
;;label
xyouts, -.8, 3., $
  'photometric redshift', orientation=90., charsize=charsize*2.
;;GALEX, ALL
position=[0.1,0.1+2.*width,0.1+width,0.1+3.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, $
  testqso=testqso
;;SDSS, ALL
position=[0.1,0.1+3.*width,0.1+width,0.1+4.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso.sav' ELSE $
      tmpfile='xdqsoz_peaks.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, $
  testqso=testqso
;;label
IF keyword_set(testqso) THEN BEGIN
    xyouts, .75, 6.2, $
      '10 % test sample', charsize=charsize*1.8
ENDIF ELSE BEGIN
    xyouts, 1.65, 6.2, $
      'all DR7QSO', charsize=charsize*1.8
ENDELSE

;;GALEX+UKIDSS, ONEPEAK
position=[0.1+width,0.1,0.1+2.*width,0.1+width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_ukidss_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_ukidss_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_ukidss.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_ukidss.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /galex,/ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, charsize=charsize, legendcharsize=legendcharsize, $
  position=position,/onepeak,/noerase, ytickformat='(A1)', $
  testqso=testqso
;;UKIDSS, ONEPEAK
position=[0.1+width,0.1+width,0.1+2.*width,0.1+2.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_ukidss_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_ukidss_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_ukidss.sav' ELSE $
      tmpfile='xdqsoz_peaks_ukidss.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /ukidss,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', $
  testqso=testqso
;;GALEX, ONEPEAK
position=[0.1+width,0.1+2.*width,0.1+2.*width,0.1+3.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_galex.sav' ELSE $
      tmpfile='xdqsoz_peaks_galex.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  /galex,hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', $
  testqso=testqso
;;SDSS, ONEPEAK
position=[0.1+width,0.1+3.*width,0.1+2.*width,0.1+4.*width]
if keyword_set(intprob) then begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso_intprob.sav' ELSE $
      tmpfile='xdqsoz_peaks_intprob.sav'
endif else begin
    IF keyword_set(testqso) THEN tmpfile='xdqsoz_peaks_testqso.sav' ELSE $
      tmpfile='xdqsoz_peaks.sav'
endelse
xdqsoz_plotzspeczphot, tmpfile=tmpfile, $
  hoggscatter=hoggscatter,conditional=conditional, $
  /nolabels, /noerase, xtickformat='(A1)', charsize=charsize, $
  legendcharsize=legendcharsize, position=position, /onepeak, ytickformat='(A1)', $
  testqso=testqso
;;label
IF keyword_set(testqso) THEN BEGIN
    xyouts, -.35, 6.2, $
      'one peak 10 % test sample', charsize=charsize*1.7
ENDIF ELSE BEGIN
    xyouts, .85, 6.2, $
      'one peak DR7QSO', charsize=charsize*1.7
ENDELSE

IF keyword_set(plotfile) THEN k_end_print

END
