;+
;   NAME:
;      exd_bonus_overlap
;   PURPOSE:
;      what is the overlap between ExD and CORE+BONUS?
;   INPUT:
;      chunk - chunk to consider
;   OUTPUT:
;      prints # fibers / deg^2 unique to ExD
;   HISTORY:
;      2010-06-26 - Written - Bovy (NYU)
;-
PRO EXD_BONUS_OVERLAP, chunk

;establish a set of targets and the area they cover...
in = mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)
in = in[where(in.inchunk eq chunk)]
IF chunk EQ 1 THEN BEGIN
    area = 219.93065D
ENDIF ELSE IF chunk EQ 2 THEN BEGIN
    area = 143.66D
ENDIF ELSE IF chunk EQ 4 THEN BEGIN
    area= 107.34D
ENDIF ELSE IF chunk EQ 8 THEN BEGIN
    area= 306.50D
ENDIF ELSE IF chunk EQ 16 THEN BEGIN
    area= 245.82D
ENDIF

;take out core, first and z > 2.2 known quasars
flags = (in.boss_target1 and 2LL^18+2LL^12)
freefib= nint(20.*area)
ind = (reverse(sort(in.like_ratio_core)))[freefib]
like_thresh = in[ind].like_ratio_core
noncore = in[where(flags eq 0 and in.like_ratio_core LE like_thresh)]

;total numbers of fibers available for the BONUS
freefib = nint((40.*area)-(n_elements(where(flags ne 0 or in.like_ratio_core GT like_thresh))))

print, (n_elements(where(flags ne 0 or in.like_ratio_core GT like_thresh)))/area
print, (n_elements(where(in.like_ratio_core GT like_thresh)))/area
print, (n_elements(where(flags ne 0)))/area

;sort by nnvalue and find minimum allowed value of nn_thresh in BONUS
;at ;this fiber level
ind = (reverse(sort(noncore.nn_value)))[freefib]
nn_thresh = noncore[ind].nn_value

;this is now everything in the CORE+BONUS target sample
targw = where(flags ne 0 or in.nn_value gt nn_thresh or in.like_ratio_core gt like_thresh)

;;Onto ExD
sorted= reverse(sort(in.qsoed_prob))
ncoretargets= nint(20.*area)

match, targw, sorted[0:ncoretargets-1], sublike, subed

print, "Number of fibers unique to ExD:"
print, (ncoretargets-n_elements(subed))/area


END
