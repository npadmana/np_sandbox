;+
; NAME:
;   likelihood_compute
;
; PURPOSE:
;   Compute the QSO likelihoods for BOSS target selection
;
; CALLING SEQUENCE:
;   likelihood_compute, objs_in, objs_out, [ adderr= ]
;
; INPUTS:
;   objs_in    - Input structure with
;                  FLUX[5] - Extinction-corrected fluxes (nanomaggies)
;                  FLUX_IVAR[5] - Inverse variance of above
;                  RA - Right ascension (optional)
;                  DEC - Declination (optional)
;
; OPTIONAL INPUTS:
;   adderr     - Fractional flux errors to add in quadrature to
;                OBJS_IN.FLUX_IVAR, default to [0.014, 0.01, 0.01, 0.01, 0.014];
;                set to 0 to turn off
;
; OUTPUTS:
;   objs_out   - Output structure with
;                  L_QSO_BOSS - Likelihood of QSO at 2.2<z<3.5
;                  L_EVERYTHING - Likelihood of any stellar source
;                  L_EVERYTHING_ARRAY - Likelihood of any stellar source
;                   limited to variability rchi2 < 1.1, 1.1-1.2, 1.2-1.3,
;                   1.3-1.4, 1.4-1.5, 1.5-1.6, >1.6
;                  L_RATIO - Ratio of L_QSO_BOSS / L_EVERYTHING
;                  L_QSO_Z[19] - Likelihood of QSO in redshift bins
;                  QSO_ZMIN[19] - Min of redshift bin
;                  QSO_ZMAX[19] - Max of redshift bin
;
; OPTIONAL OUTPUTS:
;
; COMMENTS:
;   If RA,DEC are specified, then any catalog objects matching that position
;   are not included in the likelihood calculations.
;
; EXAMPLES:
;
; DATA FILES:
;   $BOSSTARGET_DIR/data/
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
function likelihood_everything_file, lfile, area=area

   thisfile = (findfile(lfile+'*'))[0]
   if (keyword_set(thisfile)) then begin
      splog, 'Reading cached file ', thisfile
      hdr = headfits(thisfile)
      area = sxpar(hdr, 'AREA')
      newobj = mrdfits(thisfile, 1)
      return, newobj
   endif

   t0 = systime(1)

   ; Read the QSO+star model objects from catalog co-adds
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

   ; Compute effective area in deg^2
   area = 2.5 * 90. * frac_isolated

   splog, 'Writing file ', lfile
   sxaddpar, hdr, 'NAXIS', 0
   sxdelpar, hdr, 'NAXIS1'
   sxdelpar, hdr, 'NAXIS2'
   sxaddpar, hdr, 'EXTEND', 'T', after='NAXIS'
   sxaddpar, hdr, 'AREA', area, ' Effective area in deg^2'
   mwrfits, 0, lfile, hdr, /create
   mwrfits, newobj, lfile
   spawn, 'gzip ' + lfile

   t1 = systime(1)
   splog, 'Time to generate star models = ', t1-t0

   return, newobj
end
;------------------------------------------------------------------------------

function likelihood_vector, objs_in, objs_cat, area

	t1 = systime(1)

	nobj = n_elements(objs_in)
	likearr = dblarr(nobj)

	; Do not compute likelihoods for any objects in the comparison catalog
	; that are identical (e.g., have the same coordinates on the sky)!
	nmatch = intarr(nobj)
	if (tag_exist(objs_in,'RA') $
		AND tag_exist(objs_in,'DEC') $
		AND tag_exist(objs_cat,'RA') $
		AND tag_exist(objs_cat,'DEC')) then begin
			spherematch, objs_in.ra, objs_in.dec, objs_cat.ra, objs_cat.dec, $
				2./3600, i1, i2, d12
			; added check that there are actually matches E.S.S.
			if i1[0] ne -1 then begin
				nmatch[i1] = 1
			endif
	endif

	for i=0L, nobj-1L do begin
		if ((i MOD 10) EQ 0) then print,i,nobj,string(13b),format='(i,i,a,$)'
		likevec = dblarr(n_elements(objs_cat)) + 1d0
		for j=0, 4 do begin
			likevec *= $
				exp(-0.5 * (objs_in[i].flux[j] - objs_cat.psfflux[j])^2 $
				* objs_in[i].flux_ivar[j])
		endfor
		; Set the likelihoods to zero for matches
		if (nmatch[i] GT 0) then begin
			k = where(i1 EQ i)
			likevec[i2[k]] = 0
		endif
		likearr[i] = total(likevec) / area
	endfor
	print

	t2 = systime(1)
	splog, 'Time to compute = ', t2-t1

	;print,likearr[0:5]
   return, likearr
end

