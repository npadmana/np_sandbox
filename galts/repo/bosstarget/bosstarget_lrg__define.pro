function bosstarget_lrg::init, pars=pars, _extra=_extra
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end


;docstart::bosstarget_lrg::select
; NAME:
;	bosstarget_lrg::select
; PURPOSE:
;   Version 0.00001 of the galaxy selection algorithm for BOSS
; CALLING SEQUENCE:
;	ql = obj_new('bosstarget_lrg')
;   ilist=ql->boss_galaxy_select(obj, pars=, _extra=)
; INPUTS:
;   obj   : A calibObj structure
;   
; OUTPUTS:
;	A structure with the .boss_target1 flags and a large set of other
;	parameters.  See the ::struct method for the tag list.
;
; OPTIONAL INPUTS:
;	Any of the parameters defined in the .pars sub-structure can be set
;	by sending the pars= structure as an argument to the ::select method
;	or as an argument during construction (bl=obj_new('bosstarget_lrg',pars=)
;
;	Also any keywords sent during construcion or to the ::select method
;	will get copied in over the default pars.  pars= takes precedence over
;	keywords.  
;   
; REVISION HISTORY:
;	Written by Nikhil Padmanabhan, LBL
;	13-Jan-2009: Moved to class file, formatting.  Erin Sheldon, BNL
;   late Jan, 2009: made more modular, use final flag names and values
;   2009-03-23:  Many more tests added.  Now require that the boss_target1
;		bits be defined in the sdss maskbigs file.  Tycho masking 
;		incorporated into main selection code but currently only sets a 
;		flag.  Finalized the flag, rdev cuts.
;						Erin Sheldon, BNL
;	04-June-2009: Added extra_logic= keyword, a string that can be used
;		to generate new logic.  e.g. 'str.ra gt 100' or something.  
;			Erin Sheldon, BNL
;	2009-06-10:  
;		* Added /commissioning flag and a first try at altered
;			parameters.  
;       * Made concentration cut the default, user now has to
;			send conc=0 to force objc_type.
;	2009-07*
;		Dozens of major changes, not documented here unfortunately.
;	2009-12* Finalized algorithm.
;	Most keywords now absorbed into pars= keyword structure.
;		2010-01-12, Erin Sheldon, BNL
;   Use a sub-structure for pars instead of a pointer.  This avoids
;		possible memory leaks if obj_destroy is not called.
;			2010-01-25 Erin Sheldon, BNL
;   Added ifiber2 > 21.5 flagging.
;docend::bosstarget_lrg::select


function bosstarget_lrg::select, calibobj, $
		extra_logic=extra_logic, $
		pars=pars, $
		_extra=_extra

	if n_elements(calibobj) eq 0 then begin
		splog,"usage:"
		splog,"  btl=obj_new('bosstarget_lrg')"
		splog,"  t=btl->select(calibobj, extra_logic=, pars=)"
		on_error, 2
		message,'Halting'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	nobj=n_elements(calibobj)
	boss_target1 = lon64arr(nobj)


	mst = self->derived_struct(calibobj)

	flag_logic = self->flag_logic(calibobj, mst)

	if n_elements(extra_logic) ne 0 then begin
		tmp_logic = self->extra_logic(calibobj, extra_logic)
		flag_logic = flag_logic and tmp_logic
	endif

	boss_target1[*] += self->known_gals_match(calibobj, known_id=known_id)


	tycho_unmasked = self->tycho_mask(calibobj.ra, calibobj.dec, $
									  comp=tycho_masked)
	tycho_logic=lon64arr(nobj)
	tycho_logic[tycho_unmasked] = 1


	qsostar_matchid = self->known_qso_star_match(calibobj)
	qsostar_notmatched = replicate(1,n_elements(calibobj))
	if qsostar_matchid[0] ne -1 then begin
		qsostar_notmatched[qsostar_matchid] = 0
	endif


	; tycho now required, as well as no match to qso/star
	logic = flag_logic and tycho_logic and qsostar_notmatched

	;------- Define the various cuts
	cuttypes = $
		['gal_loz','gal_cmass','gal_cmass_comm',$
		 'gal_cmass_sparse','gal_cmass_all']
	ncuttypes = n_elements(cuttypes)	
	for ii = 0, ncuttypes-1L do begin
		splog,'Finding "'+cuttypes[ii]+'" targets'
		; all previous logic is anded with target logic
		logic1 = self->target_logic(mst, cuttypes[ii], input_logic=logic)
		boss_target1[*] += logic1*sdss_flagval('boss_target1', cuttypes[ii])
	endfor
	
    ; add new check brighter than ihi_fib2.
    boss_target1[*] += self->ifiber2_faint_flag(mst)

	self->print_pars

	st = self->struct(count=n_elements(calibobj))
	struct_assign, calibobj, st, /nozero
	struct_assign, mst, st, /nozero
    st.cmodelmag_dered = mst.cmodelmag

	if tycho_masked[0] ne -1 then begin
		st[tycho_masked].tychoflags = 1
	endif
	st.logic = logic
	st.known_id = known_id
	st.boss_target1 = boss_target1
	return, st

end


; Need to add this new flag to sdss_maskbits and tag
function bosstarget_lrg::ifiber2_faint_flag, str
    boss_target1 = lon64arr(n_elements(str))
    pars = self->pars()
    w=where(str.fiber2mag[3] gt pars.ihi_fib2, nw)
    splog,'Found ',nw,' with ifiber2mag[3] > ',pars.ihi_fib2,$
        format='(a,i0,a,f0.2)'
    flag=sdss_flagval('boss_target1','gal_ifiber2_faint')
    if nw gt 0 then begin
        splog,'Adding bit gal_ifiber2_faint: ',flag
        boss_target1[w] += flag
    endif
    return, boss_target1
end


pro bosstarget_lrg::copy_extra_pars, pars=pars, _extra=_extra

	if n_tags(_extra) ne 0 then begin
		tmp = self.pars
		struct_assign, _extra, tmp, /nozero
		self.pars = tmp
	endif
	if n_tags(pars) ne 0 then begin
		tmp=self.pars
		struct_assign, pars, tmp, /nozero
		self.pars=tmp
	endif

	if self.pars.commissioning then begin
		splog,'Using commissioning parameters'
		self.pars.slide_line[1] = 1.60   ; cmass slope for commissioning
		self.pars.ihi_hiz       = 20.0   ; hiz faint limit commissioning
		;pars.ihi_hiz       = 20.14   ; hiz faint limit commissioning
		self.pars.rmaglim = [13.4d0, 0.0d0, 19.5d0] ; What was used for commissioning 
		self.pars.ihi_cmass     = 20.14  ; cmass faint limit commissioning
		self.pars.ihi_fib = 22.0 ; This was used in commissioning, also boss3-boss6
	endif

end



pro bosstarget_lrg::print_pars
	pars=self->pars()
	tn=tag_names(pars)
	for i=0L, n_elements(tn)-1 do begin
		splog,tn[i],pars.(i),format='(a-35, a)'
	endfor
end



; these are no longer used
function bosstarget_lrg::tycho_flagval, type
	case strlowcase(type) of
		'tycho1': return, 2L^0
		'tycho2': return, 2L^1
		else: message,'Unknown type: '+string(type)
	endcase
end
function bosstarget_lrg::tycho_radfac, type
	case strlowcase(type) of
		'tycho1': return, 1.0
		'tycho2': return, 1.5
		else: message,'Unknown type: '+string(type)
	endcase
end


function bosstarget_lrg::colorflags_logic, flags, objflagtype, flagname, $
		notset=notset
	flagval = sdss_flagval(objflagtype, flagname)
	if not keyword_set(notset) then begin
		check = $
			(flags[0,*] and flagval) ne 0 $
			or (flags[1,*] and flagval) ne 0 $
			or (flags[2,*] and flagval) ne 0 $
			or (flags[3,*] and flagval) ne 0 $
			or (flags[4,*] and flagval) ne 0
	endif else begin
		; checking if it is not set instead if it is set
		check = $
			(flags[0,*] and flagval) eq 0 $
			or (flags[1,*] and flagval) eq 0 $
			or (flags[2,*] and flagval) eq 0 $
			or (flags[3,*] and flagval) eq 0 $
			or (flags[4,*] and flagval) eq 0
	endelse
	return, reform(check)
end


function bosstarget_lrg::flag_logic, calibobj, mst

	pars = self->pars()
        ; Deprecate complicated s/g separation here
	;case pars.conc of 
	;	1 : begin
	;		splog,'Using concentration in i > '+strn(pars.iconc_lim)
	;		type_logic = (mst.conc[3] gt pars.iconc_lim)
        ;              
	;	end
	;	2 : begin
	;		splog, 'Using a sliding S/G cut'
	;		type_logic = (mst.conc[3] gt (pars.iconci0 + pars.iconci1*(20.0-mst.modelmag[3])))
	;		type_logic = $
	;			type_logic and $
	;			(mst.conc[4] GT (pars.iconcz0+pars.iconcz1*mst.modelmag[4]))
	;	end
	;	else : begin
	;		type_logic = (calibobj.objc_type eq 3)
	;		splog,'Using objc_type == 3'
	;	end
	;endcase
        type_logic = (calibobj.objc_type EQ 3)

	; first the flags that must be set
;	primaryflag = sdss_flagval('resolve_status','survey_primary')

	binned1 = sdss_flagval('object1','binned1')
	binned2 = sdss_flagval('object1','binned2')
	binned4 = sdss_flagval('object1','binned4')

	r_binned_logic =  $
		(calibobj.flags[2] and binned1) ne 0 or $
		(calibobj.flags[2] and binned2) ne 0 or $
		(calibobj.flags[2] and binned4) ne 0

	i_binned_logic =  $
		(calibobj.flags[3] and binned1) ne 0 or $
		(calibobj.flags[3] and binned2) ne 0 or $
		(calibobj.flags[3] and binned4) ne 0

	calib_logic = self->colorflags_logic(calibobj.calib_status,$
		    'calib_status','photometric')
	logic = $
		type_logic and (r_binned_logic and i_binned_logic)

	if not pars.nocalib then begin
		splog,'Cutting to photometric'
		logic = logic and calib_logic
	endif else begin
		splog,'NOT cutting to photometric'
	endelse


	; flags that must not be set
	satur = sdss_flagval('object1','satur')
	satur_center = sdss_flagval('object2','satur_center')
	; I think !bright is already chosen by the primary cut above
	bright = sdss_flagval('object1','bright')
	too_many_peaks = sdss_flagval('object1','deblend_too_many_peaks')

	blended = sdss_flagval('object1','blended')
	nodeblend = sdss_flagval('object1','nodeblend')

	oflags = calibobj.objc_flags
	oflags2 = calibobj.objc_flags2

	s_logic = (oflags and satur)
	sc_logic = (oflags2 and satur_center)
	s_or_sc_logic = ( s_logic eq 0 or (s_logic ne 0 and sc_logic eq 0) )

	; famously worded as double negatives
	bdb_logic = $
		((oflags and blended) eq 0) or ((oflags and nodeblend) ne 0)

	logic = logic $
		and (oflags and bright) eq 0 $
		and (oflags and too_many_peaks) eq 0 $
		and bdb_logic


	; new stuff to try
	peakcenter = sdss_flagval('object1','peakcenter')
	notchecked = sdss_flagval('object1','notchecked')
	noprofile = sdss_flagval('object1','noprofile')

	logic = logic and $
		(oflags and peakcenter) eq 0 $
		and (oflags and notchecked) eq 0 $
		and (oflags and noprofile) eq 0


	; default is cut all saturated since 1/3 of those left over after
	; rdev and tycho cuts were poorly deblended and total was only 1%
	if not pars.nosatur then begin
		if pars.satcen then begin
			logic = logic and s_or_sc_logic 
		endif else begin
			logic = logic and (s_logic eq 0)
		endelse
	endif

	return, logic

end


function bosstarget_lrg::extra_logic, str, extra_logic
	command = 'logic = '+extra_logic
	splog,'getting extra logic with command = ',command,format='(a,a)'
	if not execute(command) then begin
		message,'Failed to execute extrta logic command: '+command
	endif

	return, logic
end


function bosstarget_lrg::hiz_sg_logic, mst

	; Handle s/g separation here
	loz_logic = self->target_logic(mst, 'gal_loz')
	pars = self->pars()

	; The original cut in i
	sg_logic1 = (mst.conc[3] gt (pars.iconci0 + pars.iconci1*(20.0-mst.modelmag[3])))
	; The extended cut in z
	sg_logic2 = (mst.conc[4] GT (pars.iconcz0+pars.iconcz1*mst.modelmag[4]))

	; Galaxies need to either pass the low-redshift cut, or both the S/G cuts
	return, ((sg_logic1 AND sg_logic2) OR loz_logic)

end

function bosstarget_lrg::target_logic, mst, select_type, $
		input_logic=input_logic

	if n_elements(input_logic) eq 0 then begin
		input_logic=replicate(1, n_elements(mst) )
	endif 

	logic = input_logic

	; cut bright in the fiber.  This must be satisfied for all targets

	lim = self->pars()

	logic = logic AND (mst.fiber2mag[3] LT lim.ihi_fib)

	case strlowcase(select_type) of
		'gal_loz': begin
			; Cut I
			logic = logic $
				AND ( mst.cmodelmag[2] LT $
					 (lim.rmaglim[0] + mst.cpllel/0.3d0) )
			logic = logic AND (abs(mst.cperp) LT lim.max_cperp)
			logic = logic AND (mst.cmodelmag[2] LT lim.rmaglim[2]) AND (mst.cmodelmag[2] GT lim.rmaglim[1])
			logic = logic AND (mst.conc[2] GT lim.rconc_lim)
		end
		'gal_hiz': begin
			logic = logic $
				AND (mst.cmodelmag[3] GT lim.ilow) 
			logic = logic AND $
				((mst.modelmag[2] - mst.modelmag[3]) LT lim.max_rmi)
			logic = logic AND (mst.dperp GT lim.dperp0)
			; default is cut on rdev now
			if not lim.nordev then begin
				logic = logic AND (mst.r_devi LT lim.r_devimax)
			endif
                        
			; star galaxy sep
			sglogic = self->hiz_sg_logic(mst)
			logic = logic AND sglogic
		end
		'gal_cmass': begin
			; New sliding cut
			;cmodelmag[3] LT (19.9 + 2.15*(dperp - 0.80))

			hiz_logic = self->target_logic(mst, 'gal_hiz')


			ihi = lim.ihi_cmass
			slope = lim.slide_line[1]
			dperp_offset = lim.slide_line[0]
                        logic = logic AND (mst.cmodelmag[3] LT lim.ihi_hiz)
			logic = logic $
			  and hiz_logic $
			  and (mst.cmodelmag[3] LT (ihi + slope*(mst.dperp-dperp_offset)))
		end
		'gal_cmass_comm': begin
			hiz_logic = self->target_logic(mst, 'gal_hiz')


			ihi = lim.ihi_cmass_comm
			slope = lim.slide_line[1]
			dperp_offset = lim.slide_line[0]
			logic = logic AND (mst.cmodelmag[3] LT lim.ihi_hiz_comm)
			logic = logic $
				and hiz_logic $
				and (mst.cmodelmag[3] LT (ihi + slope*(mst.dperp-dperp_offset)))
		end
		'gal_cmass_all': begin
			cmass_comm = self->target_logic(mst,'gal_cmass_comm')
			logic = logic AND (mst.cmodelmag[3] LT lim.ihi_hiz)
			logic = logic AND cmass_comm
		end
		'gal_cmass_sparse': begin
			cmass = self->target_logic(mst,'gal_cmass')
			cmass_comm = self->target_logic(mst,'gal_cmass_comm')
			logic = logic AND (mst.cmodelmag[3] LT lim.ihi_hiz)
			logic = logic AND (cmass_comm) AND (~cmass)

			ramod_logic = mst.ramod ge lim.ramod_thresh

			logic = logic and ramod_logic
		end

		else: begin
			on_error,2
			message,'Unknown select type: '+string(select_type)
		end
	endcase

	return, logic
end


function bosstarget_lrg::pars
	return, self.pars
end



function bosstarget_lrg::get_ramod, ra
	return, floor(ra*1000 MOD 100)
end
function bosstarget_lrg::ramod_select, ra, thresh, count=count
	 logic = self->ramod_logic(ra, thresh)
	 w=where(logic, count)
	 return, w
end
function bosstarget_lrg::ramod_logic, ra, thresh
	ramod = self->ramod(ra)
	return, ramod ge thresh
end



function bosstarget_lrg::dperp, modelmag1, modelmag2

	if n_params() lt 1 then begin
		splog,"usage: "
		splog,"  bl=obj_new('bosstarget_lrg')"
		splog,"  dperp = bl->dperp(gmr, rmi)"
		splog,"or"
		splog,"  dperp = bl->dperp(model_mags)"
		on_error, 2
		message,'Halting'
	endif

	if n_params() eq 1 then begin
		grcolor = modelmag1[1,*]-modelmag1[2,*]
		ricolor = modelmag1[2,*]-modelmag1[3,*]
		return, self->dperp(grcolor, ricolor)
	endif else begin
		dperp = modelmag2 - modelmag1/8.d0
		return, reform(dperp)
	endelse

end



function bosstarget_lrg::cpllel, modelmag

   grcolor = modelmag[1,*]-modelmag[2,*]
   ricolor = modelmag[2,*]-modelmag[3,*]
   c= 0.7
   cpllel = c*(grcolor) + (1.d0-c)*4.0d0*((ricolor) - 0.18)
   return, reform(cpllel)

end

function bosstarget_lrg::cperp, modelmag

   grcolor = modelmag[1,*]-modelmag[2,*]   
   ricolor = modelmag[2,*]-modelmag[3,*]
   cperp = (ricolor) - (grcolor/4.d0)-0.18
   return, reform(cperp)

end

function bosstarget_lrg::struct, count=count

	st = { $
		run: 0L, $
		rerun: '', $
		camcol: 0L, $
		field: 0L, $
		id: 0L, $
		ramod: 0, $
		calib_status: intarr(5), $
		resolve_status: 0L, $
		dperp:0.0, $
		cmodelmag_dered:fltarr(5), $
		tychoflags: 0b, $
		known_id: 0L, $ ; id of a good known sdss galaxy with a redshift
		logic: 0L, $
		boss_target1: 0LL}
	if n_elements(count) ne 0 then begin
		st = replicate(st, count)
	endif

	return, st
end



function bosstarget_lrg::derived_struct, calibobj
	st = { $
		modelmag:fltarr(5), $
		cmodelmag:fltarr(5), $
		fibermag:fltarr(5), $
                fiber2mag:fltarr(5), $
		psfmag:fltarr(5), $ 
		conc:fltarr(5), $
		;petrosb_r: 0.0, $
		cperp: 0.0, $
		cpllel: 0.0, $
		dperp: 0.0,  $
		r_devi: 0.0,  $
		ramod: 0 $
	}
	st = replicate(st, n_elements(calibobj))

	; Extract the relevant magnitudes
	; We really should have used cmodelmags, and will later.
	st.modelmag = 22.5 - 2.5*alog10(calibobj.modelflux > 0.001)
	st.cmodelmag = self->make_cmodelmag(calibobj)
	st.fibermag = 22.5 - 2.5*alog10(calibobj.fiberflux > 0.001)
	st.fiber2mag = 22.5 - 2.5*alog10(calibobj.fiber2flux > 0.001)
	st.psfmag = 22.5 - 2.5*alog10(calibobj.psfflux > 0.001)
	st.conc = st.psfmag - st.modelmag

	;petromag_r = 22.5 - 2.5*alog10(calibobj.petroflux[2,*] > 0.001)

	; Extinction correct
	st.modelmag = st.modelmag - calibobj.extinction
	st.cmodelmag = st.cmodelmag - calibobj.extinction
	st.fibermag = st.fibermag - calibobj.extinction
	st.fiber2mag = st.fiber2mag - calibobj.extinction
	;petromag_r = petromag_r - calibobj.extinction[2,*]

	; surface brightness, mags per square arcsec.  0.396 arcsec/pixel
	;r50 = calibobj.petror50[2,*]*self.arcperpix
	;st.petrosb_r = reform( petromag_r + 2.5*alog10(2*!pi*r50^2) )
	st.r_devi = calibobj.r_dev[3]

	; Compute cperp and cpllel
	st.cperp = self->cperp(st.modelmag)
	st.dperp = self->dperp(st.modelmag)
	st.cpllel = self->cpllel(st.modelmag)     

	st.ramod = self->get_ramod(calibobj.ra)
	return, st

end

function bosstarget_lrg::make_cmodelmag, calibobj, cmodelflux=cmodelflux, $
		summed=summed

	if keyword_set(summed) then begin
		nobj=n_elements(calibobj)
		expflux = fltarr(nobj)
		devflux = expflux
		fracpsf = expflux

		for i=0L, 4 do begin
			expflux[*] = calibobj.expflux[i] > 0.001
			devflux[*] = calibobj.devflux[i] > 0.001
		endfor
	
		fracpsf[*] = calibobj.fracpsf[2]

	endif else begin
		devflux = calibobj.devflux
		expflux = calibobj.expflux
		fracpsf = calibobj.fracpsf
	endelse

	cmodelflux = devflux*fracpsf + expflux*(1.0-fracpsf)
	cmodelmag = 22.5-2.5*alog10(cmodelflux > 0.001)

	return, cmodelmag
end


pro bosstarget_lrg::qaplots, calibobj, psfile, types=types
	; This currently requires sdssidl code to work, e.g.
	; pplot and modified legend

	if n_elements(types) eq 0 then begin
		types = ['I','sliding']
	endif
	if n_elements(psfile) ne 0 then begin
		begplot,psfile,/color, /encap
	endif
	; currently relies on sdssidl procedures, need to convert
	tsflags = self->select(calibobj)
	mst = self->derived_struct(calibobj)
	lim = self->pars()

	gmr = mst.modelmag[1,*] - mst.modelmag[2,*]
	rmi = mst.modelmag[2,*] - mst.modelmag[3,*]
	gmr_range=[-0.3, 2.5]
	rmi_range=[-0.5, 2.0]

	;if n_elements(psfile) eq 0 then key=get_kbrd(1)

	magrange = [15,21.5]
	drange = [-0.1, 1.5]
	w=where(tsflags eq 0, nw)
	;pplot, mst[w].cmodelmag[3], mst[w].dperp, psym=3, $
	pplot, mst.cmodelmag[3], mst.dperp, psym=3, $
		aspect=1.366, $
		xrange=magrange, xstyle=3, $
		yrange=drange, ystyle=3, $
		xtitle='i mag', ytitle='dperp'

	colors = ['darkgreen','blue','magenta','red']
	
	for i = 0L, n_elements(types)-1 do begin
		type = types[i]
		color = colors[i]
		w=where( (tsflags and self->tsflag(type)) ne 0, nw)
		if nw ne 0 then begin
			pplot, mst[w].cmodelmag[3], mst[w].dperp, psym=8, symsize=0.3,$
				/overplot, color=color
		endif
	endfor

	use_color = colors[0:n_elements(types)-1]
	plegend, types, colors=use_color, psym=8

	if n_elements(psfile) ne 0 then begin
		endplot, /trim
	endif
end


function bosstarget_lrg::tycho_mask, ra, dec, complement=complement, doplot=doplot, radfac=radfac_in
	; return the index list of those that do NOT match

	common bosstarget_lrg_tycho_block, tycho

	ntot=n_elements(ra)

	if n_elements(radfac_in) eq 0 then radfac=1.0 else radfac=radfac_in

	complement=-1

	if n_elements(tycho) eq 0 then begin
		splog,'caching tycho catalog with btmag < 13 and (ra != 0 or dec != 0)'
		tycho = tycho_read(columns=['ramdeg','demdeg','btmag'])
		w=where(tycho.btmag lt 13.0 and $
			(tycho.ramdeg ne 0.0 or tycho.demdeg ne 0.0) )
		tycho=tycho[w]
	endif

	tychobmag = (tycho.btmag > 6.) < 11.5
	; degrees
	tychorad = (0.0802*tychobmag^2 - 1.860*tychobmag + 11.625)/60.0*radfac
	maxrad = max(tychorad)

	; now match between tycho catalog and the input list
	; we will match within maxrad at first.  Then we will check the 
	; actual magnitude specific distances.
	;
	; note if we had sdssidl we could use a variable match radius with
	; htm_match.pro  here we have to jump through hoops, getting all 
	; matches and then trimming and then getting unique ones

	spherematch, $
		ra, dec, tycho.ramdeg, tycho.demdeg, maxrad, $
		imatch, tycho_match, rad,$
		maxmatch=0

	if tycho_match[0] eq -1 then begin
		return,lindgen(ntot)
	endif

	wmasked = where(rad lt tychorad[tycho_match], nmasked)

	if nmasked eq 0 then begin
		wunmasked=lindgen(ntot)
	endif else if nmasked eq ntot then begin
		wmasked = lindgen(ntot)
		wunmasked=-1
	endif else begin
		; the ones within exact specified radii
		wmasked = imatch[wmasked]

		; remove the duplicate matches
		wmasked = wmasked[rem_dup(wmasked)]

		; extract the unmasked ones
		wunmasked = replicate(1, ntot)
		wunmasked[wmasked] = 0
		wunmasked = where(wunmasked)
	endelse


	;spherematch, $
	;	tycho.ramdeg, tycho.demdeg, ra, dec, maxrad, $
	;	tycho_match, imatch, rad,$
	;	maxmatch=1


	
	;imatch2 = where(rad lt tychorad[tycho_match], n2)
	;if n2 eq 0 then begin
	;	return, lindgen(ntot)
	;endif
	;imatch = imatch[imatch2]

	; set it up so by default rad > match rad, then fill in actual matches
	;radall = replicate(maxrad*1000.0, ntot)
	;tychoradall = replicate(0.0, ntot)

	;radall[imatch] = rad
	;tychoradall[imatch] = tychorad[tycho_match]

	
	;wmasked = where( radall lt tychoradall, nmasked, comp=wunmasked)


	if nmasked eq 0 then begin
		return,lindgen(n_elements(ra))
	endif

	if keyword_set(doplot) then begin
		bin=0.005
		plothist, rad, bin=bin, xbin,ybin, /noplot
		yrange = [0.9, max(ybin)]
		plothist, rad, bin=bin,/ylog, yrange=yrange, ystyle=3, $
			xtitle='separation (deg)', ytitle='number', $
			aspect=1.366
		plothist, rad[wmasked], bin=bin, /overplot, color='red', line=2
		if !p.color eq 0 then mcolor='black' else mcolor='white'

		lmess=['all matches','masked']
		colors=[mcolor,'red']
		legend, /right, lmess, colors=[mcolor, 'red'], line=[0,2]
		if radfac ne 1.0 then begin
			legend,/top,/center,'radfac = '+string(radfac,f='(f0.2)'), $
				charsize=0.85
		endif	
	endif
	
	complement=temporary(wmasked)
	return, wunmasked

end

pro bosstarget_lrg::test_flags_run, calibobj=calibobj
	;html_file='satur_not_satur_center_tychounmasked_sbcut.html'
	;tycho_html_file='satur_not_satur_center_tychomasked_sbcut.html'
	;psfile='lrg3031-sbcut.eps'
	;self->test_flags, calibobj=calibobj, html_file=html_file, tycho_html_file=tycho_html_file, psfile=psfile, sb=1

	; run with radfac = 1.5 to test tycho matching radius

	delvarx,html_file,tycho_html_file
	html_file='satur_not_satur_center_tychounmasked_radfac1.5_nosbcut.html'
	tycho_html_file='satur_not_satur_center_tychomasked_radfac1.5_nosbcut.html'
	psfile='lrg3031-nosbcut-radfac1.5.eps'
	self->test_flags, calibobj=calibobj, html_file=html_file, tycho_html_file=tycho_html_file, psfile=psfile, sb=0, radfac=1.5


	return

	delvarx,html_file,tycho_html_file
	html_file='satur_not_satur_center_tychounmasked_nosbcut.html'
	tycho_html_file='satur_not_satur_center_tychomasked_nosbcut.html'
	psfile='lrg3031-nosbcut.eps'
	self->test_flags, calibobj=calibobj, html_file=html_file, tycho_html_file=tycho_html_file, psfile=psfile, sb=0
end

function bosstarget_lrg::read_some_calibobj
	f=[ $
		sdss_name('calibObj.gal',3031,1,rerun=137),$
		sdss_name('calibObj.gal',3031,2,rerun=137),$
		sdss_name('calibObj.gal',3031,3,rerun=137),$
		sdss_name('calibObj.gal',3031,4,rerun=137),$
		sdss_name('calibObj.gal',3031,5,rerun=137),$
		sdss_name('calibObj.gal',3031,6,rerun=137)]+'.gz'
	; for folks without sdssidl
	if not execute('calibobj=mrdfits_multi(f)') then begin
		message,"you probably don't have mrdfits_multi installed"
	endif
	return, calibobj
end

pro bosstarget_lrg::test_flags, calibobj=calibobj, html_file=html_file, tycho_html_file=tycho_html_file, sb=sb, psfile=psfile, tycho_psfile=tycho_psfile, radfac=radfac

	if n_elements(calibobj) eq 0 then begin
		calibobj=self->read_some_calibobj()
	endif

	; normal cuts !satur
	tsflags_nosatur = self->select(calibobj, sb=sb)
	; looser cuts (!satur or (satur && !satur_center))
	tsflags_satcen = self->select(calibobj, sb=sb, /satcen)

	wnosatur=where($
		(tsflags_nosatur and sdss_flagval('boss_target1','gal_loz'))  ne 0 or $
		(tsflags_nosatur and sdss_flagval('boss_target1','gal_cmass')) ne 0 )
	wsatcen=where($
		(tsflags_satcen and sdss_flagval('boss_target1','gal_loz'))  ne 0 or $
		(tsflags_satcen and sdss_flagval('boss_target1','gal_cmass')) ne 0 )


	wlowz = where( (tsflags_nosatur and sdss_flagval('boss_target1','gal_loz')) ne 0)
	;whiz = where( (tsflags_nosatur and sdss_flagval('boss_target1','gal_hiz')) ne 0)
	wcmass = where( (tsflags_nosatur and sdss_flagval('boss_target1','gal_cmass')) ne 0)

	colorlowz='darkgreen'
	colorhiz='orange'
	colorcmass='blue'

	ntot = n_elements(calibobj)





	fl = self->flag_logic(calibobj, /nosatur)

	mst = self->derived_struct(calibobj)

	logic_lowz = self->target_logic(mst, 'gal_loz', input_logic=fl, sb=sb)
	logic_hiz = self->target_logic(mst, 'gal_hiz', input_logic=fl, sb=sb)
	;logic3 = self->target_logic(mst, 'lrg3', input_logic=fl, sb=sb)
	logic_cmass = self->target_logic(mst, 'gal_cmass', $
		input_logic=fl, sb=sb)


	logic = (logic_lowz or logic_hiz or logic_cmass)

	; now the extra flags
	satur = sdss_flagval('object1','satur')
	satur_center = sdss_flagval('object2','satur_center')

	; now select objects that are saturated but don't have saturated centers
	; and see what these look like.  Should be only a few percent

	satur_logic = (calibobj.objc_flags and satur)
	satcen_logic = (calibobj.objc_flags2 and satur_center)

	sat_logic = logic $
		and ( (satur_logic ne 0) and (satcen_logic eq 0) )






	wsat=where(sat_logic)

	if n_elements(tycho_psfile) ne 0 then begin
		begplot,tycho_psfile,/color,/encap, xsize=8.5, ysize=8.5
		tycho_doplot=1
	endif
	wsat_tychokeep = self->tycho_mask(calibobj[wsat].ra, calibobj[wsat].dec,$
		doplot=tycho_doplot, complement=wsat_tychomasked, $
		radfac=radfac)
	wsat_tychomasked = wsat[wsat_tychomasked]
	help,wnosatur
	help,wsat
	help,wsat_tychokeep

	perc=float(n_elements(wsat_tychokeep))/n_elements(wsat)
	splog,'kept '+strn(n_elements(wsat_tychokeep))+'/'+strn(n_elements(wsat))+$
		' = '+strn(perc)

	wsat = wsat[wsat_tychokeep]

	if n_elements(tycho_psfile) ne 0 then begin
		endplot,/trim
	endif


	if n_elements(psfile) ne 0 then begin
		begplot,psfile,/encap,/color, xsize=8.5, ysize=8.5
	endif 


	pold=!p
	if !d.name ne 'PS' then begin
		; for folks without sdssidl c2i function
		t=execute("!p.background=c2i('white')")
		t=execute("!p.color=c2i('black')")
		symsize_norm=0.5
		symsize_sat=1.0
	endif else begin
		symsize_norm=0.5
		symsize_sat=0.5
		!p.charsize=1
	endelse

	symbol=8
	satcolor='purple'
	satbadcolor='red'
	satbadsymbol=7
	satsymbol=8

	erase & multiplot, [2,1], /square
	magrange = [14,21.5]
	drange = [-0.1, 1.5]
	sbrange=[15,26]

	plotrand, mst.cmodelmag[3], mst.dperp, $
		frac=0.005, $
		xrange=magrange ,yrange=drange, xstyle=3, ystyle=3, psym=3, $
		xtitle='i cmodel mag', ytitle='dperp'
	pplot, mst[wlowz].cmodelmag[3], mst[wlowz].dperp, $
		psym=symbol, symsize=symsize_norm, color=colorlowz, $
		/over
	pplot, mst[wcmass].cmodelmag[3], mst[wcmass].dperp, $
		psym=symbol, symsize=symsize_norm, color=colorcmass, $
		/over
	pplot, mst[wsat].cmodelmag[3], mst[wsat].dperp, $
		psym=satsymbol, symsize=symsize_sat, color=satcolor, $
		/over
	pplot, mst[wsat_tychomasked].cmodelmag[3], mst[wsat_tychomasked].dperp, $
		psym=satbadsymbol, symsize=symsize_sat, color=satbadcolor, /over
	
	lim = self->pars()
	if keyword_set(sb) then begin
		legend,$
		  textoidl('\mu_{r,petro} < '+string(lim.petrosb_r_lim,f='(f4.1)')), $
		  charsize=1
	endif else begin
		legend,'no petrosian sb cut',charsize=1
	endelse

	multiplot
	plotrand, mst.petrosb_r, mst.dperp, $
		frac=0.005, $
		xrange=sbrange ,yrange=drange, xstyle=3, ystyle=3, psym=3, $
		xtitle=textoidl('\mu_{r,petro}')
	pplot, mst[wlowz].petrosb_r, mst[wlowz].dperp, $
		psym=symbol, symsize=symsize_norm, color=colorlowz, $
		/over
	pplot, mst[wcmass].petrosb_r, mst[wcmass].dperp, $
		psym=symbol, symsize=symsize_norm, color=colorcmass, $
		/over
	pplot, mst[wsat].petrosb_r, mst[wsat].dperp, $
		psym=satsymbol, symsize=symsize_sat, color=satcolor, $
		/over
	pplot, mst[wsat_tychomasked].petrosb_r, mst[wsat_tychomasked].dperp, $
		psym=satbadsymbol, symsize=symsize_sat, color=satbadcolor, /over

	legend, ['gal_loz','gal_cmass',$
		     'satur && !!satur_center','satur && !!satur_center MASKED'], $
		psym=[symbol,symbol,satsymbol,satbadsymbol], $
		color=[colorlowz,colorcmass,satcolor,satbadcolor],$
		charsize=1
	if n_elements(radfac) ne 0 then begin
		legend,/bottom,/center,'radfac = '+string(radfac,f='(f0.2)')
	endif

	multiplot,/default

	!p=pold


	if n_elements(psfile) ne 0 then begin
		endplot,/trim
	endif



	if n_elements(html_file) ne 0 then begin
		wsat=reverse(wsat)
		sdss_fchart_table, calibobj[wsat].ra, calibobj[wsat].dec, html_file, $
			/add_atlas, struct=calibobj[wsat]
	endif

	if n_elements(tycho_html_file) ne 0 then begin
		wsat_tychomasked=reverse(wsat_tychomasked)
		sdss_fchart_table, calibobj[wsat_tychomasked].ra, calibobj[wsat_tychomasked].dec, $
			tycho_html_file, $
			/add_atlas, struct=calibobj[wsat_tychomasked]
	endif




end

function bosstarget_lrg::read_lrg_spectra
	
	pg=obj_new('postgres')
	v=obj_new('vagc')

	q='select run,rerun,camcol,field,id,plate,fiberid,mjd,primtarget,class,progname,z,zwarning,r_dev,ra,dec from vagc'
	splog,q
	spec = pg->query(q)

	wlrg = v->select_lrg(spec, nlrg)
	lrg = spec[wlrg]
	spec=0
	return, lrg

end



pro bosstarget_lrg::test_tycho_multi_plot
	file='~/tmp/test_tycho_umfracs.fits'
	dir='/home/users/esheldon/public_html/bosstarget/flags'
	file=path_join(dir,'test_tycho_umfracs.fits')
	psfile=path_join(dir,'test_tycho_umfracs.eps')
	splog,'reading file: ',file
	t=mrdfits(file,1)

	begplot,psfile,/encap,xsize=8.5
	pplot, t.radfac, t.cmass_umf, $
		/xlog, xtickf='loglabels',$
		xtitle='tycho radius/fiducial', $
		ytitle='unmasked fraction', $
		aspect=!gratio
	pplot, t.radfac, t.satcen_umf, /overplot, line=2

	legend, ['cmass','cmass satur && !!satur_center'], line=[0,2], $
		/bottom

	endplot,/trim
end
pro bosstarget_lrg::test_tycho_multi, calibobj
	nrad = 19
	radfac = 10.0^(-1.0 + 0.153333*lindgen(nrad))

	outst = replicate({radfac:0d, satcen_umf:0d, cmass_umf:0d}, nrad)

	for i=0L, nrad-1 do begin
		self->test_tycho, calibobj, radfac[i], $
			wsatcen_unmasked_frac=wsatcen_umf, $
			wcmass_unmasked_frac=wcmass_umf, $
			cmassobj=cmassobj
		outst[i].radfac = radfac[i]
		outst[i].satcen_umf = wsatcen_umf
		outst[i].cmass_umf = wcmass_umf
	endfor

	dir='/home/users/esheldon/public_html/bosstarget/flags'
	file=path_join(dir,'test_tycho_umfracs.fits')
	splog,'writing tofile: ',file,format='(a,a)'
	mwrfits,outst,file,/create
end


pro bosstarget_lrg::test_tycho, calibobj, radfac, html=html, psfile=psfile, doplot=doplot, wsatcen_unmasked_frac=wsatcen_unmasked_frac, wcmass_unmasked_frac=wcmass_unmasked_frac, cmassobj=cmassobj

	if n_elements(calibobj) eq 0 then begin
		calibobj=self->read_some_calibobj()
	endif
	;if n_elements(lrgspec) eq 0 then begin
	;	lrgspec=self->read_lrg_spectra()
	;endif

	if n_elements(cmassobj) eq 0 then begin
		; test if cutting on rdev makes a difference
		tsflags = self->select(calibobj, /satcen, /nordev)

		cmass_logic = $
			(tsflags and sdss_flagval('boss_target1','gal_cmass')) ne 0 
			;and $
			;(tsflags and sdss_flagval('boss_target1','gal_hiz')) ne 0

		wcmass=where(cmass_logic ne 0)

		cmassobj = calibobj[wcmass]
	endif

	satur = sdss_flagval('object1','satur')
	satur_center = sdss_flagval('object2','satur_center')

	satur_logic = (cmassobj.objc_flags and satur)
	satcen_logic = (cmassobj.objc_flags2 and satur_center)

	; saturated objects
	wsat = where(satur_logic ne 0)
	; saturated but not saturated at the center
	wsatcen = where( (satur_logic ne 0) and (satcen_logic eq 0) )

	; run the code
	if n_elements(psfile) ne 0 then begin
		begplot,psfile,/color,/encap, xsize=8.5, ysize=8.5
		tycho_doplot=1
	endif

	;radfac = self->tycho_radfac(type)
	splog,'Using radfac =',radfac,format='(a,a)'

	wsatcen_unmasked = $
		self->tycho_mask(cmassobj[wsatcen].ra, cmassobj[wsatcen].dec,$
			doplot=doplot, complement=wsatcen_masked, radfac=radfac)

	if n_elements(tycho_psfile) ne 0 then begin
		endplot,/trim
	endif

	wcmass_unmasked = $
		self->tycho_mask(cmassobj.ra, cmassobj.dec,$
			doplot=doplot, complement=wcmass_masked, radfac=radfac)


	if wsatcen_masked[0] eq -1 then begin
		wsatcen_masked=-1 
	endif else begin
		wsatcen_masked = wsatcen[wsatcen_masked]
	endelse
	if wsatcen_unmasked[0] eq -1 then begin
		wsatcen_unmasked=-1 
	endif else begin
		wsatcen_unmasked = wsatcen[wsatcen_unmasked]
	endelse


	help,wcmass
	help,wcmass_masked
	help,wcmass_unmasked

	help,wsatcen
	help,wsatcen_masked
	help,wsatcen_unmasked

	if wsatcen_unmasked[0] eq -1 then begin
		wsatcen_unmasked_frac=0
		num=0
	endif else begin
		num = n_elements(wsatcen_unmasked)
		wsatcen_unmasked_frac=$
			float(num)/n_elements(wsatcen)
	endelse
	splog,'of satcen kept '+$
		strn(num)+'/'+strn(n_elements(wsatcen))+$
		' = '+strn(wsatcen_unmasked_frac)

	num=n_elements(wcmass_unmasked)
	wcmass_unmasked_frac=$
		float(num)/n_elements(cmassobj)

	splog,'of cmass kept '+$
		strn(num)+'/'+strn(n_elements(cmassobj))+$
		' = '+strn(wcmass_unmasked_frac)


	dir = '/home/users/esheldon/public_html/bosstarget/flags'
	rfstr = string(radfac,f='(f0.2)')
	satcen_unmasked_html_file = $
		path_join(dir, 'satcen-tychounmasked-radfac'+rfstr+'.html')
	satcen_masked_html_file = $
		path_join(dir, 'satcen-tychomasked-radfac'+rfstr+'.html')



end

pro bosstarget_lrg::prat, num, denom, text=text
	st = strn(num)+'/'+strn(denom)+' = '+strn(float(num)/denom)
	if n_elements(text) ne 0 then st = text + ' '+st
	splog,st
end
pro bosstarget_lrg::test_rdev, calibobj, lrgspec, wdev, wdev_lrg, $
		html=html, dops=dops, tsstruct=tsstruct, cmassobj=cmassobj

	outdir = '~/public_html/bosstarget/flags'
	if n_elements(calibobj) eq 0 then begin
		calibobj=self->read_some_calibobj()
	endif
	if n_elements(lrgspec) eq 0 then begin
		lrgspec=self->read_lrg_spectra()
	endif
	nspec = n_elements(lrgspec)


	if n_elements(cmassobj) eq 0 or n_elements(tsstruct) eq 0 then begin
		; get cmass targets, satur && !satur_center included.  No rdev cut.
		tsstruct = self->select(calibobj, /str, /satcen, /nordev)
		tsflags = tsstruct.boss_target1
		;tsflags = self->select(calibobj, /satcen)

		cmass_logic = $
			(tsflags and sdss_flagval('boss_target1','gal_cmass')) ne 0 
			;and $
			;(tsflags and sdss_flagval('boss_target1','gal_hiz')) ne 0
		wcmass=where(cmass_logic, ncmass)

		cmassobj = calibobj[wcmass]
		tsstruct = tsstruct[wcmass]
	endif

	help,wcmass
	ncmass = n_elements(cmassobj)


	; which are satur and not satur center

	satur = sdss_flagval('object1','satur')
	satur_center = sdss_flagval('object2','satur_center')

	satur_logic = (cmassobj.objc_flags and satur)
	satcen_logic = (cmassobj.objc_flags2 and satur_center)

	wsatcen = where( $
		(satur_logic ne 0) $
		and (satcen_logic eq 0), nsatcen)

	self->prat, nsatcen, ncmass, $
		text='Fraction of cmass+hiz with satcen'



	; some spectro lrg stuff

	wlrg04=where(lrgspec.z gt 0.4, nlrg04)
	self->prat, nlrg04, nspec, text='Fraction of lrg spec with z > 0.4: ' 

	wlrg04_40 = where(lrgspec[wlrg04].r_dev[3] gt 40.0, nlrg04_40)
	wlrg04_40 = wlrg04[wlrg04_40]
	self->prat, nlrg04_40, nlrg04, $
		text='Fraction of z > 0.4 that have r_dev[3] > 40: '

	wlrg04_35 = where(lrgspec[wlrg04].r_dev[3] gt 35.0, nlrg04_35)
	self->prat, nlrg04_35, nlrg04, $
		text='Fraction of z > 0.4 that have r_dev[3] > 35: '
	wlrg04_35 = wlrg04[wlrg04_35]


	wlrg04_20 = where(lrgspec[wlrg04].r_dev[3] gt 20.0, nlrg04_20)
	self->prat, nlrg04_20, nlrg04, $
		text='Fraction of z > 0.4 that have r_dev[3] > 20: '
	wlrg04_20 = wlrg04[wlrg04_20]





	; use this plot to pick an rdev cut for lrgs with spectra and
	; z > 0.4

	if 1 then begin
		if keyword_set(dops) then begin
			psfile='satur_not_satur_center_rdevtest.eps'
			psfile=filepath(root=outdir, psfile)
			begplot, psfile, /color, /encap, xsize=8.5
		endif
		crap=execute("targ_color = c2i('red')")
		crap=execute("lrg04_color = c2i('darkgreen')")
		targ_line = 2
		lrg04_line = 0

		plothist, lrgspec.r_dev[3], xlrg, ylrg, min=1,  $
			yrange=[1.e-4,0.4], ystyle=3, aspect=1, /noplot
		pplot, xlrg, float(ylrg)/max(ylrg)*0.15, $
			yrange=[1.e-4,1],ystyle=3, /ylog, $
			aspect=1, psym=10, $
			xtitle='r_dev[3]', ytickf='loglabels'


		plothist, lrgspec[wlrg04].r_dev[3], xlrg04, ylrg04, min=1,  $
			yrange=[1.e-4,0.4], ystyle=3, aspect=1, /noplot
		pplot, xlrg04, float(ylrg04)/max(ylrg04), psym=10, /overplot, $
			color=lrg04_color, line=lrg04_line

		plothist, cmassobj.r_dev[3], xtarg, ytarg, min=1, /noplot
		pplot, xtarg, float(ytarg)/max(ytarg), psym=10, /overplot, $
			color=targ_color, line=targ_line
		legend, /right, ['lrg spec', 'lrg spec z > 0.4', 'gal_cmass'], line=[0,lrg04_line, targ_line], color=[!p.color, lrg04_color, targ_color]

		if keyword_set(dops) then begin
			endplot,/trim
		endif
	endif




	; 20 is 0.3% of lrgs with z > 0.4
	rdev_cut = 20

	wsatcen_rdevbad = $
		where( (cmassobj.r_dev[3] gt rdev_cut) and $
				(satur_logic ne 0) and (satcen_logic eq 0), $
				nsatcen_rdevbad)
	
	wsatcen_rdevgood = $
		where( (cmassobj.r_dev[3] lt rdev_cut) and $
				(satur_logic ne 0) and (satcen_logic eq 0), $
				nsatcen_rdevgood)

	self->prat, nsatcen_rdevbad, nsatcen, $
		text='Fraction of cmass+hiz+satcen with rdev > '+strn(rdev_cut)
	self->prat, nsatcen_rdevgood, nsatcen, $
		text='Fraction of cmass+hiz+satcen with rdev < '+strn(rdev_cut)



	wsatcen_rdevgood_nomask = $
		where( $
				(cmassobj.r_dev[3] lt rdev_cut)  $
			and	(satur_logic ne 0) $
			and (satcen_logic eq 0) $
			and (tsstruct.tychoflags eq 0) $
				,nsatcen_rdevgood_nomask)
	self->prat, nsatcen_rdevgood_nomask, nsatcen, $
		text='Fraction of cmass+hiz+satcen with nomask and rdev < '+strn(rdev_cut)

	wsatcen_rdevgood_mask = $
		where( $
				(cmassobj.r_dev[3] lt rdev_cut)  $
			and	(satur_logic ne 0) $
			and (satcen_logic eq 0) $
			and (tsstruct.tychoflags eq 1) $
				,nsatcen_rdevgood_mask)
	self->prat, nsatcen_rdevgood_mask, nsatcen, $
		text='Fraction of cmass+hiz+satcen that are masked and rdev < '+strn(rdev_cut)


	if keyword_set(html) then begin

		; first known lrgs with "bad" rdev

		spec_html=filepath(root=outdir, $
		  'satur_not_satur_center_spec_rdevgt'+strn(long(rdev_cut))+'.html')
		sdss_fchart_table, lrgspec[wlrg04_20].ra, lrgspec[wlrg04_20].dec, $
			spec_html, /add_atlas, struct=lrgspec[wlrg04_20]
		
		cmass_bad_html=filepath(root=outdir, $
	      'satur_not_satur_center_cmass_rdevgt'+strn(long(rdev_cut))+'.html')

		; order randomly and pick first 100.  Use same seed always
		;rand = randomu(300, nsatcen_rdevbad)
		;s=sort(rand)

		st=cmassobj[wsatcen_rdevbad]
		sdss_fchart_table, st.ra, st.dec,$ 
			cmass_bad_html, /add_atlas, struct=st


		cmass_good_html=filepath(root=outdir, $
		 'satur_not_satur_center_cmass_rdevlt'+strn(long(rdev_cut))+'.html')
		rand = randomu(300, nsatcen_rdevgood)
		s=sort(rand)

		st=cmassobj[wsatcen_rdevgood[s[0:100]]]
		sdss_fchart_table, st.ra, st.dec,$ 
			cmass_good_html, /add_atlas, struct=st



		; also masking
		cmass_good_html=filepath(root=outdir, $
		 'satur_not_satur_center_cmass_nomask_rdevlt'+strn(long(rdev_cut))+'.html')
		rand = randomu(350, nsatcen_rdevgood_nomask)
		s=sort(rand)

		st=cmassobj[wsatcen_rdevgood_nomask[s[0:100]]]
		sdss_fchart_table, st.ra, st.dec,$ 
			cmass_good_html, /add_atlas, struct=st, width=200, rebin=2;,/over



	endif

end


pro bosstarget_lrg::satcen_plotflags, calibobj, cmassobj=cmassobj, tsstruct=tsstruct, dops=dops

	outdir = '~/public_html/bosstarget/flags'
	if n_elements(calibobj) eq 0 then begin
		calibobj=self->read_some_calibobj()
	endif

	if n_elements(cmassobj) eq 0 or n_elements(tsstruct) eq 0 then begin
		; get cmass targets, satur && !satur_center included.  No rdev cut.
		tsstruct = self->select(calibobj, /str, /satcen)
		tsflags = tsstruct.boss_target1
		;tsflags = self->select(calibobj, /satcen)

		cmass_logic = $
			(tsflags and sdss_flagval('boss_target1','gal_cmass')) ne 0 
			;and $
			;(tsflags and sdss_flagval('boss_target1','gal_hiz')) ne 0
		wcmass=where(cmass_logic, ncmass)

		cmassobj = calibobj[wcmass]
		tsstruct = tsstruct[wcmass]
	endif

	help,wcmass
	ncmass = n_elements(cmassobj)


	; which are satur and not satur center

	satur = sdss_flagval('object1','satur')
	satur_center = sdss_flagval('object2','satur_center')

	satur_logic = (cmassobj.objc_flags and satur)
	satcen_logic = (cmassobj.objc_flags2 and satur_center)

	wsatcen = where( $
		(satur_logic ne 0) $
		and (satcen_logic eq 0), nsatcen)

	self->prat, nsatcen, ncmass, $
		text='Fraction of cmass+hiz with satcen'





	sf=obj_new('sdss_flags')

	ch=0.7

	xsize=8.5
	ysize=7.0
	psfile=filepath(root=outdir, 'cmasshiz-plotflags1.eps')
	begplot,psfile, /encap, xsize=xsize, ysize=ysize
	sf->plotflags, cmassobj.objc_flags, 'object1', /frac, label_charsize=ch
	legend,'CMASS+HIZ',/right
	endplot,/trim


	psfile=filepath(root=outdir, 'cmasshiz-plotflags2.eps')
	begplot,psfile, /encap, xsize=xsize, ysize=ysize
	sf->plotflags, cmassobj.objc_flags2, 'object2', /frac, label_charsize=ch
	legend,'CMASS+HIZ',/right
	endplot,/trim


	psfile=filepath(root=outdir, 'cmasshiz-satcen-plotflags1.eps')
	begplot,psfile, /encap, xsize=xsize, ysize=ysize
	sf->plotflags, cmassobj[wsatcen].objc_flags, 'object1', $
		/frac, label_charsize=ch
	legend,['CMASS+HIZ','SATUR && !!SATUR_CENTER'],/right
	endplot,/trim


	psfile=filepath(root=outdir, 'cmasshiz-satcen-plotflags2.eps')
	begplot,psfile, /encap, xsize=xsize, ysize=ysize
	sf->plotflags, cmassobj[wsatcen].objc_flags2, 'object2', $
		/frac, label_charsize=ch
	legend,['CMASS+HIZ','SATUR && !!SATUR_CENTER'],/right
	endplot,/trim

	obj_destroy, sf



end




function bosstarget_lrg::known_gals_match, objs, known_id=known_id

	if n_elements(objs) eq 0 then begin
		on_error, 2
		splog,'Usage: boss_target1=bl->known_gals_match(objs)'
		message,'Halting'
	endif

	splog,'Matching to known "good" SDSS spectroscopic galaxies'

	common known_gals_block, known_gals
	self->known_gals_cache

	nobj=n_elements(objs)
	nknown=n_elements(known_gals)

	; to be filled in
	boss_target1 = lon64arr(nobj)
	known_id = replicate(-9999L, nobj)

	
	known_ind = lindgen(nknown)

	if tag_exist(known_gals,'progname') then begin
		wmain = where(strmatch(known_gals.progname,'main*'), nmain)
		known_ind = known_ind[wmain]	
	endif

	matchrad = 1d/3600d
	spherematch, $
		objs.ra, objs.dec, $
		known_gals[known_ind].plug_ra, known_gals[known_ind].plug_dec, $
		matchrad, $
		objs_match, known_match, distances,$
		maxmatch=1

	nmatch=0L
	if objs_match[0] ne -1 then begin
		nmatch=n_elements(objs_match)

		known_match = known_ind[known_match]

		boss_target1[objs_match] $
			+= sdss_flagval('boss_target1','SDSS_KNOWN')
		known_id[objs_match] = known_match
	endif

	splog,'Found ',nmatch,' matches ', form='(a,i0,a)'

	return, boss_target1
	
end

function bosstarget_lrg::known_gals_file
	dir=getenv('BOSSTARGET_DIR')
	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	dir = filepath(root=dir, 'data')
	file=filepath(root=dir, 'spAll_primary_good.fits')
	return, file
end
pro bosstarget_lrg::known_gals_cache, reload=reload
	common known_gals_block, known_gals

	if n_elements(known_gals) eq 0 or keyword_set(reload) then begin
		file=self->known_gals_file()
		splog,'Reading file: ',file,form='(a,a)'
		known_gals=mrdfits(file, 1)
		if n_tags(known_gals) eq 0 then begin
			message,string('Failed to read file: ',file,form='(a,a)')
		endif
	endif
end
function bosstarget_lrg::known_gals_read, reload=reload
	common known_gals_block, known_gals

	self->known_gals_cache, reload=reload
	return, known_gals
end


pro bosstarget_lrg::known_qso_stars_cache
	common known_qso_block_forlrg, knownqso
	if n_elements(knownqso) eq 0 then begin
		;bq = obj_new('bosstarget_qso')
		;knownqso = bq->known_qso_read()
		bqknown = obj_new('bosstarget_qsoknown')
		knownqso = bqknown->read()
	endif
end

function bosstarget_lrg::known_qso_star_match, objs

	common known_qso_block_forlrg, knownqso
	self->known_qso_stars_cache

	matchrad = 1d/3600d
	splog,'Matching known qsos/stars within ',matchrad*3600,' arcsec', $
		format='(a,g0,a)'	
	unmatched = lonarr(n_elements(objs))
	spherematch, $
		objs.ra, objs.dec, knownqso.ra, knownqso.dec, $
		matchrad, $
		matchobjs, matchknown, maxmatch=1

	if matchobjs[0] ne -1 then nmatch=n_elements(matchobjs) else nmatch=0
	splog,'Found ',nmatch,' matches',form='(a,i0,a)'

	return, matchobjs

end



function bosstarget_lrg_default_pars
	; this serves to define the par struct as well as the defaults

	parstruct = { bosstarget_lrg_parstruct, $
		; if 1, don't use the calib_status information, e.g. photometric
		nocalib: 1, $ 
		commissioning: 0,         $ ; use commissioning parameters
		nordev: 0, $
		satcen: 0, $
		nosatur: 0, $
		conc: 0, $
		verbose:1, $
		$
		petrosb_r_lim: 24.2,      $ ; r-band petrosian sb limit * not used
		rmaglim:[13.5d0,          $ ; gal_loz parameter
		         16.0d0,19.6d0],  $ ; gal_loz magnitude limits
		max_cperp: 0.2d,          $ ; gal_loz max absolute cperp for cut I
		max_rmi: 2.0,             $ ; hiz/cmass max r-i
		dperp0:0.55,              $ ; hiz/cmass low dperp cut
		dperp1:0.75,              $ ; * Not used
		ilow:17.5,                $ ; hiz/cmass bright limit
		ihi_hiz:19.9,             $ ; hiz faint limit
		ihi_hiz_comm:20.0,        $ ; hiz faint limit -- commissioning
		;ihi_cmass: 19.84,         $ ; cmass faint limit
		;ihi_cmass: 19.92,         $ ; cmass faint limit
		ihi_cmass: 19.86,         $ ; cmass faint limit
		ihi_cmass_comm: 20.14,    $ ; cmass faint limit -- commissioning
		ramod_thresh: 80,         $ ; threshold to sparse sample at ~5/sq deg
		ihi_fib: 21.7,            $ ; fiber faint limit for all cuts
		ihi_fib2: 21.5,            $ ; fiber faint limit for new cuts (nov 2010)
		ilow_fib: 15.,            $ ; fiber bright limit for all cuts
		slide_line: [0.80, 1.60], $ ; cmass line in mag-dperp space
		r_devimax: 20.0,          $ ; sanity radius check.
                rconc_lim: 0.3,           $ ; Cut I s/g separation
		iconc_lim: 0.3,           $ ; potential s/g separation cut
		iconci0: 0.2,              $ ; Sliding S/G separation, based on 
                                    ; UKIDSS (David Wake)
	    iconci1: 0.2,               $ ; conci > iconci0 + iconci1*(20-i_model)
		iconcz0: 9.125, $
		iconcz1: -0.46$  ; concz > iconcz0 + iconcz1*z_model
	}

	return, parstruct
end

pro bosstarget_lrg::set_default_pars
	pars=bosstarget_lrg_default_pars()
	self.pars = pars
end
function bosstarget_lrg_testcall
	return,3
end
pro bosstarget_lrg__define

	parstruct = bosstarget_lrg_default_pars()
	struct = {$
		bosstarget_lrg, $
		pars: parstruct $
	}
end
