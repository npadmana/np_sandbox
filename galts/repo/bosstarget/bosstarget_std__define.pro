function bosstarget_std::init, pars=pars, _extra=_extra
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end


;docstart::bosstarget_std::select
; NAME:
;	bosstarget_std::select
; PURPOSE:
;   Version 0.00001 of the galaxy selection algorithm for BOSS
; CALLING SEQUENCE:
;	ql = obj_new('bosstarget_std', pars=, _extra=)
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
;	or as an argument during construction (bl=obj_new('bosstarget_std',pars=)
;
;	Also any keywords sent during construcion or to the ::select method
;	will get copied in over the default pars.  pars= takes precedence over
;	keywords.  
;   
; REVISION HISTORY:
;	Written: 2009-06-? Erin Sheldon, BNL.  
;	This documentation added, 2010-01-25, Erin Sheldon BNL.
;docend::bosstarget_std::select




function bosstarget_std::select, calibobj, $
		pars=extra_pars, $
		extra_logic=extra_logic, $
		doplot=doplot, $
		_extra=_extra

	self->copy_extra_pars, pars=extra_pars, _extra=_extra

	flags = lon64arr(n_elements(calibobj))

	; logic for objc_flags[2], resolve, calib checks
	flag_logic = self->flag_logic(calibobj)

	if n_elements(extra_logic) ne 0 then begin
		tmp_logic = self->extra_logic(calibobj, extra_logic)
		flag_logic = flag_logic and tmp_logic
	endif

	w=where(flag_logic, nw)
	print,nw,' passed flag logic'

	fstar_logic = self->fstar_logic(calibobj, input_logic=flag_logic, $
		doplot=doplot)


	; don't target known quasars as fstar standards.  Logic is false
	; for matches
	known_qso_logic = self->known_qso_match_logic(calibobj, $
		known_qso_id=known_qso_id)

	fstar_logic = fstar_logic and known_qso_logic
	flags += fstar_logic*sdss_flagval('boss_target1','std_fstar')


	st = self->struct(count=n_elements(calibobj))
	struct_assign, calibobj, st, /nozero

	st.known_qso_id = known_qso_id
	st.boss_target1 = flags
	return, st
end

function bosstarget_std::extra_logic, str, extra_logic
	command = 'logic = '+extra_logic
	print,'getting extra logic with command = ',command
	if not execute(command) then begin
		message,'Failed to execute extrta logic command: '+command
	endif

	return, logic
end


function bosstarget_std::known_qso_match_logic, calibobj, $
		known_qso_id=known_qso_id

	splog,'Matching to known quasars'
	lim=self->pars()

	nobj=n_elements(calibobj)
	known_qso_id = replicate(-9999L, nobj)

	; the /commissioning will work for both comm and comm2 runs
	bknown=obj_new('bosstarget_qsoknown')
	knownqso = bknown->read()

	; remove the stars
	w=where(knownqso.zem gt 0.01)
	knownqso = knownqso[w]

	spherematch, $
		calibobj.ra, calibobj.dec, knownqso.ra, knownqso.dec, $
		lim.known_qso_matchrad, $
		objs_match, known_match, dist,$
		maxmatch=1

	nmatch=0
	if objs_match[0] ne -1 then begin
		nmatch=n_elements(objs_match)
		known_qso_id[objs_match] = known_match
	endif
	splog,'Found: ',nmatch,nobj,' matches', $
		form='(a,i0,"/",i0,a)'

	return, known_qso_id lt 0

end


function bosstarget_std::fstar_logic, calibobj, input_logic=input_logic, $
		doplot=doplot

	if n_elements(input_logic) eq 0 then begin
		input_logic=replicate(1, n_elements(calibobj) )
	endif 

	logic = input_logic

	; this is a pretty harsh cut but we don't care about completeness
	logic = logic $
		and ( (calibobj.objc_flags2 and sdss_flagval('object2','satur_center')) eq 0 ) $
		and ( (calibobj.objc_flags2 and sdss_flagval('object2','interp_center')) eq 0 ) $
		and ( (calibobj.objc_flags2 and sdss_flagval('object2','psf_flux_interp')) eq 0 )


	; extinction corrected model magnitudes
	rawmags = 22.5 - 2.5*alog10( calibobj.psfflux > 0.001 )
	mags = rawmags - calibobj.extinction
	umg = reform( mags[0,*] - mags[1,*] )
	gmr = reform( mags[1,*] - mags[2,*] )
	rmi = reform( mags[2,*] - mags[3,*] )
	imz = reform( mags[3,*] - mags[4,*] )

	; This structure contains our limits
	lim = self->pars()

	; basic magnitude cut is in r-band (un-extincted)
	logic = logic and (rawmags[2,*] gt lim.min_rmag and rawmags[2,*] lt lim.max_rmag)

	; compute distance in 4-d color space of each star from
	; our canonical low-metalicity F-star color
    mdist = sqrt( (umg - lim.umg_val)^2/lim.umg_wid^2 $
        + (gmr - lim.gmr_val)^2/lim.gmr_wid^2 $
        + (rmi - lim.rmi_val)^2/lim.rmi_wid^2 $
        + (imz - lim.imz_val)^2/lim.imz_wid^2 )

	logic = logic and (mdist lt 1)

	; from here on just plotting stuff

	if keyword_set(doplot) then begin
		w=where(input_logic and (mags[2,*] lt lim.max_rmag), nw)
		w2 = where(logic, nw2)
		if n_elements(w2) eq 1 then w2=[w2]
		if nw ne 0 then begin

			plold = !p
			if !d.name ne 'PS' then begin
				t=execute("!p.background=c2i('white')")
				t=execute("!p.color=c2i('black')")
			endif else begin
				!p.charsize=1
			endelse


			nc=n_elements(calibobj)
			ind = long( randomu(seed,nc/10.0)*(nc-1) )
			pplot, calibobj[ind].ra, calibobj[ind].dec, psym=3, /ynozero, $
				aspect=1
			pplot, calibobj[w].ra, calibobj[w].dec, psym=8, symsize=0.5, $
				/overplot, $
				color='blue'
			if nw2 gt 0 then begin
				pplot, calibobj[w2].ra, calibobj[w2].dec, psym=8, $
					/overplot, $
					color='red'
			endif

			if !d.name ne 'PS' then key=get_kbrd(1)

			erase & multiplot, [2,2], /square, /doxaxis
			set_color = 'red'
			box_color = 'darkgreen'
			
			;!p.multi=[0,2,2]
			umg_range = [0.7,1.5]
			gmr_range = [0.0,1.0]
			rmi_range = [-0.2,0.5]
			imz_range = [-0.2,0.4]
			pplot, umg[w], gmr[w], psym=3, $
				xrange=umg_range, yrange=gmr_range, $
				xstyle=3, ystyle=3, $
				xtitle='u-g', ytitle='g-r'
			axis, xaxis=1, xrange=umg_range, xstyle=3, xtickf='(f-4.1)', $
				xtitle='u-g'

			plot_box, $
				lim.umg_val-lim.umg_wid, lim.umg_val+lim.umg_wid, $
				lim.gmr_val-lim.gmr_wid, lim.gmr_val+lim.gmr_wid, $
				color=box_color


			if nw2 gt 0 then begin
				pplot, umg[w2], gmr[w2], psym=8, color=set_color,/over,$
					symsize=0.5
			endif

			multiplot;, /doyaxis
			pplot, rmi[w], gmr[w], psym=3, $
				yrange=gmr_range, xrange=rmi_range, $
				xstyle=3, ystyle=3;, $
				;ytitle='g-r', xtitle='r-i'
			axis, yaxis=1, ytitle='g-r', yrange=gmr_range, ystyle=3, $
				ytickf='(f-4.1)'
			axis, xaxis=1, xrange=rmi_range, xstyle=3, xtickf='(f-4.1)', $
				xtitle='r-i'

			plot_box, $
				lim.rmi_val-lim.rmi_wid, lim.rmi_val+lim.rmi_wid, $
				lim.gmr_val-lim.gmr_wid, lim.gmr_val+lim.gmr_wid, $
				color=box_color

			if nw2 gt 0 then begin
				pplot, rmi[w2], gmr[w2], psym=8, color=set_color,/over,$
					symsize=0.5
			endif

			
			multiplot
			multiplot;, /doyaxis
			plot, rmi[w], imz[w], psym=3, $
				xrange=rmi_range, yrange=imz_range, $
				xstyle=3, ystyle=3, $
				xtitle='r-i';, ytick_get=ytickv
			axis, yaxis=1, ytitle='i-z', yrange=imz_range, ystyle=3, $
				ytickf='(f-4.1)';ytickname=ytickn

			plot_box, $
				lim.rmi_val-lim.rmi_wid, lim.rmi_val+lim.rmi_wid, $
				lim.imz_val-lim.imz_wid, lim.imz_val+lim.imz_wid, $
				color=box_color


			if nw2 gt 0 then begin
				pplot, rmi[w2], imz[w2], psym=8, color=set_color,/over,$
					symsize=0.5
			endif

			;!p.multi=0
			multiplot,/default
			!p = plold
		endif
	endif

	w=where(logic, nw)
	print,nw,' passed fstar logic'

	return, logic

end


function bosstarget_std::flagval, select_type
	case strlowcase(select_type) of
		'std_fstar': return, 2L^15
		else: message,'Unkown selection type: '+string(select_type)
	endcase
end

function bosstarget_std::pars
	return, self.pars
end

function bosstarget_std::pars_old
	; put these in a config file somewhere
	pars = {$
		; if 1, don't use the calib_status information, e.g. photometric
		nocalib: 0, $ 
		commissioning: 0, $
		min_rmag:15.0, $
		$;max_rmag:18.0, $
		max_rmag:19.0, $
		$
		umg_val:0.82, $
		umg_wid:0.08, $
		$
		gmr_val:0.30, $
		gmr_wid:0.08, $
		$
		rmi_val:0.09, $
		rmi_wid:0.08, $
		$
		imz_val:0.02, $
		imz_wid:0.08, $
		$
		known_qso_matchrad: 1d/3600d }

	ep=self->extra_pars()
	if size(ep,/tname) eq 'STRUCT' then begin
		splog,'Adding extra pars'
		self->print_pars,ep
		struct_assign, ep, pars, /nozero
	endif


	return, pars
end

function bosstarget_std::calib_logic, calibobj
    photometricflag = sdss_flagval('calib_status','photometric')
    logic = $
        (calibobj.calib_status[0] and photometricflag) ne 0 $
        and (calibobj.calib_status[1] and photometricflag) ne 0 $
        and (calibobj.calib_status[2] and photometricflag) ne 0 $
        and (calibobj.calib_status[3] and photometricflag) ne 0 $
        and (calibobj.calib_status[4] and photometricflag) ne 0
    return, logic
end
function bosstarget_std::flag_logic, calibobj

	pars=self->pars()

	; first the flags that must be set
	stationary_flag = sdss_flagval('object2','stationary')
	primaryflag = sdss_flagval('resolve_status','survey_primary')

	logic = $
		(calibobj.objc_flags2 and stationary_flag) ne 0 $
		and (calibobj.resolve_status and primaryflag) ne 0

	if not pars.nocalib then begin
		splog,'Cutting to photometric'
        logic = logic and self->calib_logic(calibobj)
	endif else begin
		splog,'NOT cutting to photometric'
	endelse

	; make sure photo thinks it is a star
	logic = logic $
		and (calibobj.objc_type eq 6)

	; flags that must not be set
	blended = sdss_flagval('object1','blended')
	too_many_peaks = sdss_flagval('object1','deblend_too_many_peaks')
	cr = sdss_flagval('object1','cr')
	satur = sdss_flagval('object1','satur')
	badsky = sdss_flagval('object1','badsky')

	peaks_too_close = sdss_flagval('object2','peaks_too_close')
	notchecked_center = sdss_flagval('object2','notchecked_center')

	logic = logic $
		and (calibobj.objc_flags and blended) eq 0 $
		and (calibobj.objc_flags and too_many_peaks) eq 0 $
		and (calibobj.objc_flags and cr) eq 0 $
		and (calibobj.objc_flags and satur) eq 0 $
		and (calibobj.objc_flags and badsky) eq 0 $
		and (calibobj.objc_flags2 and peaks_too_close) eq 0 $
		and (calibobj.objc_flags2 and notchecked_center) eq 0
	return, logic
end



function bosstarget_std::struct, count=count
	st = { $
		run: 0L, $
		rerun: '', $
		camcol: 0L, $
		field: 0L, $
		id: 0L, $
		known_qso_id: -9999L, $
		calib_status: intarr(5), $
		resolve_status: 0L, $
		boss_target1: 0LL}
	if n_elements(count) ne 0 then begin
		st = replicate(st, count)
	endif

	return, st
end

function bosstarget_std::color_plots, struct

	; extinction corrected model magnitudes
	mags = 22.5 - 2.5*alog10( calibobj.psfflux > 0.001 )
	mags = mags - calibobj.extinction
	umg = reform( mags[0,*] - mags[1,*] )
	gmr = reform( mags[1,*] - mags[2,*] )
	rmi = reform( mags[2,*] - mags[3,*] )
	imz = reform( mags[3,*] - mags[4,*] )

	; This structure contains our limits
	lim = self->pars()


end

pro bosstarget_std::print_pars, pars
	if n_elements(pars) eq 0 then begin
		pars = self->pars()
	endif
	tn=tag_names(pars)
	for i=0L, n_elements(tn)-1 do begin
		if size(pars.(i),/tname) ne 'STRUCT' then begin
			splog,tn[i],pars.(i),format='(a-35, a)'
		endif
	endfor
end



pro bosstarget_std::copy_extra_pars, pars=pars, _extra=_extra

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

end

function bosstarget_std_default_pars
	; put these in a config file somewhere
	pars = { bosstarget_std_parstruct, $
		$
		; if 1, don't use the calib_status information, e.g. photometric
		nocalib: 0, $ 
		commissioning: 0, $
		min_rmag:15.0, $
		$;max_rmag:18.0, $
		max_rmag:19.0, $
		$
		umg_val:0.82, $
		umg_wid:0.08, $
		$
		gmr_val:0.30, $
		gmr_wid:0.08, $
		$
		rmi_val:0.09, $
		rmi_wid:0.08, $
		$
		imz_val:0.02, $
		imz_wid:0.08, $
		$
		known_qso_matchrad: 1d/3600d }

	return, pars
end




pro bosstarget_std::set_default_pars
	pars=bosstarget_std_default_pars()
	self.pars = pars
end







pro bosstarget_std__define

	parstruct = bosstarget_std_default_pars()
	struct = {$
		bosstarget_std, $
		pars: parstruct $
	}
end
