function bosstarget_qsoknown::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end


pro bosstarget_qsoknown::match, $
		objs, flag_bitmask, $
		matchflags, target_flags, known_matchids, $
		pars=pars, _extra=_extra

	; flag_bitmask is/are inputs so call this after
	; flag_logic

	if n_elements(objs) eq 0 or n_elements(flag_bitmask) eq 0 then begin
		message,'usage: bq->known_qso_match_wrapper, objs, flag_bitmask, matchflags, target_flags'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	target_flags = lon64arr(n_elements(objs))

	pars = self->pars()

	nobjs = n_elements(objs)

	; run an initial match at 1.5".  Then run again at 2" on those that did
	; not match, keeping only if the magnitude difference is less than 0.5

	splog,'Matching all at ',pars.known_matchrad1,'"',format='(a,f0.2,a)'
	maxrad = pars.known_matchrad1/3600d
	self->do_match, objs.ra, objs.dec, maxrad, $
		matchflags, known_matchids

	wmatch = where(matchflags gt 0, nmatch)

	splog,'Found ',nmatch,' matches',format='(a,i0,a)'
	if nmatch eq nobjs then return


	index_rematch = lindgen(nobjs)
	if nmatch ne 0 then begin
		remove, wmatch, index_rematch
	endif

	; now rematch again at 2" demanding mag difference less than 0.5

	splog,'Matching leftovers at ',pars.known_matchrad2,'" and magdiff ',$
		pars.known_max_magdiff,format='(a,f0.2,a,f0.2)'
	tra=objs[index_rematch].ra
	tdec = objs[index_rematch].dec

	maxrad = pars.known_matchrad2/3600d
	gflux = objs[index_rematch].psfflux[1]
	bu=obj_new('bosstarget_util')
	gmag = bu->flux2mags( gflux, 0.9 ) - objs[index_rematch].extinction[1] 
	gmag = reform(gmag)
	self->do_match, tra, tdec, maxrad, $
		matchflags2, known_matchids2, $
		gmag = gmag, max_magdiff=pars.known_max_magdiff

	wmatch2 = where(matchflags2 gt 0, nmatch2)
	splog,'Found ',nmatch2,' more matches',format='(a,i0,a)'

	matchflags[index_rematch] = matchflags2
	known_matchids[index_rematch] = known_matchids2

	known_midz=sdss_flagval('boss_target1','qso_known_midz')
	known_lohiz=sdss_flagval('boss_target1','qso_known_lohiz')
	known_suppz=sdss_flagval('boss_target1','qso_known_suppz')

	wmid = where( $
	 (matchflags and known_midz) ne 0, nmid)
	wlohi = where( $
	 (matchflags and known_lohiz) ne 0, nlohi)
	wsupp = where( $
	 (matchflags and known_suppz) ne 0, nsupp)

	splog,'Found ',nmid,' matches ',pars.known_zlo,' < z < ',pars.known_zhi,$
		format='(a,i0,a,f0.2,a,f0.2)'
	splog,'Found ',nlohi,' matches z < ',pars.known_zlo,' or z > ',pars.known_zhi,$
		format='(a,i0,a,f0.2,a,f0.2)'
	splog,'Found ',nsupp,' supp matches z < ',pars.known_zsupp,' or z > ',pars.known_zlo,$
		format='(a,i0,a,f0.2,a,f0.2)'

	; now set the target flags.  This is a bit more complicated
	;
	; known mid-z objects we be targeted ifalso also pass the
	; bounds cuts and resolve cuts
	
	wmid = where( $
		flag_bitmask eq 0 $
		and (matchflags and known_midz) ne 0, nmid)
	if nmid ne 0 then begin
		target_flags[wmid] += known_midz
	endif

        ;ADM also target the "supplemental" known quasars (that get fibers
        ;ADM on the second fiber pass) just the same as mid-z quasars

	wsupp = where( $
		flag_bitmask eq 0 $
		and ((matchflags and known_suppz) ne 0), nsupp2)
	if nsupp2 ne 0 then begin
        splog,'kept ',nsupp2,'/',nsupp,' supp', format='(a,i0,a,i0,a)'
		target_flags[wsupp] += known_suppz
	endif else begin
        if nsupp ne nsupp2 then begin
            splog,'lost all ',nsupp,'/',nsupp,' supp to bitmask',$
                format='(a,i0,a,i0,a)'
        endif
    endelse

	; these are things will will definitely not target, independent of their
	; properties
	wlohi = where( (matchflags and known_lohiz) ne 0, nlohi)
	if nlohi ne 0 then begin
		target_flags[wlohi] += known_lohiz
	endif

end


