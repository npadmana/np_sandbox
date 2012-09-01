;+
; NAME:
;   likelihood_plate2634
;
; PURPOSE:
;   Compute the QSO likelihoods for SDSS spectra on plate 2634 footprint
;
; CALLING SEQUENCE:
;   likelihood_stripe2634, [ outfile ]
;
; INPUTS:
;
; OPTIONAL INPUTS:
;   outfile - Output file name; default to 'QSO-target-plate2634.fits'
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
;   02-Aug-2009  Written by D. Schlegel, LBL
;-
;------------------------------------------------------------------------------
pro likelihood_plate2634, outfile

   if (NOT keyword_set(outfile)) then outfile = 'QSO-target-plate2634.fits'

   t0 = systime(1)

   readspec_footprint, 2634, zans=zans, tsobj=objs, /best
   indx = where(objs.objc_type EQ 6 AND zans.zwarning EQ 0)
   zans = zans[indx]
   objs = objs[indx]
   objs = struct_addtags(struct_selecttags(objs,except='MJD'), zans)

; Replace photometry with ubercal???

; Add in photometric-only objects
;   racen = 35.882961
;   deccen = 0.125012
;   radius = 1.5 + 0.161
;   setenv, 'PHOTO_SWEEP=/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/dr7'
;   objs = sdss_sweep_circle(racen, deccen, radius, type='star')
;   indx = where(objs.psfflux[2] GT 1.) ; Trim out sky fibers
;   objs = objs[indx]

   ; Select the fluxes we want, and extinction-correct
   addobj = replicate( create_struct('FLUX', fltarr(5), $
    'FLUX_IVAR', fltarr(5)), n_elements(objs))
   addobj.flux = objs.psfflux * 10.^(0.4*objs.extinction)
   addobj.flux_ivar = objs.psfflux_ivar * 10.^(-0.8*objs.extinction)
   objs = struct_addtags(objs, addobj)

   ; Compute the likelihoods
   likelihood_compute, objs, objs_out
   newobj = struct_addtags(objs, objs_out)

   splog, 'Writing file ', outfile
   mwrfits, newobj, outfile, /create

   t1 = systime(1)
   splog, 'Elapsed time = ', t1-t0

   return
end
;------------------------------------------------------------------------------