function _compile_qsolike, recompile=recompile
	common likelihood_vector_fast_block, name, srcdir, extra_cflags

	if keyword_set(recompile) then begin
		reuse_existing=0
	endif else begin
		reuse_existing=1
	endelse

	make_dll, name, name, $
		reuse_existing=reuse_existing, $
		input_directory=srcdir, $
		output_directory=srcdir, $
		compile_directory=srcdir, $
		dll_path=dll_path, /show_all_output, $
		extra_cflags=extra_cflags

	return, dll_path
end

function likelihood_vector_fast, objs, model, area, recompile=recompile

	; Using the c function gives a speedup of about 5.5-6

	common likelihood_vector_fast_block, name, srcdir, extra_cflags

	if n_elements(extra_cflags) eq 0 then begin
		name='qsolike'

		btd=getenv('BOSSTARGET_DIR')
		if btd eq '' then message,'$BOSSTARGET_DIR not set'
		srcdir=filepath(root=btd, subdir='src', 'qso-like')

		; -mtune=native is similar to -march=native but will tune the code 
		; to this arch but won't restruct to operations on this arch.  In 
		; my experience just as fast within a few percent
		extra_cflags='-O3 -mtune=native'
	endif

	if keyword_set(recompile) then begin
		unload=1
		ignore_existing_glue=1
	endif

	obju=reform( objs.flux[0] )
	objg=reform( objs.flux[1] )
	objr=reform( objs.flux[2] )
	obji=reform( objs.flux[3] )
	objz=reform( objs.flux[4] )

	objui=reform( objs.flux_ivar[0] )
	objgi=reform( objs.flux_ivar[1] )
	objri=reform( objs.flux_ivar[2] )
	objii=reform( objs.flux_ivar[3] )
	objzi=reform( objs.flux_ivar[4] )

	mu=reform( model.psfflux[0] )
	mg=reform( model.psfflux[1] )
	mr=reform( model.psfflux[2] )
	mi=reform( model.psfflux[3] )
	mz=reform( model.psfflux[4] )

	nobj = long( n_elements(objs) )
	nmodel = long( n_elements(model) )

	like = dblarr(nobj)


	t1 = systime(1)

	; use auto_glue to generate the interface function
	; set /recompile (which implies ignore_existing_glue) to reload the 
	; shared object
	dll_path = _compile_qsolike(recompile=recompile)
	res = call_external( $
		dll_path, name, $
		float(area), $
		nmodel, $
		mu,mg,mr,mi,mz,$
		nobj,$
		obju,objg,objr,obji,objz,$
		objui,objgi,objri,objii,objzi, $
		like, $
		unload=unload,$
		ignore_existing_glue=ignore_existing_glue, $
		/auto_glue, $
		extra_cflags=extra_cflags,$
		/show_all_output)	

	t2 = systime(1)
	splog, 'Time to compute = ', t2-t1

	;print,like[0:5]

	return, like
end

