;+
;   NAME:
;      check_ukidss_match
;   PURPOSE:
;      check that matching the ukidss data to the coadded data worked
;   INPUT:
;      plotfilename - filename for plot
;   OPTIONAL INPUT:
;      coadddatafilename - file that has the coadded data
;      ukidssdatafilename - file that has the ukidss data
;      outfilename - name of the file that will hold the output (ukidss+matchTHING_ID)
;      matchlength - spherematch matchlength (deg)
;   OUTPUT:
;     figures in plotfilename
;   HISTORY:
;      2010-05-05 - Written - Bovy (NYU)
;-
PRO CHECK_UKIDSS_MATCH, coadddatafilename=coadddatafilename,$
                        ukidssdatafilename=ukidssdatafilename, $
                        outfilename=outfilename, matchlength=matchlength, $
                        plotfilename=plotfilename
IF ~keyword_set(coadddatafilename) THEN coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
IF ~keyword_set(ukidssdatafilename) THEN ukidssdatafilename= '$BOVYQSOEDDATA/ukidss_stripe82.fits'
IF ~keyword_set(outfilename) THEN outfilename= '$BOVYQSOEDDATA/ukidss_stripe82_coaddmatched.fits'
IF ~keyword_set(matchlength) THEN matchlength= 0.7/3600.

ukidssmatch= mrdfits(outfilename,1)
coadd= mrdfits(coadddatafilename,1)

hasmatch= where(ukidssmatch.thing_id NE -1)
nmatch= n_elements(hasmatch)
match, ukidssmatch[hasmatch].thing_id, coadd.thing_id, match1, match2
matchra= ukidssmatch[hasmatch[match1]].ra*180D0/!DPI-coadd[match2].ra
matchdec= ukidssmatch[hasmatch[match1]].dec*180D0/!DPI-coadd[match2].dec

IF keyword_set(plotfilename) THEN k_print, filename=plotfilename
djs_plot, matchra, xtitle='index', ytitle='Delta RA [deg]', psym=3
print, matchlength, nmatch
djs_oplot, [0.,nmatch],[matchlength, matchlength], color=djs_icolor('red')
djs_oplot, [0.,nmatch],[-matchlength, -matchlength], color=djs_icolor('red')
IF ~keyword_set(plotfilename) THEN stop

djs_plot, matchdec, xtitle='index', ytitle='Delta Dec [deg]', psym=3
djs_oplot, [0.,nmatch],[matchlength, matchlength], color=djs_icolor('red')
djs_oplot, [0.,nmatch],[-matchlength, -matchlength], color=djs_icolor('red')

IF keyword_set(plotfilename) THEN k_end_print
END
