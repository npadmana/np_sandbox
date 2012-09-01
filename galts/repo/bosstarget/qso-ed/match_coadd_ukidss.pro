;+
;   NAME:
;      match_coadd_ukidss
;   PURPOSE:
;      match the stripe-82 coadded data to the UKIDSS data
;   INPUT:
;      coadddatafilename - file that has the coadded data
;      ukidssdatafilename - file that has the ukidss data
;      outfilename - name of the file that will hold the output (ukidss+matchTHING_ID)
;      matchlength - spherematch matchlength (deg)
;   OUTPUT:
;      writes a fits-file
;   HISTORY:
;      2010-05-05 - Written - Bovy (NYU)
;-
PRO MATCH_COADD_UKIDSS, coadddatafilename=coadddatafilename,$
                        ukidssdatafilename=ukidssdatafilename, $
                        outfilename=outfilename, matchlength=matchlength
IF ~keyword_set(coadddatafilename) THEN coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'
IF ~keyword_set(ukidssdatafilename) THEN ukidssdatafilename= '$BOVYQSOEDDATA/ukidss_stripe82.fits'
IF ~keyword_set(outfilename) THEN outfilename= '$BOVYQSOEDDATA/ukidss_stripe82_coaddmatched.fits'
IF ~keyword_set(matchlength) THEN matchlength= 0.7/3600.

;;Read the ukidss data
ukidss= mrdfits(ukidssdatafilename,1)
nukidss= n_elements(ukidss.ra)
;;Read the coadded data
coadd= mrdfits(coadddatafilename,1)

;;Sphere-match
spherematch, ukidss.ra*180D0/!DPI, ukidss.dec*180D0/!DPI, $
  coadd.ra, coadd.dec, matchlength, $
  match1, match2, distance12

matchthingid= {THING_ID:-1L}
matchstruct= replicate(matchthingid,nukidss)
foundmatch= where(match1 NE -1)
IF foundmatch[0] NE -1 THEN matchstruct[match1[foundmatch]].thing_id= coadd[match2[foundmatch]].thing_id
newukidss= struct_addtags(ukidss,matchstruct)

;;Save to a file
mwrfits, newukidss, outfilename, /create
END