pro bosstarget_qsoknown::do_match, ra, dec, maxrad, $
		matchflags, known_matchids,  $
		gmag=gmag, max_magdiff=max_magdiff

	if n_params() lt 3 then begin
		on_error, 2
		message,'bq->known_qso_match, ra, dec, maxrad, matchflags, known_matchids, gmag=, max_magdiff='
	endif

	; Gordon's notes:
	;
	; Objects that *don't* pass our selection, but that are on this list and
	; have 2.15<z<9.9 should be included anyway.
	;
	; We can probably go to 2.0" if we also require that the mags match to
	; withing 0.5 (I've given the g mag in the table).  Without a mag test,
	; maybe 1 or 1.5 would be better.
	;
	; so we set 2^0 if match z< 2.15 or z > 9.9 quasar
	;       set 2^1 if match 2.15 < z < 9.9


	common bosstarget_qso_knownqso_block, knownqso

	pars = self->pars()

	if n_elements(knownqso) eq 0 then begin
		knownqso = self->read()
	endif

	ngmag = n_elements(gmag)
	if ngmag ne 0 then begin
		if n_elements(max_magdiff) ne 1 then begin
			message,'max_magdiff must be entered as a scalar with gmag'
		endif
	endif

	n=n_elements(ra)
	if n ne n_elements(dec) then begin
		message,'ra/dec must be same length'
	endif

	matchflags = lon64arr(n)
	known_matchids = replicate(-9999L, n)

	; put ra,dec first since spherematch sometimes blows up if it has to 
	; tile the poles
	spherematch, $
		ra, dec, knownqso.ra, knownqso.dec, maxrad, $
		imatch, iknown_matchids, matchrad,$
		maxmatch=1

	if imatch[0] eq -1 then begin
		return
	endif

	if ngmag ne 0 then begin
		; only keep matches for which magdiff less than specified
		magdiff = abs( knownqso[iknown_matchids].gmag - gmag[imatch]) 

		wkeep = where( magdiff lt max_magdiff, nkeep)
		if nkeep eq 0 then begin
			return
		endif

		imatch = imatch[wkeep]
		iknown_matchids = iknown_matchids[wkeep]
	endif

	wmid = where( $
		knownqso[iknown_matchids].zem gt pars.known_zlo $
		and knownqso[iknown_matchids].zem lt pars.known_zhi, nmid, $
		complement=wlohi, ncomp=nlohi)

        ;ADM also match supplemental "repeats" to a lower redshift bin
        ;ADM these are things to be targeted on the second sweep
        ;ADM once all fibers are initally placed on the first sweep
	wsupp = where( $
		knownqso[iknown_matchids].zem gt pars.known_zsupp $
		and knownqso[iknown_matchids].zem lt pars.known_zlo, nsupp)

	if nmid ne 0 then begin
		matchflags[imatch[wmid]] += $
			sdss_flagval('boss_target1','qso_known_midz')
	endif
	if nlohi ne 0 then begin
		matchflags[imatch[wlohi]] += $
			sdss_flagval('boss_target1','qso_known_lohiz')
	endif
	if nsupp ne 0 then begin
		matchflags[imatch[wsupp]] += $
			sdss_flagval('boss_target1','qso_known_suppz')
	endif

	known_matchids[imatch] = iknown_matchids

end





function bosstarget_qsoknown::file, dat=dat
	dir=filepath(root=getenv("BOSSTARGET_DIR"), "data")

	; same for now
	;file = filepath(root=dir, "knownquasars.100209")
	file = filepath(root=dir, 'knownquasarstar.060910')

	if keyword_set(dat) then begin
		file=file+'.dat'
	endif else begin
		file=file+'.fits'
	endelse
	return, file
end

function bosstarget_qsoknown::read, dat=dat

	file=self->file(dat=dat)
	splog,'Reading known qsos:',file
	if not keyword_set(dat) then begin
		knownqso = mrdfits(file,1,status=status)
		if status ne 0 then message,"Could not read knowqso file: "+file
	endif else begin
		readcol, file, name, ra, dec, zem, gmag, source, $
			format='a,d,d,d,d,a', skip=1
		stdef={name:'', ra:0d, dec:0d, zem:0d, gmag:0d, source:''}
		knownqso=replicate(stdef, n_elements(ra))
		knownqso.name=name
		knownqso.ra=ra
		knownqso.dec=dec
		knownqso.zem=zem
		knownqso.gmag=gmag
		knownqso.source=source
	endelse
	return, knownqso
end

pro bosstarget_qsoknown::convert2fits
	st=self->read(/dat)
	outfile=self->file()
	splog,'Writing out fits version: ',outfile
	mwrfits, st, outfile, /create
end


pro bosstarget_qsoknown__define
	struct = {$
		bosstarget_qsoknown, $
		inherits bosstarget_qsopars $
	}
end


