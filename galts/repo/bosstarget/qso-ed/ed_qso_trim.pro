;------------------------------------------------------------------------------
; Return the indices of good objects from the point of view of QSO
; flag-checking, assuming we've (?)
; BOVY: adapted from ../qso-like/likelihood_qso_trim.pro
function ed_qso_trim, objs

   primval = sdss_flagval('RESOLVE_STATUS','SURVEY_PRIMARY')

   qmpeaks = (objs.objc_flags $
    AND sdss_flagval('OBJECT1','DEBLEND_TOO_MANY_PEAKS')) NE 0
   qmoved = (objs.objc_flags AND sdss_flagval('OBJECT1','MOVED')) NE 0 $
    AND (objs.objc_flags2 AND sdss_flagval('OBJECT2','STATIONARY')) EQ 0
   qbinned1 = (objs.objc_flags AND sdss_flagval('OBJECT1','BINNED1')) NE 0
   qsatur = (objs.objc_flags2 AND sdss_flagval('OBJECT2','SATUR_CENTER')) NE 0
   qinterp = ((objs.objc_flags AND sdss_flagval('OBJECT1','CR')) NE 0 $
    AND (objs.objc_flags2 AND sdss_flagval('OBJECT2','INTERP_CENTER')) NE 0) $
    OR ((objs.objc_flags2 AND sdss_flagval('OBJECT2','PSF_FLUX_INTERP')) NE 0)
   qbadcounts = (objs.objc_flags2 $
    AND sdss_flagval('OBJECT2','BAD_COUNTS_ERROR')) NE 0
   qnotchecked = (objs.objc_flags2 $
    AND sdss_flagval('OBJECT2','NOTCHECKED_CENTER')) NE 0

   indx = where(objs.objc_type EQ 6 $
;AND (objs.resolve_status AND primval) NE 0 $
                AND qmpeaks EQ 0 $
                AND qmoved EQ 0 $
                AND qbinned1 EQ 1 $
                AND qsatur EQ 0 $
                AND qbadcounts EQ 0 $
                AND qnotchecked EQ 0)
;    AND qinterp EQ 0 $ ; Discards 17% of objects, mostly from u+z bands

   return, indx
end
;------------------------------------------------------------------------------
