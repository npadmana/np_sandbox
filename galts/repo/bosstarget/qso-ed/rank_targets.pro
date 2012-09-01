;+
;   NAME:
;      rank_targets
;   PURPOSE:
;      given photometry, calculate p_qso for each one, sort, and save
;   INPUT:
;      chunk - 1 or 2
;   OPTIONAL INPUT:
;      lumfunc - QSO luminosity function to use ('HRH07' or 'R06';
;                default= 'HRH07')
;   OUTPUT:
;      (none; just writes the savefilename)
;   BUGS:
;      PATHs not universal
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;      2010-04-29 - Adapted for sdss3 svn repos - Bovy
;-
PRO RANK_TARGETS, chunk=chunk, lumfunc=lumfunc
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07'
IF ~keyword_set(chunk) THEN chunk= 1
IF chunk EQ 1 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits'
    savefilename= 'chunk1_extreme_deconv_'+lumfunc+'.fits'
ENDIF ELSE IF chunk EQ 2 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits'
    savefilename= 'chunk2_extreme_deconv_'+lumfunc+'.fits'
ENDIF ELSE BEGIN
    print, "No chunk "+strtrim(chunk)
    print, "returning ..."
    RETURN
ENDELSE
;;Prep the data
data= mrdfits(datafilename,1)
out= qsoed_calculate_prob(data,lumfunc=lumfunc)

;;Save to a file
mwrfits, out, savefilename, /create
END