;------------------------------------------------------------------------------
pro likelihood_compute, objs_in1, objs_out, adderr=adderr, $
		fast=fast, recompile=recompile

	common likelihood_compute_block, objs1, area1, objs2, area2

	t0=systime(1)

   if (n_elements(adderr) EQ 0) then adderr = [0.014, 0.01, 0.01, 0.01, 0.014]

   objs_in = struct_selecttags(objs_in1, $
    select_tags=['FLUX','FLUX_IVAR','RA','DEC'])
   if (keyword_set(adderr)) then begin
      for j=0, 4 do begin
         qgood = objs_in.flux_ivar[j] GT 0
         objs_in.flux_ivar[j] = qgood / ( 1./(objs_in.flux_ivar[j]+1-qgood) $
          + (adderr[j] * (objs_in.flux[j]>0))^2 )
      endfor
   endif

   if n_elements(objs1) eq 0 then begin
	   ; Read in the "everything" file
	   file1 = filepath('Likeli_everything.fits', $
		root_dir=getenv('BOSSTARGET_DIR'), subdir='data')
	   objs1 = likelihood_everything_file(file1, area=area1)
	   splog, 'Number of model stars = ', n_elements(objs1)
	   splog, 'Sky area = ', area1
   endif

   if n_elements(objs2) eq 0 then begin
	   ; Read in the QSO file
	   file2 = filepath('Likeli_QSO.fits.gz', $
		root_dir=getenv('BOSSTARGET_DIR'), subdir='data')
	   objs2 = mrdfits(file2, 1)
	   area2 = n_elements(objs2) / 229.07422
	   splog, 'Sky area = ', area2
	   splog, 'Number of model QSOs = ', n_elements(objs2)
   endif

   nzbin = 19
   dz = 0.1
   zmin = 2.0 + dz * lindgen(nzbin)
   zmax = 2.0 + dz * (lindgen(nzbin)+1)
   isum = where(zmin GE 2.2 AND zmax LE 3.5)
   objs_out = replicate(create_struct( $
    'L_QSO_BOSS', 0., $
    'L_EVERYTHING', 0., $
    'L_EVERYTHING_ARRAY', fltarr(7), $
    'L_RATIO', 0., $
    'L_QSO_Z', fltarr(nzbin), $
    'QSO_ZMIN', zmin, $
    'QSO_ZMAX', zmax ), n_elements(objs_in))

   ; Compute the likelihoods per deg^2
   splog, 'Computing everything likelihoods'
   i1 = where(objs1.flux_clip_rchi2[2] LT 1.1, ct1)
   i2 = where(objs1.flux_clip_rchi2[2] GE 1.1 $
    AND objs1.flux_clip_rchi2[2] LT 1.2, ct2)
   i3 = where(objs1.flux_clip_rchi2[2] GE 1.2 $
    AND objs1.flux_clip_rchi2[2] LT 1.3, ct3)
   i4 = where(objs1.flux_clip_rchi2[2] GE 1.3 $
    AND objs1.flux_clip_rchi2[2] LT 1.4, ct4)
   i5 = where(objs1.flux_clip_rchi2[2] GE 1.4 $
    AND objs1.flux_clip_rchi2[2] LT 1.5, ct5)
   i6 = where(objs1.flux_clip_rchi2[2] GE 1.5 $
    AND objs1.flux_clip_rchi2[2] LT 1.6, ct6)
   i7 = where(objs1.flux_clip_rchi2[2] GE 1.6, ct7)
   if keyword_set(fast) then begin
      if (ct1 GT 0) then objs_out.l_everything_array[0] = $
        likelihood_vector_fast(objs_in, objs1[i1], area1, recompile=recompile)
      if (ct2 GT 0) then objs_out.l_everything_array[1] = $
        likelihood_vector_fast(objs_in, objs1[i2], area1, recompile=recompile)
      if (ct3 GT 0) then objs_out.l_everything_array[2] = $
        likelihood_vector_fast(objs_in, objs1[i3], area1, recompile=recompile)
      if (ct4 GT 0) then objs_out.l_everything_array[3] = $
        likelihood_vector_fast(objs_in, objs1[i4], area1, recompile=recompile)
      if (ct5 GT 0) then objs_out.l_everything_array[4] = $
        likelihood_vector_fast(objs_in, objs1[i5], area1, recompile=recompile)
      if (ct6 GT 0) then objs_out.l_everything_array[5] = $
        likelihood_vector_fast(objs_in, objs1[i6], area1, recompile=recompile)
      if (ct7 GT 0) then objs_out.l_everything_array[6] = $
        likelihood_vector_fast(objs_in, objs1[i7], area1, recompile=recompile)
   endif else begin
      if (ct1 GT 0) then objs_out.l_everything_array[0] = $
       likelihood_vector(objs_in, objs1[i1], area1)
      if (ct2 GT 0) then objs_out.l_everything_array[1] = $
       likelihood_vector(objs_in, objs1[i2], area1)
      if (ct3 GT 0) then objs_out.l_everything_array[2] = $
       likelihood_vector(objs_in, objs1[i3], area1)
      if (ct4 GT 0) then objs_out.l_everything_array[3] = $
       likelihood_vector(objs_in, objs1[i4], area1)
      if (ct5 GT 0) then objs_out.l_everything_array[4] = $
       likelihood_vector(objs_in, objs1[i5], area1)
      if (ct6 GT 0) then objs_out.l_everything_array[5] = $
       likelihood_vector(objs_in, objs1[i6], area1)
      if (ct7 GT 0) then objs_out.l_everything_array[6] = $
       likelihood_vector(objs_in, objs1[i7], area1)
   endelse
   objs_out.l_everything = total(objs_out.l_everything_array, 1)
   for ibin=0, nzbin-1 do begin
      indx = where(objs2.z GE zmin[ibin] AND objs2.z LT zmax[ibin], ct)
      splog, 'Computing QSO likelihoods z=', zmin[ibin], zmax[ibin], ct
	  if keyword_set(fast) then begin
		  objs_out.l_qso_z[ibin] = $
			  likelihood_vector_fast(objs_in, objs2[indx], area2)
	  endif else begin
		  objs_out.l_qso_z[ibin] = $
			  likelihood_vector(objs_in, objs2[indx], area2)
	  endelse
   endfor
   objs_out.l_qso_boss = total(objs_out.l_qso_z[isum], 1)
   eps = 1e-30
   objs_out.l_ratio = (objs_out.l_qso_boss + eps) $
    / (objs_out.l_everything + eps)

	print,'Overall time: ',(systime(1)-t0)/60.,' minutes', $
		f='(a,f0.2,a)'
   return
end
;------------------------------------------------------------------------------
