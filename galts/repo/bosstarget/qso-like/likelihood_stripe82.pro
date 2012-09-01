;+
; NAME:
;   likelihood_stripe82
;
; PURPOSE:
;   Compute the QSO likelihoods for BOSS target selection on stripe 82
;
; CALLING SEQUENCE:
;   likelihood_stripe82, [ ra_min, ra_max, infile, outfile ]
;
; INPUTS:
;
; OPTIONAL INPUTS:
;   ra_min - Min RA for trimmming objects; default to 0 deg
;   ra_max - Max RA for trimmming objects; default to 360 deg
;   infile - Input file(s) from stripe 82 co-adds (written by SWEEP_VARCAT);
;            default to ['varcat-ra300-330.fits.gz', $
;                        'varcat-ra330-360.fits.gz', $
;                        'varcat-ra0-30.fits.gz', $
;                        'varcat-ra30-60.fits.gz']
;   outfile - Output file name; default to 'QSO-target-XXX-YYY.fits'
;             where XXX=ra_min and YYY=ra_max
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
; COMMENTS:
;
; EXAMPLES:
;
; DATA FILES:
;
; PROCEDURES CALLED:
;
; INTERNAL SUPPORT ROUTINES:
;
; REVISION HISTORY:
;   01-Aug-2009  Written by D. Schlegel, J. Hennawi, J. Kirkpatrick,
;                V. Bhardwaj, LBL
;-
;------------------------------------------------------------------------------
pro likelihood_stripe82, ra_min1, ra_max1, infile, outfile

   if (n_elements(ra_min1) GT 0) then ra_min = ra_min1[0] else ra_min = 0.
   if (n_elements(ra_max1) GT 0) then ra_max = ra_max1[0] else ra_max = 360.
   if (NOT keyword_set(infile)) then $
    infile = ['varcat-ra300-330.fits.gz', 'varcat-ra330-360.fits.gz', $
     'varcat-ra0-30.fits.gz', 'varcat-ra30-60.fits.gz']
   if (NOT keyword_set(outfile)) then $
    outfile = 'QSO-target-'+string(ra_min,format='(i3.3)')+'-' $
     +string(ra_max,format='(i3.3)')+'.fits'

   t0 = systime(1)

   ; Read objects from catalog co-adds
   for i=0, n_elements(infile)-1 do begin
      objs = mrdfits(infile[i], 1)
      objs = objs[where(objs.ra GE ra_min AND objs.ra LT ra_max $
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

      ; Select the fluxes we want, and extinction-correct
      addobj = replicate( create_struct('FLUX', fltarr(5), $
       'FLUX_IVAR', fltarr(5)), n_elements(objs))
      addobj.flux = objs.flux_clip_mean * 10.^(0.4*objs.extinction)
      addobj.flux_ivar = objs.flux_ngood / (objs.flux_clip_rms)^2 $
       * 10.^(-0.8*objs.extinction)
      objs = struct_addtags(objs, addobj)

      ; Trim to r<22.0
      fluxlimit = 10.^((22.5-22.0)/2.5)
      indx = where(objs.flux[2] GT fluxlimit)
      objs = objs[indx]

      if (keyword_set(newobj)) then newobj = [newobj, objs] $
       else newobj = objs
   endfor

   ; Compute the likelihoods
   likelihood_compute, newobj, objs_out
   newobj = struct_addtags(newobj, objs_out)

   splog, 'Writing file ', outfile
   mwrfits, newobj, outfile, /create

   t1 = systime(1)
   splog, 'Elapsed time = ', t1-t0

   return
end
;------------------------------------------------------------------------------
