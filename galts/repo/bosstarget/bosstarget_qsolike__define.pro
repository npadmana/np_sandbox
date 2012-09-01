function bosstarget_qsolike::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsolike::typename
	pars = self->pars()
	vers = pars.likelihood_version
	case vers of
		'v1': type = 'like'
		'v2': type = 'like2'
		else: message,'Bad likelihood version: '+string(vers)
	endcase
	return, type
end

function bosstarget_qsolike::process, objs, pars=pars, _extra=_extra

	nobjs = n_elements(objs)
	if  nobjs eq 0 then begin
		message,'Usage: like_struct=bl->process(objs, pars=pars, _extra=_extra)'
	endif

	; inherited from bosstarget_qsopars
	self->copy_extra_pars, pars=pars, _extra=_extra
	pars = self->pars()



	pars=self->pars()

	nobjs=n_elements(objs)


	type = self->typename()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)
	qsocache->match, type, self, objs, mobjs, mcache, cache=cache

	if mobjs[0] eq -1 then begin
		message,'Found no matches!!!'
	endif

	nmobjs=n_elements(mobjs)
	if n_elements(mobjs) ne nobjs then begin
		splog,'Some objects did not match the cached file!'
		splog,'    ',n_elements(mobjs),'/',n_elements(ind),form='(a,i0,a,i0)'
		message,'Halting'
	endif

	splog,'Found ',nmobjs,' likelihood matches',form='(a,i0,a)'


	like_struct = self->struct(nobjs)

	if pars.likelihood_version eq 'v1' then begin
		like_struct[mobjs].like_ratio_old = cache[mcache].l_ratio

		tcache = cache[mcache]
		tobjs = objs[mobjs]

		splog,'  - calculating straight like_ratio'
		like_struct[mobjs].like_ratio = $
			self->calculate_like_ratio(tcache)
		splog,'  - calculating mclike_ratio'
		like_struct[mobjs].like_ratio_pat = $
			self->calculate_mcvalue_rmag_like_ratio(tcache,tobjs)
	endif else begin
		like_struct[mobjs].like_ratio_old = -9999
		like_struct[mobjs].like_ratio = cache[mcache].l_ratio
	endelse


	return, like_struct

end



function bosstarget_qsolike::struct, count
	like_struct = {$
		like_ratio:-9999., $
		like_ratio_old: -9999., $
		like_ratio_pat:-9999., $
		like_qval:-9999. $
	}
	if n_elements(count) ne 0 then begin
		like_struct = replicate(like_struct, count)
	endif
	return, like_struct
end


function bosstarget_qsolike::add_like_ratio, like_struct
    pars=self->pars()
    n = create_struct(like_struct[0], 'like_ratio', -9999.0)
    like_struct_new = replicate(n, n_elements(like_struct))
    struct_assign, like_struct, like_struct_new, /nozero

	if pars.likelihood_version eq 'v1' then begin
		like_struct_new.like_ratio = self->calculate_like_ratio(like_struct)
	endif else begin
		like_struct_new.like_ratio = like_struct.l_ratio
	endelse

    return, like_struct_new
end


function bosstarget_qsolike::run, objs, recompile=recompile


	pars = self->pars()
	nobj=n_elements(objs)

	sendstruct = self->create_input(objs)
	
	; in $BOSSTARGET_DIR/pro/qso-like/
	vers = pars.likelihood_version
	case vers of
		'v1': begin
			likelihood_compute, sendstruct, outstruct, $
				/fast, recompile=recompile
		end
		'v2':  begin
			likelihood_compute_v2, sendstruct, outstruct, $
				/fast, recompile=recompile
		end
		else: message,'Bad likelihood version: '+string(vers)
	endcase

	outst=create_struct({run:0L,rerun:'',camcol:0,field:0,id:0L},outstruct[0])
	outst=replicate(outst, nobj)

	struct_assign, objs, outst, /nozero
	struct_assign, outstruct, outst, /nozero

    return, outst

end


pro bosstarget_qsolike::cache_generate, objs, recompile=recompile


	pars = self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)

	tm1=systime(1)

	nobj=n_elements(objs)
	run=objs[0].run
	rerun=objs[0].rerun
	camcol=objs[0].camcol

	type = self->typename()
	file=qsocache->file(type,run, rerun, camcol)

	splog,'Will write to file: ',file,form='(a,a)'

    outst = self->run(objs, recompile=recompile)

	qsocache->write, type, outst, run, rerun, camcol

	tm2=systime(1)
	splog,'Total execution time: ',(tm2-tm1)/60.,' minutes', $
		format='(a,g0.2,a)'

end

function bosstarget_qsolike::create_input, objs
	bu=obj_new('bosstarget_util')

	nobj=n_elements(objs)
	st = {flux:fltarr(5), flux_ivar:fltarr(5)}
	sendstruct = replicate(st, nobj)

	flux=bu->deredden(objs.psfflux, objs.extinction)
	flux_ivar=bu->deredden_error(objs.psfflux_ivar, objs.extinction)
	sendstruct.flux = flux
	sendstruct.flux_ivar = flux_ivar

	obj_destroy, bu

	return, sendstruct
