function bosstarget_qsofirst::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end



function bosstarget_qsofirst::match, objs, bitmask=bitmask,firstradio_struct=firstradio_struct, $
		pars=pars, _extra=_extra

	;29-Sept-2009: 
	;	Match target photometry against the FIRST radio survey and include any matches
	;	that pass our basic target cuts as passed in bitmask
	;	Match at 1" (SDSS used 2" but see http://arxiv.org/abs/0909.4091 and 
	;	sdss3-qsos thread at message 494)
	;	Adam D. Myers, UIUC


	if n_elements(objs) eq 0 then begin
		on_error, 2
		splog,'Usage: boss_target1=bf->match(objs, bitmask=, firstradio_struct=)'
		message,'Halting'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	common firstradio_block, firstradio
	self->do_cache

	nobj=n_elements(objs)
	boss_target1=lon64arr(nobj)
	firstradio_struct = replicate({firstradio_id:-9999L, firstradio_dist:-9999.9},  nobj)

	matchrad = 1d/3600d ; degrees

	spherematch, $
		objs.ra, objs.dec, firstradio.ra, firstradio.dec, matchrad, $
		objs_match, firstradio_match, distances,$
		maxmatch=1

	fr_flag = sdss_flagval('boss_target1','qso_first_boss')
	nmatch=0
	nkeep=0
	if objs_match[0] ne -1 then begin
		nmatch=n_elements(objs_match)	
		firstradio_struct[objs_match].firstradio_id = firstradio_match
		firstradio_struct[objs_match].firstradio_dist = distances*3600
		if n_elements(bitmask) eq 0 then begin
			nkeep=nmatch
			boss_target1[objs_match] += fr_flag
		endif else begin
			;; only flag matches that also have a clear bitmask
			keep=where(bitmask[objs_match] eq 0, nkeep)
			if nkeep ne 0 then begin
				keep = objs_match[keep]
				boss_target1[keep] += fr_flag
			endif
		endelse

	endif

	print
	splog,'Found ',nmatch,' FIRST matches',format='(a,i0,a)'
	splog,'Found ',nkeep,' good FIRST matches',format='(a,i0,a)'
	print

	return, boss_target1
end




function bosstarget_qsofirst::file

	;29-Sept-2009: 
	;	Obtain name of FIRST radio survey file for matches
	;	Adam D. Myers, UIUC

	dir=filepath(root=getenv("BOSSTARGET_DIR"), "data")
	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	file = filepath(root=dir, "first_08jul16.fits")
	return, file
end


pro bosstarget_qsofirst::do_cache

	common firstradio_block, firstradio

	if n_elements(firstradio) eq 0 then begin
		file=self->file()
		splog,'Reading file: ',file,form='(a,a)'
		firstradio=mrdfits(file,1)
		if n_tags(firstradio) eq 0 then begin
			message,string('Could not read file: ',file,f='(a,a)')
		endif
	endif

end






pro bosstarget_qsofirst__define
	struct = {$
		bosstarget_qsofirst, $
		inherits bosstarget_qsopars $
	}
end


