;------------------------------------------------------------------------------
;+
; NAME:
;   qso-colorbox
;
; PURPOSE:
;   A very simple procedure than imposes a series of simple
;   color-cuts that could potentially be used to define a 
;   CORE BOSS QSO sample.
;
; CALLING SEQUENCE:
;   > .r qso-colorbox
;
; INPUTS:
;       The same input (datasweep) files as the other TS routines. 

; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
; DATA FILES:
;   $BOSSTARGET_DIR/data/
;
; COMMON BLOCKS:
;
; PROCEDURES USED:
;
; COMMENTS:
;       Original suggestion/idea from David Schlegel. 
;       See emails [sdss3-qsos 930] and [sdss3-qsos 1226] 
;       Some of the content for the latter is given in comments
;       below. 
;       
;       Note, this code is *MEGA* simple right now, and more
;       just a placeholder than anything....
;
; EXAMPLES:
;          IDL> .run qso-colorbox
;
; MODIFICATION HISTORY:
;   01-March-2010       v0.0.1       N.P. Ross
;       This version is just really the header and the
;       notes from the emails. I've not even run it to 
;       see what happens, let alone tested it. 
;               
;-
;------------------------------------------------------------------------------



;; I/P files

;; COPIED STRAIGHT FROM ../qso-like/likelihood_compute.pro
;;
;; Read the QSO+star model objects from catalog co-adds
file = ['varcat-ra300-330.fits.gz', 'varcat-ra330-360.fits.gz', $
       'varcat-ra0-30.fits.gz', 'varcat-ra30-60.fits.gz']
ntot = 0L
nisolated = 0L
    for i=0, n_elements(file)-1 do begin
      objs = mrdfits(file[i], 1)
      objs = objs[where((objs.ra GT 315. OR objs.ra LT 45.) $
       AND objs.dec GT -1.25 AND objs.dec LT 1.25)]

      ; Trim to primary stars that don't have bad flags
      indx = likelihood_qso_trim(objs)
      objs = objs[indx]

      ; Trim to objects with a minimum number of good photometry
      min_ngood = 8
      ngood = lonarr(n_elements(objs)) + min_ngood
      for j=0,4 do ngood = (ngood < objs.flux_ngood[j])
      indx = where(ngood GE min_ngood)
      objs = objs[indx]

      ; Identify blended objects
      ntot += n_elements(objs)
      qisolated = (objs.objc_flags AND sdss_flagval('OBJECT1','CHILD')) EQ 0
      indx = where(qisolated EQ 1, ct)
      nisolated += ct
      objs = objs[indx]

      ; Select the fluxes we want, and extinction-correct
      newobj1 = replicate( create_struct('PSFFLUX', fltarr(5), $
       'RA', 0d, 'DEC', 0d, 'FLUX_CLIP_RCHI2', fltarr(5)), ct)
      newobj1.psfflux = objs.flux_clip_mean * 10.^(0.4*objs.extinction)
      newobj1.ra = objs.ra
      newobj1.dec = objs.dec
      newobj1.flux_clip_rchi2 = objs.flux_clip_rchi2
      if (keyword_set(newobj)) then newobj = [newobj, newobj1] $
       else newobj = newobj1
   endfor
   frac_isolated = double(nisolated) / ntot

;; object colors

ug_obj = objs.upsf - objs.gpsf
gr_obj = objs.gpsf - objs.rpsf



;; parameters in the cuts
;;
;; From email [sdss3-qsos 1226] 
;; 
;; (g-r) < -0.3 * (1.3/3) * (u-g)
;; (u-g) > 0.4
;; 17.8 < r < 21.5
;; I think I suggested this some time ago, but we never checked it.
;; Only slightly more complicated would be to have the (g-r) cut
;; slide bluer at fainter magnitudes (to keep us away from the stellar locus).
;; This would include all the BHB stars, but we probably already do.
;;
;; If someone has Erin's files on disk, this should be straightforward
;; to check.
;;
;; NPR: I think it's  (g-r) < -0.3 plus (1.3/3) * (u-g)...


r_bright = 17.8
r_faint  = 21.5

gr_offset = -0.3
ug_slope  = (1.3/3.)

ug_upper = 1.5 
ug_lower = 0.4

;; Extra term added in DJS notes...
rmag_term =  [ (objs.rpsf-19.)  ] / 5. 


;; Just doing a where for the time being 
inbox = where( (gr_obj lt ( gr_offset +  (ug_slope* ug_obj) - rmag_term)) and $
    ug_obj gt ug_lower and $
    ug_obj lt ug_upper and $
    objs.rpsf gt r_bright and $
    objs.rpsf gt r_faint, N_objs_pass)

    

end

;(g-r) < -0.3 * (1.3/3) * (u-g)
;(u-g) > 0.4
;17.8 < r < 21.5
;I think I suggested this some time ago, but we never checked it.
;Only slightly more complicated would be to have the (g-r) cut
;slide bluer at fainter magnitudes (to keep us away from the stellar locus).
;This would include all the BHB stars, but we probably already do.

;If someone has Erin's files on disk, this should be straightforward
;to check.