end

pro bosstarget_qsolike::cache_combine
	; combine all the caches for likelihood

	pars = self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)

	type = self->typename()

	front=qsocache->frontname(type)

	dir=qsocache->dir()
	pattern = filepath(root=dir,front+'-*-*-*.fits')
	print,pattern
	files=file_search(pattern)
	


	extension=1
	sdef = {$
		run:0,rerun:0,camcol:0,field:0,id:0L, $
		like_ratio:0.0, like_ratio_old:0.0}

	nfiles=n_elements(files)
    print
	print,'Reading headers'

	ntotal = 0LL
	numlist = lonarr(nfiles)
	for i=0l, nfiles-1 do begin 

		hdr = headfits(files[i], ext=extension)
		numlist[i] = sxpar(hdr,'naxis2')
		ntotal = ntotal + numlist[i]

	endfor 

    print
	print,'Total number of rows: ',ntotal,f='(a,i0)'

	struct = replicate(sdef, ntotal)

	beg =0L
	for i=0l, nfiles-1 do begin 

		if numlist[i] ne 0 then begin 
			print,'Reading File: ',files[i],form='(a,a)'
			t = mrdfits(files[i], extension)

			if n_tags(t) ne 0 then begin


				tstruct = struct[beg:beg+numlist[i]-1]
				struct_assign, t, tstruct, /nozero
				tstruct.run=t.run
				tstruct.rerun=fix(t.rerun)
				tstruct.camcol=t.camcol
				tstruct.field=t.field
				tstruct.id=t.id

				tstruct.like_ratio_old = t.l_ratio
				tstruct.like_ratio = self->calculate_like_ratio(t)
				if i eq 0 then begin
					help,tstruct,/str
				endif
				struct[beg:beg+numlist[i]-1] = temporary(tstruct)

				beg = beg+numlist[i]

			endif else begin
				message,'Error reading file: ',files[i],/inf
				message,'Data is not a structure',/inf
			endelse

			t = 0

		endif else begin  
			print,'File is empty: ',files[i],form='(a,a)'
		endelse 
	endfor 


	qsocache->write, 'like', struct, /combined
end





function bosstarget_qsolike::calculate_like_ratio, str

	lratio = replicate(-9999.0, n_elements(str))

	w=where( str.l_qso_boss gt 1d-9, nw)

	eps = 1d-30
	if nw gt 0 then begin
		; qso likelihood for z > 2.2
		num = total(str[w].l_qso_z[2:18],1,/double)
		; relative to everything plus quasara over all z
		denom = $
			total(str[w].l_everything_array[0:4],1,/double)  +  $
			total(str[w].l_qso_z[0:18],1,/double) 

		lratio[w] = num/(denom+eps)
	endif

	return, lratio
end



function bosstarget_qsolike::calculate_mcvalue_rmag_like_ratio, str, objs

	; in z these line up exactly with the outputs from likelihood
	mcstruct = self->read_mcvalue_rmag()

	mclike_ratio = replicate(-9999.0, n_elements(str))

	
	; interpolate into the mag array.  NOT dereddened

	rmag = 22.5-2.5*alog10(objs.psfflux[2] > 0.001)

	minmag = min(mcstruct[0].rmag, max=maxmag)
	w=where( $
		str.l_qso_boss gt 1d-9 $
		and rmag gt minmag $
		and rmag lt maxmag, nw)


	if nw ne 0 then begin

		nmag = n_elements(mcstruct[0].rmag)
		ind = findgen(nmag)
		rmag_indices = $
			nint(interpol( ind, mcstruct[0].rmag, rmag[w] ))

		; last check to make sure in bounds
		rmag_indices = rmag_indices > 0 < (nmag-1)

		eps = 1d-30
		for i=0L, nw-1 do begin
			wi = w[i]

			; note subscript with i
			rmagi = rmag_indices[i]
			
			; pick out all z values for the right magnitude value
			vals = mcstruct.value[rmagi]

			; now sum over z > 2.2
			num = total(str[wi].l_qso_z[2:18]*vals[2:18], /double)

			; note denominator is the same as for ordinary likelihood
			; ratio.  A sum over all z
			denom = $
				total(str[wi].l_everything_array[0:4],/double) + $
				total(str[wi].l_qso_z[0:18],/double)

			mclike_ratio[wi] = num/(denom + eps)
		endfor

	endif

	return, mclike_ratio

end

function bosstarget_qsolike::read_mcvalue_rmag

	dir=getenv('BOSSTARGET_DIR')


	f=filepath(root=dir,sub='data','mcvalue-r.txt')
	nlines=file_lines(f)
	st=replicate({z:0d, rmag:0d, value:0d}, nlines)

	openr, lun, f, /get_lun
	readf, lun, st
	free_lun, lun

	; place magnitudes on a grid

	; the number of magnitudes given at each z
	nmag = 50

	min_rmag = min(st.rmag)
	max_rmag = max(st.rmag)

	; just define nmag evenly spaced from min to max
	new_rmag = findgen(nmag)*(max_rmag-min_rmag)/(nmag-1.0) + min_rmag

	nz = nlines/nmag

	newst = {z:0.0, rmag:fltarr(nmag), value:fltarr(nmag)}
	newst = replicate(newst,nz)

	beg=0
	for i=0L, nz-1 do begin
		newst[i].z = st[beg].z

		tmpst = st[beg:beg+nmag-1]

		newst[i].rmag = new_rmag
		; interpolate, make sure doesn't run under zero
		newst[i].value = interpol(tmpst.value, tmpst.rmag, new_rmag) > 0
		beg = beg + nmag
	endfor

	; pick the ones that correspond to the likelihood outputs
	w=where(indgen(39) mod 2)
	newst = newst[w]

	return, newst

end




; this is not used
function bosstarget_qsolike::likelihood_pats_probsarray
; read in Pat Mcdonald's probability file return array in a format
; such that for a given g value we have an array of probabilities
; corresponding to zmin and zmax for the likelihood method
;		Adam D. Myers, UIUC

	dir=filepath(root=getenv("BOSSTARGET_DIR"), "data")
        	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	qvfile = filepath(root=dir, "quasarvalue.txt")

;check some values of the quasarvalue file to see if it's in an appropriate format
	readcol, qvfile, zval, gval, Pval, format='d,d,d'
	if min(zval) gt 2.0 then message, 'quasar value file format wrong'
	if max(zval) lt 4.0 then message, 'quasar value file format wrong'
	if min(gval) gt 18.1 then message, 'quasar value file format wrong'
	if max(gval) lt 23.0 then message, 'quasar value file format wrong'
	if n_elements(gval) ne 2050 then message, 'quasar value file format wrong'
       
; The likelihood file contains an array with the first bin from 2.0 to 2.1 and the final bin
; from 3.8 to 3.9. We make the following function to only select bins at 2.05, 2.15, 2.25, etc.
	binselect = where(indgen(38) mod 2 )
	zarr = zval[where(gval gt 18.09 and gval lt 18.11)]
	print, 'likelihood bins for value weights are assumed to be', zarr[binselect]

; Now build an array such that element 0 contains the Prob values for the entire z range
; from 2.05 to 3.85 for magnitude g=18.1, element 1 is the same for g=18.2 etc.
	probarr = dblarr(19,50)
	for i = 0, 49 do begin	
		maglo = (i*0.1)+18.09
		maghi = (i*0.1)+18.11
		parr = pval[where(gval gt maglo and gval lt maghi)]
		probarr[*,i] = parr[binselect]
	endfor	

	return, probarr

end
	

function bosstarget_qsolike::likelihood_match, objs, $
		bitmask=bitmask, $
		like_struct=like_struct

	if n_elements(objs) eq 0 then begin
		on_error, 2
		splog,'Usage: boss_target1=bq->likelihood_match(objs, bitmask=,  like_struct=)'
		message,'Halting'
	endif

	common likelihood_block, likelihood, current_version
	self->likelihood_cache

	nobj=n_elements(objs)
	boss_target1=lon64arr(nobj)

	like_struct = replicate({like_id:-9999L, like_ratio:-9999.},  nobj)

	matchrad = 1d/3600d ; degrees

	spherematch, $
		objs.ra, objs.dec, likelihood.ra, likelihood.dec, matchrad, $
		objs_match, likelihood_match, distances,$
		maxmatch=1

	likelihood_flag = sdss_flagval('boss_target1','qso_like')
	nmatch=0
	nkeep=0
	if objs_match[0] ne -1 then begin
		nmatch=n_elements(objs_match)	
		like_struct[objs_match].like_id = likelihood_match
		like_struct[objs_match].like_ratio = $
			likelihood[likelihood_match].l_ratio

		if n_elements(bitmask) eq 0 then begin
			nkeep=nmatch
			boss_target1[objs_match] += likelihood_flag
		endif else begin
			;; only flag matches that also have a clear bitmask
			keep=where(bitmask[objs_match] eq 0, nkeep)
			if nkeep ne 0 then begin
				keep = objs_match[keep]
				boss_target1[keep] += likelihood_flag
			endif
		endelse

	endif

	print
	splog,'Found ',nmatch,' likelihood matches',format='(a,i0,a)'
	splog,'Found ',nkeep,' good likelihood matches',format='(a,i0,a)'
	print

	return, boss_target1

end





pro bosstarget_qsolike__define
	struct = {$
		bosstarget_qsolike, $
		inherits bosstarget_qsopars $
	}
end


