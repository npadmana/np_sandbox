;+
; CLASS NAME:
;	bosstarget
;
; PURPOSE:
;	Run the various BOSS target algorithms.
;
; CATEGORY:
;	SDSS III/BOSS specific
;
; CALLING SEQUENCE:
;	bt = obj_new('bosstarget')
; METHODS:
;	run IDL> methods, 'bosstarget' to see a list of methods.
;
; MODIFICATION HISTORY:
;	Created Erin Sheldon, BNL 2009-??
;
;-
function bosstarget::init, pars=pars

	self->set_default_pars
	self->add_extra_pars, pars
	return, 1
end

pro bosstarget::process_partial_runs, target_type, target_run, jobnum, $
		nper=nper, $
		run_index=run_index, $
		fpobjc=fpobjc, $
		pars=pars, $
		extra_logic=extra_logic, $
		_extra=_extra

	if n_elements(target_type) eq 0 or n_elements(jobnum) eq 0 then begin
		on_error, 2
		message,'bt->process_partial_runs, target_type, target_run, jobnum, nper=2, run_index=, /fpobjc, _extra='
	endif

	if n_elements(nper) eq 0 then begin
		nper=2
	endif
	self->split_runlist, runptrs, rerunptrs, nper=nper
	runs = *runptrs[jobnum]
	reruns = *rerunptrs[jobnum]
	ptr_free, runptrs, rerunptrs

	if n_elements(run_index) ne 0 then begin
		runs=runs[run_index]
		reruns=reruns[run_index]
	endif

	splog,'Using runs: ',runs

	self->process_runs, target_type, target_run,  $
		runs=runs, extra_logic=extra_logic, fpobjc=fpobjc,  $
		pars=pars, $
		_extra=_extra

end



;docstart::bosstarget::process_runs
;
; NAME:
;	bosstarget::process_runs	
;
; PURPOSE:
;	Process a list of runs through a targeting code.  Can process either the
;	datasweeps or fpObjc files.
;
; CALLING SEQUENCE:
;	bt=obj_new('bosstarget')
;	bt->process_runs, target_type, target_run, $
;		target_dir=, runs=, logfile=, /fpobjc, /all _extra=_extra
;
; INPUTS:
;	target_type: 'lrg','qso','std'
;	target_run: Either a string or a number.  Numbers will be converted to
;		a 6-zero padded integer string, e.g. 001732, when including in a
;		file name.
;
; OPTIONAL INPUTS:
;	target_dir: over-ride the default location $BOSS_TARGET/target_run	
;	runs: specify a set of runs.  These must be a subset of those returned
;		by a run of bt->runlist
;	logfile: Specify a file to write log messages
;	/fpobjc: Process fpObjc files instead of sweep files.
;	/all:  For 'lrg' temporarily set objc_type=3 for all.  For qso set to 6
;		so all will be run.  Note lrg now does not use objc_type by default,
;		but instead uses concentration in the i band > 0.3.
;	extra_logic: A string containing extra logic to apply.  This will be
;		added to the status_struct in the first extension.
;	pars=: A structure with extra parameters to be fed to the underlying "select" 
;       function for each target type
;	_extra:  Extra keywords for the ::select method for each target type.
;		See the individual documention.
;
;		Notable extra keywords:
;			type=  Select only using certain algorithms.  default 'all'. For
;				example, type=['nn','like'] to just run the NN and likelihood
;				codes for qsos.
;
; OUTPUTS:
;	Writes the status_struct (see ::status_struct) to the first binary
;	table extension.
;
;	Writes the structures returned by the ::select methods to second 
;	extension. See the ::target_file method for how these names are generated.
;
; MODIFICATION HISTORY:
;		* renamed process_datasweeps to process_runs which can now process
;			fpObjc files.
;		* require target_run input
;	2009-06-31:  Write a status structure to the first binary table extension.
;		This is much more powerful than using the header.
;docend::bosstarget::process_runs

pro bosstarget::process_runs, target_type, target_run, $
		runs=runs, camcols=camcols, $
		fpobjc=fpobjc, $
		all=all, $
		match_method=match_method, $
		extra_logic=extra_logic, $
		pars=pars, $
		target_dir=target_dir, $
		logfile=logfile, $
		_extra=_extra

	if n_elements(target_type) eq 0 or n_elements(target_run) eq 0 then begin
		splog,"usage: "
		splog,"  bt=obj_new('bosstarget')"
		splog,"  bt->process_runs, target_type, target_run, target_dir=, runs=all, camcols=all, logfile=stdout, extra_logic=, /fpobjc, /all, _extra="
		splog,"  See the ::select method in the individual target classes for "
		splog,"  extra keywords that can be sent.  These will be passed along "
		splog,"  with the _extra= technique"
		on_error, 2
		message,'Halting'
	endif

	; begin logging
	splog, filename=logfile

	if n_elements(target_dir) eq 0 then begin
		target_dir = self->target_dir(target_run)
	endif

	if not file_test(target_dir) then begin
		splog,'Making target_dir: '+target_dir
		file_mkdir, target_dir
	endif

	if not file_test(target_dir,/directory) then begin
		message,'Directory does not exist: '+string(target_dir)
	endif

	; Get some environment variables
	calibdir = getenv('PHOTO_CALIB')
	if NOT keyword_set(calibdir) then begin
		message,'Set PHOTO_CALIB'
	endif
	resdir = getenv('PHOTO_RESOLVE')
	if NOT keyword_set(resdir) then begin
		message,'Set PHOTO_RESOLVE'
	endif
	sweepdir = getenv('PHOTO_SWEEP')
	if NOT keyword_set(sweepdir) then begin
		message,'Set PHOTO_SWEEP'
	endif
	targetversion = bosstarget_version()

	; make sure we have our run list
	self->match_runlist, runs, runs2use, reruns2use

	stime0 = systime(1)
   
	nrun = n_elements(runs2use)

	if n_elements(logfile) ne 0 then begin
		splog, 'Log file ' + logfile + ' opened ' + systime()
	endif
	splog, 'Working with Nrun=', nrun
	spawn, 'uname -a', uname
	splog, 'Uname: ' + uname[0]


	if n_elements(camcols) eq 0 then camcols=[1,2,3,4,5,6]

	;---- For loop goes through all the runs

	calibobj_type = self->calibobj_type(target_type)
	for irun=0L, nrun-1L do begin
		run = runs2use[irun]
		rerun = reruns2use[irun]

		for icamcol=0, n_elements(camcols)-1 do begin
			camcol=camcols[icamcol]

			status_struct = self->status_struct($
				target_type=target_type,target_run=target_run,$
				run=run,rerun=rerun,camcol=camcol)

			status_struct.date =  systime()
			status_struct.photoop_v = photoop_version()
			status_struct.bosstarget_v = bosstarget_version()
			status_struct.idlutils_v = idlutils_version()
			status_struct.photo_sweep = file_basename(sweepdir)
			status_struct.photo_resolve = file_basename(resdir)
			status_struct.photo_calib = file_basename(calibdir)

			if n_elements(extra_logic) ne 0 then begin
				status_struct.extra_logic=extra_logic
			endif

			target_file = self->target_file( $
				target_type, target_run, run, rerun, camcol, $
				target_dir=target_dir, $
				fpobjc=fpobjc, all=all, match_method=match_method, old=old)

			status_struct.output_file = file_basename(target_file)

			if keyword_set(fpobjc) or keyword_set(all) then begin
				; run on the full fpObjc files
				res = self->process_fpobjc($
					target_type, run, rerun, camcol, $
					pars=pars, $
					nobj=nobj, all=all, $
					extra_logic=extra_logic, $
					_extra=_extra)
			endif else if n_elements(match_method) ne 0 then begin
				; take the match_method string as the name of a matching
				; method contained within the class for this target type.
				; This should return a structure describing matches between
				; the sweep and some internal catalog
				res = self->match_sweep( $
					target_type, run, rerun, camcol, match_method, $
					nobj=nobj, $
					extra_logic=extra_logic, $
					_extra=_extra)
			endif else begin
				; run on the sweeps
				res = self->process_sweep($
					target_type, run, rerun, camcol, $
					pars=pars, $
					used_pars=used_pars, $
					nobj=nobj, $
					extra_logic=extra_logic, $
					_extra=_extra)
			endelse

			status_struct.nobj=nobj
			if status_struct.nobj eq 0 then begin
				status_struct.process_flags += self->processing_flag('read_fail')
			endif
			if n_tags(res) eq 0 then begin
				status_struct.process_flags += self->processing_flag('noresult')
				status_struct.nres=0
			endif else begin
				status_struct.nres=n_elements(res)
			endelse

			; combine the status_struct with the parameter struct from 
			; the selection
			status_struct = create_struct(status_struct, used_pars)

			splog,$
				'Writing status structure to file: ',target_file,format='(a,a)'
			mwrfits, status_struct, target_file, /create

			if n_tags(res) ne 0 then begin
				splog, 'Run=',run,' camcol=', camcol,' Nres=',n_elements(res)
				splog,$
				 'Appending results to output file: ',target_file,format='(a,a)'
				mwrfits, res, target_file
			endif 
	
		endfor
	endfor

	splog, 'Total time = ', systime(1)-stime0, ' seconds', format='(a,f6.0,a)'
	splog, 'Successful completion at ' + systime()
	splog, /close

	return

end

function bosstarget::status_struct, $
		target_type=target_type, target_run=target_run, $
		run=run, rerun=rerun, camcol=camcol, $
		minimal=minimal

	st = { $
		target_type: '', $
		target_run: '', $
		photoop_v: '', $
		bosstarget_v: '', $
		idlutils_v: '', $
		photo_sweep: '', $
		photo_resolve: '', $
		photo_calib: ''}

	if n_elements(target_type) ne 0 then st.target_type=target_type
	if n_elements(target_run) ne 0 then st.target_run=target_run

	if not keyword_set(minimal) then begin
		st_rest = { $
			run:-9999L,$
			rerun:'-9999L',$
			camcol:-9999L, $
			output_file: '', $
			date: '', $
			nobj: 0L, $
			nres: 0L, $
			extra_logic:' ',$  ; mwrfits bug with empty strings
			process_flags: 0L}
		st = create_struct(st, st_rest)


		if n_elements(run) ne 0 then st.run=run
		if n_elements(rerun) ne 0 then st.rerun=rerun
		if n_elements(camcol) ne 0 then st.camcol=camcol
	endif

	return, st
end

function bosstarget::processing_flag,name
	case strlowcase(name) of
		'read_fail': return, 2L^0
		'noresult': return, 2L^1
		'notargfile': return, 2L^2
		else: message,'No such flag name: '+string(name)
	endcase
end

function bosstarget::target_runstring, target_run
	; if a number is entered, convert it length 6 zero-padded string
	if size(target_run, /tname) ne 'STRING' then begin
		tstr = string(long(target_run), f='(i06)')
	endif else begin
		return, target_run
	endelse

end
function bosstarget::target_dir, target_run
	if n_elements(target_run) eq 0 then begin
		on_error,2
		message,'Usage: dir=bt->target_dir(target_run)'
	endif
	dir = getenv('BOSS_TARGET')
	if dir eq '' then message,'BOSS_TARGET is not set'

	runstr = self->target_runstring(target_run)
	dir = filepath(root=dir, runstr)
	return, dir
end


function bosstarget::target_file, target_type, target_run, run, rerun, camcol, target_dir=target_dir, fpobjc=fpobjc, all=all, extra_name=extra_name, match_method=match_method, old=old, gather=gather, collate=collate, verify=verify

	if keyword_set(gather) or keyword_set(collate) or keyword_set(verify) then begin
		gorc=1
		npar = 2
	endif else begin
		gorc=0
		npar = 5
	endelse
	if n_params() lt npar then begin
		on_error,2
		message,'Usage: f=bt->target_file(target_type, target_run, run, rerun, camcol, target_dir=, /fpobjc, /old, /gather, /collate, match_method=)'
	endif

	if n_elements(target_dir) eq 0 then begin
		target_dir=self->target_dir(target_run)
	endif

	fname='bosstarget'
	if keyword_set(fpobjc) then begin
		fname += '-fpobjc'
	endif else if keyword_set(all) then begin
		fname += '-all'
	endif else if n_elements(match_method) ne 0 then begin
		mstr=repstr(match_method,'_','-')
		fname += '-'+mstr
	endif
	fname+="-"+target_type

	target_runstr = self->target_runstring(target_run)

	if not keyword_set(gorc) then begin
		fname=[fname,string(long(run),f='(i06)')]
		fname=[fname,string(long(camcol),f='(i0)')]
		if not keyword_set(old) then begin
			fname=[fname,strn(rerun)]
		endif
	endif 

	if not keyword_set(old) then fname = [fname, target_runstr]

	if keyword_set(collate) then begin
		fname = [fname,'collate']
	endif else if keyword_set(gather) then begin
		fname = [fname,'gather']
	endif else if keyword_set(verify) then begin
		fname = [fname,'verify']
	endif

	if keyword_set(extra_name) then begin
		fname = [fname,extra_name]
	endif
	fname = strjoin(fname, '-') + '.fits'

	fpath = filepath(root=target_dir, fname)
	return, fpath
end




function bosstarget::process_sweep, $
		target_type, run, rerun, camcol, nobj=nobj, $
		pars=pars, $
		used_pars=used_pars, $
		extra_logic=extra_logic, $
		_extra=_extra

	ctype=self->calibobj_type(target_type)
	sweep_file = $
		sdss_name('calibObj.'+ctype,run,camcol,rerun=rerun)

	splog,'Reading file: ',sweep_file,'[.gz]',format='(a,a,a)'
	targ = obj_new('bosstarget_'+target_type)

	objs = sweep_readobj(run, camcol, rerun=rerun, type=ctype)

	if n_tags(objs) ne 0 then begin
		nobj=n_elements(objs)
		res = targ->select(objs, pars=pars, extra_logic=extra_logic, _extra=_extra)
		used_pars = targ->pars()
	endif else begin
		nobj=0
		splog,'Failed to read file: ',sweep_file
		res = -1
	endelse

	obj_destroy, targ

	return, res
end

function bosstarget::process_fpobjc, $
		target_type, run, rerun, camcol, nobj=nobj, all=all, $
		pars=pars, $
		extra_logic=extra_logic, $
		_extra=_extra

	targ = obj_new('bosstarget_'+target_type)

	objs = sdss_readobj(run, camcol, rerun=rerun)
	
	if n_tags(objs) ne 0 then begin
		nobj=n_elements(objs)
		if keyword_set(all) then begin
			splog,'    * processing all objects'
			; this won't propagate into the outputs
			if target_type eq 'lrg' then begin
				objs.objc_type = 3
			endif else begin
				objs.objc_type = 6
			endelse
		endif

		res = targ->select(objs, pars=pars, extra_logic=extra_logic, _extra=_extra)
	endif else begin
		nobj=0
		splog,'Failed to read file: ',sweep_file
		res = -1
	endelse

	obj_destroy, targ

	return, res
end

function bosstarget::match_sweep, $
		extra_logic=extra_logic, $
		target_type, run, rerun, camcol, match_method, nobj=nobj, _extra=_extra

	if n_params() lt 5 then begin
		on_error,2
		message,'usage: res=bt->match_sweep(objs, target_type, run, rerun, camcol, match_method, _extra=)'
	endif
	ctype=self->calibobj_type(target_type)
	sweep_file = $
		sdss_name('calibObj.'+ctype,run,camcol,rerun=rerun)

	splog,'Reading file: ',sweep_file,'[.gz]',format='(a,a,a)'
	targ = obj_new('bosstarget_'+target_type)

	objs = sweep_readobj(run, camcol, rerun=rerun, type=ctype)

	if n_tags(objs) ne 0 then begin
		nobj=n_elements(objs)
		command = 'res = targ->'+match_method+'(objs, _extra=_extra)'
		if not execute(command) then begin
			message,'Could not execute command: '+command
		endif
	endif else begin
		nobj=0
		splog,'Failed to read file: ',sweep_file
		res = -1
	endelse

	obj_destroy, targ

	return, res
end




function bosstarget::make_bayes_input, struct

	if n_elements(struct) eq 0 then begin
		on_error, 2
		message,'usage: bayes_instruct=bt->make_bayes_input(struct)'
	endif

	arrval=fltarr(5)
	larrval = lonarr(5)
	inst = {$
		psfcounts: arrval, $
		psfcountserr: arrval, $
		counts_dev: arrval, $
		counts_deverr: arrval, $
		counts_exp:arrval, $
		counts_experr:arrval, $
		fracpsf: arrval, $
		m_rr_cc_psf: arrval, $
		flags: larrval,$
		flags2: larrval }	
		
	inst = replicate(inst, n_elements(struct))

	struct_assign, struct, inst, /nozero
	sdss_flux2lups, struct.psfflux, struct.psfflux_ivar, struct.psfcountserr, $
		psfcounts, psfcountserr
	inst.psfcounts = temporary(psfcounts)
	inst.psfcountserr = temporary(psfcountserr)

	sdss_flux2lups, struct.devflux, struct.devflux_ivar, struct.counts_deverr, $
		counts_dev, counts_deverr	
	inst.counts_dev = counts_dev
	inst.counts_deverr = temporary(counts_deverr)

	sdss_flux2lups, struct.expflux, struct.expflux_ivar, struct.counts_experr, $
		counts_exp, counts_experr	
	inst.counts_exp = counts_exp
	inst.counts_experr = temporary(counts_experr)


	return, inst


end

pro bosstarget::run_bayes_prob, struct, probgal, probflags

	if n_elements(struct) eq 0 then begin
		on_error, 2
		message,'usage: run_bayes_prob, struct, probgal, probflags'
	endif
	splog,'Making input'
	inst=self->make_bayes_input(struct)
	compute_bayes_prob, inst, probgal, probflags

end




function bosstarget::file_info, target_type, target_dir, target_run
	info={target_type: target_type, $
		file_front: '', $
		calibobj_type: '', $
		target_dir: target_dir, $
		target_run: target_run}


	if target_type eq 'lrg' then begin
		info.file_front = 'bosstarget-lrg'
		info.calibobj_type = 'gal'
	endif else if target_type eq 'qso' then begin
		info.file_front = 'bosstarget-qso'
		info.calibobj_type = 'star'
	endif else if target_type eq 'std' then begin
		info.file_front = 'bosstarget-std'
		info.calibobj_type = 'star'
	endif else begin
		message,'Unsupported target type: '+string(target_type)
	endelse

	return, info
end

function bosstarget::get_files_old, info, run, rerun, camcol

	ninfo = create_struct($
		info, $
		'calibobj_file', '', $
		'target_file','', $
		'target_file_fpobjc','', $
		'target_file_all', '')

	calibobj_file = sdss_name('calibObj.'+info.calibobj_type, $
		run, camcol, rerun=rerun)

	target_file = file_basename(calibobj_file)
	target_file = repstr(target_file,'calibObj',info.file_front)
	target_file = repstr(target_file,'-'+info.calibobj_type,'')
	target_file = filepath(target_file, root_dir=info.target_dir)

	ninfo.calibobj_file = calibobj_file
	ninfo.target_file = target_file
	ninfo.target_file_fpobjc = $
		repstr(target_file,'bosstarget','bosstarget-fpobjc')
	ninfo.target_file_all = repstr(target_file,'bosstarget','bosstarget-all')

	return, ninfo

end

function bosstarget::calibobj_type, target_type
	if target_type eq 'lrg' then begin
		return, 'gal'
	endif else if target_type eq 'qso' then begin
		return, 'star'
	endif else if target_type eq 'std' then begin
		return,'star'
	endif else begin
		message,'Unsupported target type: '+string(target_type)
	endelse

	return, calibobj_type
end
function bosstarget::get_files, target_type, target_run, run, rerun, camcol, old=old

	ctype = self->calibobj_type(target_type)
	calibobj_file = sdss_name('calibObj.'+ctype, run, camcol, rerun=rerun)

	target_file = self->target_file(old=old, $
		target_type, target_run, run, rerun, camcol, target_dir=target_dir)
	target_file_fpobjc = self->target_file(old=old, $
		target_type, target_run, run, rerun, camcol, target_dir=target_dir,$
		/fpobjc)
	target_file_all = self->target_file(old=old, $
		target_type, target_run, run, rerun, camcol, target_dir=target_dir,$
		/all)

	ninfo = { $
		calibobj_file: calibobj_file, $
		target_file: target_file, $
		target_file_fpobjc: target_file_fpobjc, $
		target_file_all: target_file_all}


	return, ninfo

end


function bosstarget::read, $
		target_type, target_run, run, rerun, camcol, $
		target_dir=target_dir, $
        extra_name=extra_name, $
		pars=pars, $
		reselect=reselect, $
		collate=collate, $
		columns=columns, $
		where_string=where_string, $
		filename=filename, $
		fpobjc=fpobjc, $
		all=all, $
		match_method=match_method, $
		old=old, $
		status_struct=status_struct, $
		_extra=_extra


	if n_params() lt 5 then begin
		splog,"usage: "
		splog,"  bt=obj_new('bosstarget')"
		splog,"  res = bt->read(target_type, target_run, run, rerun, camcol, target_dir=, /collate, columns=, where_string=, filename=, /fpobjc, /all, /old, match_method=, /addlups, status_struct=)"
		splog,"  In the where string, refer the structure 'str'.  e.g. "
		splog,"      str.boss_target1 gt 0 and str.ra gt 336"
		on_error, 2
		message,'Halting'
	endif

	btpars=self->pars()

	calibobj_type = self->calibobj_type(target_type)

	calibobj_file = $
		sdss_name('calibObj.'+calibobj_type, run, camcol, rerun=rerun)
	target_file = self->target_file( $
		target_type, target_run, run, rerun, camcol, target_dir=target_dir, $
        extra_name=extra_name, $
		fpobjc=fpobjc, all=all, old=old, match_method=match_method)

	if not file_test(target_file) then begin
		splog,'File not found: ',target_file,format='(a,a)'
		return,-1
	endif

	splog,'Reading target file: ',target_file,format='(a,a)'
	if btpars.result_ext ne 1 then begin
		status_struct = mrdfits(target_file, btpars.status_ext, $
			silent=0, status=rd_status)
		str = mrdfits(target_file, btpars.result_ext, $
			silent=0, status=rd_status)
	endif else begin
		str = mrdfits(target_file, btpars.result_ext, $
			/silent, status=rd_status)
	endelse
	if rd_status ne 0 then begin
		on_error, 2
		splog,'Error reading file: '+target_file
		return,-1
	endif
	if keyword_set(collate) then begin
		splog,'Collating'

		if keyword_set(all) or keyword_set(fpobjc) then begin
			co = sdss_readobj(run, camcol, rerun=rerun)
		endif else begin
			splog,'Reading calibObj file: ',calibobj_file+'[.gz]',$
				format='(a,a,a)'
			co = sweep_readobj(run, camcol, rerun=rerun, $
				type=calibobj_type)
		endelse


		wbad = where(co.id ne str.id, nbad)
		if nbad ne 0 then begin
			message,"Structures don't line up"	
		endif

		; combine the data structures
		newstr = self->struct_combine(str,co)
		strold=temporary(str)
		str=temporary(newstr)


		; attempt to re-select based on the input parameters
		; the select function must support the /reselect keyword
		if n_elements(pars) ne 0 or keyword_set(reselect) then begin
			splog,'Re-selecting with input pars'
			targ=obj_new('bosstarget_'+target_type)
			;res = targ->select(str, pars=pars, /reselect, _extra=_extra)
			res = targ->select(str, pars=pars, reselect=reselect, _extra=_extra)
			wdiff=where(res.boss_target1 ne str.boss_target1, ndiff)
			splog,'# differences found in boss_target1: ',ndiff,form='(a,i0)'

			; res will take precedence in copying
			newstr = self->struct_combine(res,co)

			str=0
			res=0
			co=0
			str=temporary(newstr)
		endif

	endif 


	; make sure to do the selection *before* we extract
	; tags, to give the user full flexibility
	if n_elements(where_string) ne 0 then begin
		w=self->where_select(str, where_string, nw)
		if nw eq 0 then begin
			return, -1
		endif
		str = str[w]
	endif

	; now extract certain columns(tags)
	if n_elements(columns) ne 0 then begin
		tstr = struct_selecttags(str, select_tags=columns)
		if size(tstr, /tname) ne 'STRUCT' then begin
			message,'None of the requested tags matched: '+$
				'['+strjoin( string(columns), ', ')+']'
		endif
		str=0
		str = temporary(tstr)
	endif

	return, str

end

function bosstarget::where_select, str, where_string, nw

	command = 'w = where('+where_string+', nw)'
	splog,'Executing where statement: "',command,'"',$
		form='(a,a,a)'
	if not execute(command) then begin
		message,'Could not execute where_string: '+string(where_string)
	endif
	return, w
end


pro bosstarget::cache_runlist, force=force, minscore=minscore
	common bosstarget_runlist_block, flrun, flrerun


	if n_elements(flrun) eq 0 or keyword_set(force) then begin

		epsilon=0.001
        if n_elements(minscore) eq 0 then minscore=0.1+epsilon
        splog,'Using PHOTO_RESOLVE: ',getenv('PHOTO_RESOLVE')
        splog, 'Cacheing window_runlist, ..,  minscore=',minscore,$
            format='(a,f)'
        window_runlist, flrun, rerun=flrerun, minscore=minscore

		return

	endif
end

pro bosstarget::runlist, flrun_out, flrerun_out, $
		minscore=minscore, force=force
	common bosstarget_runlist_block, flrun, flrerun

	if n_elements(flrun) eq 0 or keyword_set(force) then begin
		self->cache_runlist, force=force, minscore=minscore
	endif

	flrun_out=flrun
	flrerun_out=flrerun

end

pro bosstarget::split_runlist, runs2use, reruns2use, $
		nsplit=nsplit, nper=nper, $
		runs=runs, $
		force=force

	if n_elements(runs) ne 0 then begin
		self->match_runlist, runs, runs2use, reruns2use, $
			force=force
	endif else begin
		self->runlist, runs2use, reruns2use, $
			force=force
	endelse

	if n_elements(nsplit) ne 0 or n_elements(nper) ne 0 then begin
		runs2use = self->splitlist(runs2use, nsplit=nsplit, nper=nper)
		reruns2use = self->splitlist(reruns2use, nsplit=nsplit,  nper=nper)
	endif

end

function bosstarget::splitlist, list, nsplit=nsplit, nper=nper

	nlist = n_elements(list)
	if nlist eq 0 then begin
		message,'Usage: slist=bt->splitlist(list, nsplit=, nper=)'
	endif

	if n_elements(nper) ne 0 then begin
		;nsplit = (nlist/nper) + (nlist mod nper)
		nsplit = (nlist/nper) + ((nlist mod nper) gt 0)
	endif else if n_elements(nsplit) ne 0 then begin
		nper = nlist/nsplit
		;nleft = nlist mod nsplit
	endif else begin
		message,'send nsplit= or nper='
	endelse

	split_ptrlist = ptrarr(nsplit)
	
	current = 0LL
	for i=0L, nsplit-1 do begin
		if i eq (nsplit-1) then begin
			; last one, make sure we include the remainder
			split = list[current:nlist-1]
		endif else begin
			split = list[current:current+nper-1]
		endelse

		split_ptrlist[i] = ptr_new(split, /no_copy)
		current = current + nper
	endfor

	return, split_ptrlist

end




pro bosstarget::match_runlist, runs, match_runs, match_reruns, $
		force=force, minput=minput, mflrun=mflrun

	common bosstarget_runlist_block, flrun, flrerun
	self->cache_runlist, force=force

	if n_elements(runs) eq 0 then begin
		splog,'Using all runs'
		match_runs = flrun
		match_reruns = flrerun
		return
	endif

	splog,'Matching input runlist'

	rmd = rem_dup(runs)
	match, runs[rmd], flrun, minput, mflrun
	if mflrun[0] eq -1 then begin
		message,'None of input runs matched window_runlist'
	endif
	if n_elements(mflrun) ne n_elements(rmd) then begin
		message,'Some of the input runs did not match',/inf
	endif

	splog, 'Using ',n_elements(mflrun),'/',n_elements(flrun),' runs'
	match_runs = flrun[mflrun]
	match_reruns = flrerun[mflrun]

end



function bosstarget::default_where_string, target_type, $
		typecut=typecut, $
		anyresolve=anyresolve, $
		run_primary=run_primary, $
		match_method=match_method, _extra=_extra

	if n_elements(target_type) eq 0 then begin
		splog,'Usage: default_where_string, target_type, /typecut, /anyresolve, /run_primary, match_method='
		splog,"   target_type in ('std','lrg','qso')"
		splog,"Requires boss_target1 and resolve_status defined in structure"
		on_error, 2
		message,'Halting'
	endif

	pars=self->pars()

	primary = strn(sdss_flagval('resolve_status','survey_primary'))
	rprimary = strn(sdss_flagval('resolve_status','run_primary'))

	if n_elements(match_method) ne 0 then begin
		; Were we just doing a match?
		; if so just get everything that is primary
		ws='((str.resolve_status and '+primary+') ne 0)'
	endif else begin

		if target_type eq 'std' then begin
			ws = '(str.boss_target1 gt 0)'
		endif else if target_type eq 'lrg' then begin
			flags = ['gal_loz', $
				     'gal_cmass', $
					 'gal_cmass_sparse']

			orflags = sdss_flagval('boss_target1', flags)
			orflags_str = string(orflags,f='(i0)')

			ws='((str.boss_target1 and '+orflags_str+') ne 0)'

			if keyword_set(typecut) then begin
				ws = ws + ' and (str.objc_type eq 3)'
			endif

            if sdss_flagexist('boss_target1','gal_ifiber2_faint') then begin
                faintflag = sdss_flagval('boss_target1','gal_ifiber2_faint')
                faintflag_str = string(faintflag,f='(i0)')
                ws = ws + ' and ( (str.boss_target1 and '+faintflag_str+') eq 0)'
            endif

		endif else if target_type eq 'qso' then begin

			lohiz= $
			  string(sdss_flagval('boss_target1','qso_known_lohiz'), f='(I0)')

			orflagnames=[$
				'qso_core_main', $ ; trimmed qso_like 
				'qso_bonus_main', $ ; nn combinator
				'qso_known_midz',$
				'qso_first_boss']
			orflags = sdss_flagval('boss_target1', orflagnames)

			orflags_str = string(orflags,f='(i0)')

            suppz_flags = sdss_flagval('boss_target1', 'qso_known_suppz')
            suppz_str = string(suppz_flags,f='(i0)')

			;ws='(((str.boss_target1 and '+lohiz+') eq 0) and ((str.boss_target1 and '+orflags_str+') ne 0))'

			ws='((((str.boss_target1 and '+lohiz+') eq 0)' + $
				' and ((str.boss_target1 and '+orflags_str+') ne 0))'+ $
                ' or ((str.boss_target1 and '+suppz_str+') ne 0))'

			if keyword_set(typecut) then begin
				ws = ws + ' and (str.objc_type eq 6)'
			endif
		endif

		if keyword_set(run_primary) then begin
			print,'Using run_primary'
			ws=ws+' and ((str.resolve_status and '+rprimary+') ne 0)'
		endif else if not keyword_set(anyresolve) then begin
			ws=ws+' and ((str.resolve_status and '+primary+') ne 0)'
		endif

	endelse

	return, ws

end

pro bosstarget::gather_partial, target_type, target_run, jobnum, $
		runs=runs, $
		nper=nper, $
		pars=pars, reselect=reselect, extra_name=extra_name, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		everything=everything, $
		fpobjc=fpobjc, $
		combine=combine,ascii=ascii, $ ; these with regard to combine only
		match_method=match_method, $
		outfile=outfile, $
		noverify=noverify, $
		add_inchunk=add_inchunk, $
		_extra=_extra

	if n_elements(target_type) eq 0 or (n_elements(jobnum) eq 0 and not keyword_set(combine)) then begin
		on_error, 2
		message,'bt->gather_partial, target_type, target_run, jobnum, nper=2, where_string=, /everything, /fpobjc, /combine, /ascii, extra_name=, match_method=, outfile=, _extra=', /inf
		message,'Send /combine to combine the individual files.  ',/inf
		message,'  /ascii is with regard to the combined file only'
	endif

	btpars=self->pars()

	if n_elements(nper) eq 0 then begin
		nper=2
	endif
	
	if not keyword_set(combine) then begin


		self->split_runlist, runptrs, rerunptrs, nper=nper, $
			runs=runs, /force
		njobs=n_elements(runptrs)

		runs = *runptrs[jobnum]
		reruns = *rerunptrs[jobnum]
		ptr_free, runptrs, rerunptrs

		splog, 'Using runs: ',runs


		if n_elements(outfile) eq 0 then begin
			outfile=self->target_file(target_type, target_run, $
				extra_name=extra_name, $
				fpobjc=fpobjc, /collate, $
				match_method=match_method)
			outfile = $
				repstr(outfile,'.fits','-'+string(jobnum,f='(i03)')+'.fits')
		endif
		splog,'outfile: ',outfile,format='(a,a)'

		self->gather2file, target_type, target_run, $
			runs=runs, $
            pars=pars, $
            reselect=reselect, $
            extra_name=extra_name, $
			where_string=where_string, $
			add_where_string=add_where_string, $
			everything=everything, $
			columns=columns, /fast,  $
			fpobjc=fpobjc, $
			match_method=match_method, $
			noverify=noverify, $
			outfile=outfile, $
            _extra=_extra

	endif else begin

		splog,'Combining various collated files'
		if n_elements(where_string) ne 0 then begin
			splog,'Combining with where string "'+where_string+'"'
		endif

		if not keyword_set(noverify) then begin
			splog,'First verifying all outputs'

			nbad = self->verify(target_type, target_run, $
				runs=runs, $
				fpobjc=fpobjc, match_method=match_method, $
				extra_name=extra_name)
			if nbad ne 0 then begin
				splog,'Found bad results: ',nbad,form='(a,i0)'
				message,'Halting'
			endif
		endif

		self->split_runlist, runptrs, rerunptrs, nper=nper, $
			runs=runs, /force
		njobs=n_elements(runptrs)
		ptr_free, runptrs, rerunptrs

		; combine all the partials
		outfile=self->target_file(target_type, target_run, $
			extra_name=extra_name, $
			fpobjc=fpobjc, match_method=match_method, /collate)


		; Got to roll my own since we don't have sdssidl mrdfits_multi
		flist=strarr(njobs)

		status_ptrlist=ptrarr(njobs)
		res_ptrlist=ptrarr(njobs)
		for job=0L, njobs-1 do begin
			flist[job] = $
				repstr(outfile,'.fits','-'+string(job,f='(i03)')+'.fits')
			splog,'Reading: ',flist[job],form='(a,a)'
			st=mrdfits(flist[job],btpars.status_ext, status=stst)

			err=string($
				'Failed to read ',flist[job],$
				' ext=',btpars.status_ext,form='(a,a,a,i0)')
			if stst ne 0 then begin
				splog,err
			endif else begin
				status_ptrlist[job] = ptr_new(st, /no_copy)
			endelse
			err=string($
				'Failed to read ',flist[job],$
				' ext=',btpars.result_ext,form='(a,a,a,i0)')
			res=mrdfits(flist[job],btpars.result_ext, status=tst)
			if tst ne 0 then begin
				splog,err
			endif else begin
				if n_elements(where_string) ne 0 then begin
					w=self->where_select(res,where_string,nw)
					splog,'Keeping ',nw,'/',n_elements(res),form='(a,i0,a,i0)'
					if nw ne 0 then begin
						res=res[w]
					endif else begin
						res=0
					endelse
				endif
				if n_tags(res) ne 0 then begin
					res_ptrlist[job] = ptr_new(res, /no_copy)
				endif
			endelse


		endfor
		tot = combine_ptrlist(res_ptrlist)
		status_tot = combine_ptrlist(status_ptrlist)

		if n_tags(tot) eq 0 then message,'Failed to read'

		; now just keep one,verify above makes sure they are the same
		status_struct = status_tot[0]

		if keyword_set(add_inchunk) then begin
			bq=obj_new('bosstarget_qso')
			if keyword_set(add_inchunk) then begin
				; this will re-do the inchunk tests
				bq->add_inchunk, tot
			endif
		endif

		ntot=n_elements(tot)
		if keyword_set(ascii) then begin
			outfile = repstr(outfile, '.fits', '-tab.st')
			splog,'Writing ',ntot,' to file: ',outfile,format='(a,i0,a)'
			; requires sdssidl
			write_idlstruct, tot, outfile, /ascii, hdrstruct=status_struct
		endif else begin
			splog,'Writing status to file: ',outfile,format='(a,a)'
			mwrfits, status_struct, outfile, /create
			splog,'Writing ',ntot,' to file: ',outfile,format='(a,i0,a)'
			mwrfits, tot, outfile
		endelse

	endelse

end








function bosstarget::read_collated, target_type, target_run,  $
		target_dir=target_dir, $
		extra_name=extra_name, $
		ascii=ascii, $
		all=all, fpobjc=fpobjc, match_method=match_method, $
		status_struct=status_struct, file=file

	if n_elements(target_type) eq 0 or n_elements(target_run) eq 0 then begin
		on_error, 2
		message,'Usage: str=bt->read_collated(target_type, target_run, target_dir=, /all, /fpobjc, match_method=, status_struct=)', /inf
		message,'Halting'
	endif

	pars=self->pars()
	file=self->target_file(target_type, target_run, $
		target_dir=target_dir, all=all, fpobjc=fpobjc, /collate, $
		extra_name=extra_name, $
		match_method=match_method)
	splog,'Reading file: ',file,format='(a,a)'
	if keyword_set(ascii) then begin
		file = repstr(file, '.fits', '-tab.st')
		command=' st=read_idlstruct(file,hdr=status_struct)'
		if not execute(command) then begin
			message,"You probably don't have sdssidl stup"
		endif
	endif else begin
		status_struct = mrdfits(file, pars.status_ext)
		st=mrdfits(file,pars.result_ext)
	endelse
	return, st
end
pro bosstarget::gather_usage, proc=proc

	if keyword_set(proc) then begin
		front="bt->gather2file, "
		back=""
	endif else begin
		front="targets = bt->gather("
		back=")"
	endelse

	splog,"usage: "
	splog,"  bt=obj_new('bosstarget')"
	splog,"  "+front+"target_type, target_dir=, runs=all, logfile=stdout, columns=, where_string=, /everything, /fast"+back+", /noverify"
	splog,"  In the where string, refer the structure 'str'.  e.g. "
	splog,"      str.boss_target1 gt 0 and str.ra gt 336"
	splog,"  /fast uses twice the memory but only does one pass"
end
pro bosstarget::gather2file, target_type, target_run, $
		target_dir=target_dir, $
		runs=runs, camcols=camcols, nomatch=nomatch, $
		pars=pars, reselect=reselect, extra_name=extra_name, $
		logfile=logfile, $
		columns=columns, $
		where_string=where_string, everything=everything, $
		add_where_string=add_where_string, $
		fast=fast, $
		all=all, fpobjc=fpobjc, match_method=match_method, $
		noverify=noverify, $
		outfile=outfile, _extra=_extra

	; this procedural version writes to a file

	if n_elements(target_type) eq 0 or n_elements(target_run) eq 0 then begin
		self->gather_usage,/proc
		on_error, 2
		message,'Halting'
	endif

	if n_elements(outfile) eq 0 then begin
		outfile=self->target_file(target_type, target_run, $
			target_dir=target_dir, all=all, fpobjc=fpobjc, $
			extra_name=extra_name, $
			match_method=match_method, $
			/gather, /collate)
	endif
	splog,'Will write to output file: ',outfile,format='(a,a)'

	targets = self->gather($
		target_type, target_run, $
		target_dir=target_dir, $
        extra_name=extra_name, $
		runs=runs, camcols=camcols, nomatch=nomatch, $
		pars=pars, reselect=reselect, $
		logfile=logfile, columns=columns, $
		where_string=where_string, everything=everything, $
		add_where_string=add_where_string, $
		fast=fast, $
		all=all, fpobjc=fpobjc,match_method=match_method, $
		noverify=noverify, $
		status_struct=status_struct, _extra=_extra)

	if n_tags(targets) eq 0 then begin
		splog,'No targets found, not writing file: ',outfile,form='(a,a)'
		return
	endif

	; in order to pass the verify step, the versions must all match so we
	; can just copy in from the first
	st=status_struct[0]

	st.run=-9999
	st.rerun='-9999'
	st.camcol='-9999'
	st.output_file=outfile
	st.date = systime()
	st.nobj=-9999
	st.nres=total(status_struct.nres, /int)
	st.extra_logic = '  '
	st.process_flags = 0

	splog,'Writing to output file: ',outfile,format='(a,a)'
	mwrfits, st, outfile, /create
	mwrfits, targets, outfile

end

function bosstarget::gather, target_type, target_run, $
		target_dir=target_dir, $
        extra_name=extra_name, $
		runs=runs, camcols=camcols, nomatch=nomatch, $
		pars=pars, reselect=reselect, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		anyresolve=anyresolve, $
		run_primary=run_primary, $
		everything=everything, $
		logfile=logfile, columns=columns, $
		fast=fast, $ ; this is the only option now
		all=all, fpobjc=fpobjc, $
		match_method=match_method, $
		noverify=noverify, $
		nocollate=nocollate, $
		status_struct=status_struct, $
		_extra=_extra



	if n_elements(target_type) eq 0 or n_elements(target_run) eq 0 then begin
		self->gather_usage
		on_error, 2
		message,'Halting'
	endif

	; in this case we assume we already kept everything in the output struct
	if keyword_set(match_method) then collate=0 else collate=1
	if keyword_set(nocollate) then collate=0

	if not keyword_set(noverify) and not keyword_set(nomatch) then begin
		nbad = self->verify(target_type, target_run, $
			target_dir=target_dir, runs=runs, camcols=camcols, $
            extra_name=extra_name, $
			logfile=logfile, $
			all=all, fpobjc=fpobjc, $
			match_method=match_method)
		if nbad ne 0 then begin
			splog,'Found bad results: ',nbad,form='(a,i0)'
			message,'Halting'
		endif
	endif

	if n_elements(where_string) eq 0 and not keyword_set(everything) then begin
		where_string = self->default_where_string(target_type,$
												  run_primary=run_primary, $
			                                      anyresolve=anyresolve)
	endif
	if n_elements(add_where_string) ne 0 then begin
		; you have to deal with parens yourself
		where_string += ' ' + add_where_string 
	endif

	if n_elements(where_string) ne 0 then begin
		splog,'Gathering with where string: "'+where_string+'"'
	endif
	; begin logging
	splog, filename=logfile

	; Get some environment variables
	resdir = getenv('PHOTO_RESOLVE')
	if NOT keyword_set(resdir) then begin
		message,'Set PHOTO_RESOLVE'
	endif

	if not keyword_set(nomatch) then begin
		self->match_runlist, runs, runs2use, reruns2use
	endif else begin
		if n_elements(runs) eq 0 then begin
			message,'send runs if /nomatch is set'
		endif
		runs2use=runs
		splog,'Assuming reruns are 301'
		reruns2use = replicate(301,n_elements(runs))
	endelse
  
	stime0 = systime(1)

	nrun = n_elements(runs2use)

	if n_elements(logfile) ne 0 then begin
		splog, 'Log file ' + logfile + ' opened ' + systime()
	endif
	splog, 'Working with Nrun=', nrun
	spawn, 'uname -a', uname
	splog, 'Uname: ' + uname[0]


	;---- For loop goes through all the runs
	;---- (first count total number)

	ptrlist=ptrarr(nrun*6)
	if arg_present(status_struct) then begin
		sptrlist=ptrarr(nrun*6)
		do_status=1
	endif else begin
		do_status=0
	endelse

	itot=0L
	for irun=0L, nrun-1L do begin
		run = runs2use[irun]
		rerun = reruns2use[irun]
		for camcol=1, 6 do begin

			tstr= self->read(target_type, target_run, run, rerun, camcol, $
				target_dir=target_dir,$
                extra_name=extra_name, $
				pars=pars, reselect=reselect, $
				where_string=where_string, collate=collate, $
				match_method=match_method, $
				columns=columns,$
				all=all, fpobjc=fpobjc,  $
				status_struct=tstatus_struct, $
				_extra=_extra)

			if(n_tags(tstr) gt 0) then begin
				splog,'Keeping ',n_elements(tstr),' objects', $
					format='(A,I0,A)'

				ptrlist[itot] = ptr_new(tstr,/no_copy)

				if do_status then begin
					sptrlist[itot] = ptr_new(tstatus_struct,/no_copy)
				endif

				itot = itot+1

			endif else begin
				splog,'Keeping zero objects in camcol: ',camcol,$
					form='(a,i0)'
			endelse

		endfor
	endfor

	outst = combine_ptrlist(ptrlist)
	if do_status then begin
		status_struct=combine_ptrlist(sptrlist)
	endif

	if n_tags(outst) ne 0 then begin
		ntot=n_elements(outst)
	endif else begin
		ntot=0
	endelse
	splog,'Keeping total of ',ntot,' objects', format='(A,I0,A)'
	splog,'Total time = ', systime(1)-stime0, ' seconds', format='(a,f6.0,a)'
	splog,'Successful completion at ' + systime()
	splog,/close

	return, outst
end 

function bosstarget::verify, target_type, target_run, writebad=writebad, $
		target_dir=target_dir, $
		runs=runs, camcols=camcols, $
		extra_name=extra_name, $
		logfile=logfile, $
		all=all, fpobjc=fpobjc, $
		match_method=match_method


	if n_elements(target_type) eq 0 or n_elements(target_run) eq 0 then begin
		splog,'Usage: nbad = bt->verify(target_type, target_run, target_dir=, /all, /fpobjc, match_method=)'
		on_error, 2
		message,'Halting'
	endif

	pars=self->pars()
	if n_elements(camcols) eq 0 then camcols=[1,2,3,4,5,6]

	; begin logging
	splog, filename=logfile

	self->match_runlist, runs, runs2use, reruns2use, /force
  
	stime0 = systime(1)

	nrun = n_elements(runs2use)

	if n_elements(logfile) ne 0 then begin
		splog, 'Log file ' + logfile + ' opened ' + systime()
	endif
	splog, 'Verifying Nrun=', nrun

	ptrlist=ptrarr(nrun*6)
	ii=0LL
	for irun=0L, nrun-1L do begin
		run = runs2use[irun]
		rerun = reruns2use[irun]
		for icamcol=0L, n_elements(camcols)-1 do begin
			camcol=camcols[icamcol]

			target_file = self->target_file( $
				target_type, target_run, run, rerun, camcol, $
				target_dir=target_dir, $
				extra_name=extra_name, $
				fpobjc=fpobjc, all=all, match_method=match_method, old=old)
            print,target_file

			if not file_test(target_file) then begin
				splog,'target file missing: ',target_file,form='(a,a)'
				message,'Fatal error: halting'
			endif

			tstatus=mrdfits(target_file, pars.status_ext, /silent, status=ts)

			if ((tstatus.process_flags and self->processing_flag('notargfile')) ne 0 $
					or ts ne 0) then begin

				splog,'Problem reading target file: ',target_file,form='(a,a)'
				; maybe something happened between then and now
				tstatus.process_flags += self->processing_flag('notargfile')
			endif

			ptrlist[ii] = ptr_new(tstatus, /no_copy)

			ii+=1
		endfor
	endfor

	status_struct = combine_ptrlist(ptrlist)
	;help,status_struct,/str


	; only write a file if problems were found
	wbad=where(status_struct.process_flags ne 0, nbad)
	if nbad ne 0 then begin
		splog,'Found problems with ',nbad,' files', form='(a,i0,a)'
		if keyword_set(writebad) then begin
			badfile=self->target_file(target_type, target_run, /verify, $
				target_dir=target_dir, all=all, fpobjc=fpobjc, $
				extra_name=extra_name, $
				match_method=match_method)
			splog,'Writing verify file: ',badfile,form='(a,a)'
			mwrfits, status_struct, badfile, stname='BOSSTARGET_STATUS', $
				/create
		endif
	endif else begin
		splog,'No problems found with status structures'
	endelse

	; version problems are a fatal error, an exception will be thrown
	self->check_version_tags, status_struct

	return, nbad
end

pro bosstarget::check_version_tags, status_struct
	; run through all the relevant version tags and make sure they are 
	; equal.  This is fatal and an exception is thrown
	tags=strlowcase(tag_names(status_struct))
	tagcheck = ['bosstarget_v', 'photoop_v', 'idlutils_v', $
		'target_run', 'target_type', 'photo_sweep', 'photo_resolve', $
		'photo_calib']
	for i=0L, n_elements(tagcheck)-1 do begin
		w=where(tags eq tagcheck[i], nw)
		if nw eq 0 then message,'Tag not found: '+tagcheck[i]


		unique_tag = rem_dup(status_struct.(w))
		if n_elements(unique_tag) ne 1 then begin
			message,"Not all '"+tagcheck[i]+"' tags are the same!",/inf
            message,'Unique values: ',/inf
            print,status_struct[unique_tag].(w)
            message,'files',/inf
            print,status_struct[unique_tag].output_file
            message,'halting'
		endif
	endfor
end




function bosstarget::read_boss_survey
	dir=getenv("BOSSTARGET_DIR")
	if dir eq '' then message,'BOSSTARGET_DIR not set'
	file = filepath(root=dir, sub=['data','geometry'], 'boss_survey.par')

	splog,'Reading file: ',file,form='(a,a)'
	bounds = yanny_readone(file,/anon)
	if n_tags(bounds) eq 0 then message,'Failed to read boss_survey'
	return, bounds
end


function bosstarget::chunk_polygon_file, chunk, bounds=bounds
	btdir=getenv('BOSSTARGET_DIR')

	if strn(chunk[0]) eq 'boss' then begin
		; whole survey
		file=filepath(root=btdir,sub=['data','geometry'],'boss_survey.ply')

	endif else if strn(chunk[0]) eq 'ngc' then begin
		; whole of ngc
		file='boss_survey_ngc.ply'
		file=filepath(root=btdir,sub=['data','geometry'], file)

	endif else if strn(chunk[0]) eq 'sgc' then begin
		; whole of sgc
		file='boss_survey_sgc.ply'
		file=filepath(root=btdir,sub=['data','geometry'], file)

	endif else if strn(chunk[0]) eq 'bossgood' then begin
		; ngc with some non-photometric regions cut
		file='boss_survey_good.ply'
		file=filepath(root=btdir,sub=['data','geometry'], file)

	endif else if strn(chunk[0]) eq 'ngcgood' then begin
		; ngc with some non-photometric regions cut
		file='boss_survey_ngc_good.ply'
		file=filepath(root=btdir,sub=['data','geometry'], file)

	endif else if strn(chunk[0]) eq 'ngcgood2' then begin
		; ngc with some non-photometric regions cut and some
        ; other high density qso regions cut
		file='boss_survey_ngc_good2.ply'
		file=filepath(root=btdir,sub=['data','geometry'], file)

	endif else if strn(chunk[0]) eq 'ngc-large' then begin
		file=filepath(root=btdir,sub=['data','geometry'],'ngc-large.ply')

	endif else if strn(chunk[0]) eq 'ngc-small' then begin
		file=filepath(root=btdir,sub=['data','geometry'],'ngc-small.ply')

	endif else if strn(chunk[0]) eq 'sgc-small1' then begin
		file=filepath(root=btdir,sub=['data','geometry'],'sgc-small1.ply')

	endif else begin

		dir=getenv('BOSSTILELIST_DIR')
		if dir eq '' then message,'bosstilelist is not setup'
		bosschunk=string('boss',chunk,f='(a,i0)')

		if keyword_set(bounds) then begin
			fname='trim-'+bosschunk+'.ply'
			file=filepath(root=dir, sub=['inputs',bosschunk], fname)
		endif else begin
			fname = 'geometry-'+bosschunk+'.ply'
			file = filepath(root=dir,sub=['outputs',bosschunk],fname)
		endelse
	endelse

	return, file
end

function bosstarget::chunk_polygon_read, chunk, bounds=bounds, verbose=verbose

	if n_elements(chunk) eq 0 then begin
		message,'poly=bt->chunk_polygon_read(chunk,/bounds,/verbose)'
	endif

	for i=0L, n_elements(chunk)-1 do begin
		poly_file=self->chunk_polygon_file(chunk[i], bounds=bounds)

		if not file_test(poly_file) then begin
			message,'File not found: '+poly_file
		endif
		if keyword_set(verbose) then begin
			print,'reading polygons: ',poly_file
		endif
		if strpos(poly_file,'fits') ne -1 then begin
			read_fits_polygons, poly_file, tpolygons
		endif else begin
			read_mangle_polygons, poly_file, tpolygons, poly_ids
		endelse

		if n_tags(polygons) eq 0 then begin
			polygons = tpolygons
		endif else begin
			polygons = [polygons, tpolygons]
		endelse
	endfor

	return, polygons
end

function bosstarget::is_in_chunk, chunk, ra, dec, bounds=bounds, area=area, verbose=verbose

	; return an array, 1 for all objects in the chunk

	polygons=self->chunk_polygon_read(chunk, bounds=bounds, verbose=verbose)
	inchunk=is_in_window(polygons, ra=ra, dec=dec)
	area = total(polygons.str)*(180d/!dpi)^2
	destruct_polygon, polygons

	return, inchunk
end


function bosstarget::snap_balkanize_unify, ply

    bu=obj_new('bosstarget_util')
	plyfile=bu->tmpfile(tmpdir='/tmp',prefix='geom-',suffix='.ply')
	snapfile=bu->tmpfile(tmpdir='/tmp',prefix='snap-',suffix='.ply')
	balkanfile=bu->tmpfile(tmpdir='/tmp',prefix='balkan-',suffix='.ply')
	unifyfile=bu->tmpfile(tmpdir='/tmp',prefix='unify-',suffix='.ply')

	write_mangle_polygons, plyfile, ply
	spawn, 'snap '+plyfile+' '+snapfile
	spawn, 'balkanize '+snapfile+' '+balkanfile
	spawn, 'unify '+balkanfile+' '+unifyfile

	read_mangle_polygons, unifyfile, newply
	return, newply

end

function bosstarget::_make_ngc_small_mask
	cetarange = [15,15+14.14]
	clamrange = [-7.07,7.07]
	cb = cel_block(cetarange, clamrange)
	return, cb
end

pro bosstarget::make_ngc_small_mask
	file='~/tmp/ngc-small.ply'
	cb = self->_make_ngc_small_mask()	
	print,'writing to file: ',file
	write_mangle_polygons, file, cb
	destruct_polygon, cb
end

pro bosstarget::plot_nonphoto_u, type, run, str=str
	if n_tags(str) eq 0 then begin
		str=self->read_collated(type,run)
	endif

	dir=filepath(root=getenv('BOSS_TARGET'),sub=['esheldon','tmp'],'nonphoto')
	file=filepath(root=dir,'ngc-'+type+'-nonphoto-'+run+'.eps')

    regions = ['sgc','ngc']

    dir=filepath(root=getenv('BOSS_TARGET'),sub=['esheldon','tmp'],'nonphoto')
    if not file_test(dir) then begin
        file_mkdir, dir
    endif
    file=filepath(root=dir,type+'-nonphoto-'+run+'.eps')

    photoflag = sdss_flagval('calib_status','photometric')
    begplot,file,/color

    mxtitle=textoidl('\lambda_c')
    mytitle=textoidl('\eta_c')
    erase 
    multiplot, [1,2], mytitle=mytitle, mxtitle=mxtitle, $
        mytitsize=2, mxtitsize=2, $
        mxtitoffset=1, mytitoffset=1
    for i=0L, n_elements(regions)-1 do begin
        region=regions[i]

        print,'region: ',region
        ply = self->chunk_polygon_read(region)
        inwin = is_in_window(ply, ra=str.ra, dec=str.dec)

        wall=where(inwin)
        clogic = (str.calib_status[0] and photoflag) eq 0
        wbadu = where(inwin and clogic)

        eq2csurvey, str.ra, str.dec, clam, ceta


        xrange = [-70,70]
        if region eq 'ngc' then begin
            yrange=[-40,40]
        endif else begin
            yrange = [110,170]
        endelse

        plot, clam[wall], ceta[wall], psym=3, $
            xrange=xrange, xstyle=3, $
            yrange=yrange, ystyle=3
        pplot,/over,clam[wbadu],ceta[wbadu],color='red',psym=3

        if i eq 0 then begin
            plegend, [type+' all','nonphoto u'], psym=8, color=['black','red'], $
                /right, charsize=1
            multiplot
        endif

    endfor
    multiplot,/reset
    endplot, /trim, /png, dpi=250

end


pro bosstarget::make_ngc_mask, str, inwin=inwin
    if n_elements(type) eq 0 then type='qso'
    if n_elements(run) eq 0 then run='2010-08-19'
	if n_tags(str) eq 0 then begin
		str=self->read_collated(type,run)
	endif

    allply = self->chunk_polygon_read('ngc')
	if n_elements(inwin) eq 0 then begin
        inwin = is_in_window(allply, ra=str.ra, dec=str.dec)
	endif

	wall=where(inwin)
	wbadu = where($
		inwin $
		and (str.calib_status[0] and sdss_flagval('calib_status','photometric')) eq 0)

	eq2csurvey, str.ra, str.dec, clam, ceta

	dir=filepath(root=getenv('BOSS_TARGET'),sub=['esheldon','tmp'],'badmask')
    if not file_test(dir) then begin
        file_mkdir, dir
    endif
	file=filepath(root=dir,'ngc-'+type+'-bad-boxes-'+run+'.eps')
	begplot,file,xsize=15,ysize=10,/color
	plot, clam[wall], ceta[wall], psym=3, $
		yrange=[-37,-10], ystyle=3, $
		xrange=[-70,70], xstyle=3, $
		xtitle=textoidl('\lambda_c'), $
		ytitle=textoidl('\eta_c')
	pplot,/over,clam[wbadu],ceta[wbadu],color='red',psym=3



	; ordered from bottom to top in eta

	thick=1.5
	color='blue'


	lamrange1 = [-66, -62.3]
	etarange1 = [-36.0, -35.6]

	plot_box, lamrange1[0],lamrange1[1],etarange1[0],etarange1[1], color=color, thick=thick

	; these two have overlapping eta ranges.
	lamrange2 = [-66, -30.5]
	etarange2 = [-35.6, -35.1]
	plot_box, lamrange2[0],lamrange2[1],etarange2[0],etarange2[1], color=color, thick=thick

	lamrange3 = [-18.8, -14.0]
	etarange3 = [-35.5, -35.3]
	plot_box, lamrange3[0],lamrange3[1],etarange3[0],etarange3[1], color=color, thick=thick

	lamrange4 = [-33.0, -30.5]
	etarange4 = [-30.8, -30.4]
	plot_box, lamrange4[0],lamrange4[1],etarange4[0],etarange4[1], color=color, thick=thick

	lamrange5 = [3.5,57.0]
	etarange5 = [-27.9, -27.55]
	plot_box, lamrange5[0],lamrange5[1],etarange5[0],etarange5[1], color=color, thick=thick

    lamrange6 = [-9.0,-5.0]
    etarange6 = [-16.15,-13.7]
	plot_box, lamrange6[0],lamrange6[1],etarange6[0],etarange6[1], color=color, thick=thick


	endplot,/trim,/png,dpi=250


    ; these are wider than the survey area, which we will allow 
    ; cel_block to trim
    bs = self->read_boss_survey()


	etamin=-40
	etamax=45

	lammin=-66
	lammax=63

    ;etamin = min(bs.cetamin)    - 0.5
    ;etamax = max(bs.cetamax)    + 0.5
    ;lammin = min(bs.clambdamin) - 0.5
    ;lammax = max(bs.clambdamax) + 0.5


	; generate a new footprint, missing those areas.  I think there is
	; probably a better way to do this

	; Use the fact that cel_block will clip to the sdss3 region
	; start under the true bottom and grow to under first polygon
	add_arrval, cel_block([etamin,etarange1[0]], [lammin,lammax]), ply

	; now just exclude the bit of lambda range we don't want
	add_arrval, cel_block(etarange1, [lamrange1[1], lammax]), ply

	; now a very thin strip starting at the end of 2 to the far right, 
	; but just going up to the tiny mask
	add_arrval, cel_block([etarange2[0],etarange3[0]],[lamrange2[1],lammax]), ply

	; now the bit in between 2 and 3
	add_arrval, cel_block(etarange3, [ lamrange2[1], lamrange3[0] ]), ply
	; and between the tiny bit and the end
	add_arrval, cel_block(etarange3, [ lamrange3[1], lammax]), ply

	; now from top of tiny strip to top of number 2 avoiding lam range in 2
	add_arrval, cel_block( [etarange3[1],etarange2[1]], [lamrange2[1], lammax]), ply


	; now up to the small box
	add_arrval, cel_block( [etarange2[1], etarange4[0]], [lammin,lammax]), ply

	; now left side of box
	add_arrval, cel_block( etarange4, [lammin,lamrange4[0]]), ply
	; now right side of box
	add_arrval, cel_block( etarange4, [lamrange4[1], lammax]), ply


	; now from top of little box to bottom of the upper right strip
	add_arrval, cel_block( [etarange4[1], etarange5[0]], [lammin,lammax] ), ply

	; left side of upper right strip
	add_arrval, cel_block( etarange5, [lammin,lamrange5[0]] ), ply

	; now on up to the large box
	add_arrval, cel_block( [etarange5[1], etarange6[0]], [lammin,lammax]), ply
	; now left side of large box
	add_arrval, cel_block( etarange6, [lammin,lamrange6[0]]), ply
	; now right side of large box
	add_arrval, cel_block( etarange6, [lamrange6[1], lammax]), ply

	; now on up to the top
	add_arrval, cel_block( [etarange6[1], etamax], [lammin,lammax]), ply


    ; add a block for the SGC
	;add_arrval, cel_block( [100,170], [lammin,lammax]), ply


	newply = self->snap_balkanize_unify(ply)
	destruct_polygon, ply
	;newply=ply


	file=filepath(root=dir,'ngc-'+type+'-badmask-'+run+'.eps')
	begplot,file,/color, xsize=11,ysize=8.5

    inwin_new=is_in_window(newply, ra=str[wall].ra, dec=str[wall].dec)
    wnew = where(inwin_new, comp=wout)

    ; ngc
    plot, clam[wall], ceta[wall], psym=3, $
        xrange=[-70,70], xstyle=3, $
        yrange=[-50,50], ystyle=3, $
        xtitle=textoidl('\lambda_c'), $
        ytitle=textoidl('\eta_c')

    oplot, clam[wall[wout]], ceta[wall[wout]], psym=3, color=c2i('red')

	endplot,/trim,/png, dpi=130

	
	plyfile = file_basename(self->chunk_polygon_file('ngcgood2'))
	plyfile = filepath(root=dir,plyfile)



	print,'writing new polygon file: ',plyfile
	write_mangle_polygons, plyfile, newply
	destruct_polygon, newply

end



pro bosstarget::make_badamp_mask, str=str, inwin=inwin, run=run, type=type
    ; this one just blocks the bad amplifiers, see
    ; make bad ngc mask for this plus additional cutouts
    if n_elements(type) eq 0 then type='qso'
    if n_elements(run) eq 0 then run='2010-08-19'
	if n_tags(str) eq 0 then begin
		str=self->read_collated(type,run)
	endif

    allply = self->chunk_polygon_read('boss')
	if n_elements(inwin) eq 0 then begin
		;inwin = self->is_in_chunk('ngc',str.ra,str.dec)
		;inwin = self->is_in_chunk('boss',str.ra,str.dec)
        inwin = is_in_window(allply, ra=str.ra, dec=str.dec)
	endif

	wall=where(inwin)
	wbadu = where($
		inwin $
		and (str.calib_status[0] and sdss_flagval('calib_status','photometric')) eq 0)

	eq2csurvey, str.ra, str.dec, clam, ceta

	dir=filepath(root=getenv('BOSS_TARGET'),sub=['esheldon','tmp'],'nonphoto')
    if not file_test(dir) then begin
        file_mkdir, dir
    endif
	;file=filepath(root=dir,'ngc-qso-nonphoto.eps')
	;file=filepath(root=dir,'ngc-nonphoto.eps')
	file=filepath(root=dir,'ngc-'+type+'-nonphoto-boxes-'+run+'.eps')
	begplot,file,xsize=15,ysize=5,/color
	;plotrand, clam[wall], ceta[wall], psym=3, $
	;	yrange=[-37,-26], ystyle=3
	plot, clam[wall], ceta[wall], psym=3, $
		yrange=[-37,-26], ystyle=3, $
		xrange=[-70,70], xstyle=3, $
		xtitle=textoidl('\lambda_c'), $
		ytitle=textoidl('\eta_c')
	pplot,/over,clam[wbadu],ceta[wbadu],color='red',psym=3



	; ordered from bottom to top in eta

	thick=1.5
	color='blue'


	lamrange1 = [-66, -62.3]
	etarange1 = [-36.0, -35.6]

	plot_box, lamrange1[0],lamrange1[1],etarange1[0],etarange1[1], color=color, thick=thick

	; these two have overlapping eta ranges.
	lamrange2 = [-66, -30.5]
	etarange2 = [-35.6, -35.1]
	plot_box, lamrange2[0],lamrange2[1],etarange2[0],etarange2[1], color=color, thick=thick

	lamrange3 = [-18.8, -14.0]
	etarange3 = [-35.5, -35.3]
	plot_box, lamrange3[0],lamrange3[1],etarange3[0],etarange3[1], color=color, thick=thick

	lamrange4 = [-33.0, -30.5]
	etarange4 = [-30.8, -30.4]
	plot_box, lamrange4[0],lamrange4[1],etarange4[0],etarange4[1], color=color, thick=thick

	lamrange5 = [3.5,57.0]
	etarange5 = [-27.9, -27.55]
	plot_box, lamrange5[0],lamrange5[1],etarange5[0],etarange5[1], color=color, thick=thick



	endplot,/trim,/png,dpi=250


    ; these are wider than the survey area, which we will allow 
    ; cel_block to trim
    bs = self->read_boss_survey()


	etamin=-40
	etamax=45

	lammin=-66
	lammax=63

    ;etamin = min(bs.cetamin)    - 0.5
    ;etamax = max(bs.cetamax)    + 0.5
    ;lammin = min(bs.clambdamin) - 0.5
    ;lammax = max(bs.clambdamax) + 0.5


	; generate a new footprint, missing those areas.  I think there is
	; probably a better way to do this

	; Use the fact that cel_block will clip to the sdss3 region
	; start under the true bottom and grow to under first polygon
	add_arrval, cel_block([etamin,etarange1[0]], [lammin,lammax]), ply

	; now just exclude the bit of lambda range we don't want
	add_arrval, cel_block(etarange1, [lamrange1[1], lammax]), ply

	; now a very thin strip starting at the end of 2 to the far right, 
	; but just going up to the tiny mask
	add_arrval, cel_block([etarange2[0],etarange3[0]],[lamrange2[1],lammax]), ply

	; now the bit in between 2 and 3
	add_arrval, cel_block(etarange3, [ lamrange2[1], lamrange3[0] ]), ply
	; and between the tiny bit and the end
	add_arrval, cel_block(etarange3, [ lamrange3[1], lammax]), ply

	; now from top of tiny strip to top of number 2 avoiding lam range in 2
	add_arrval, cel_block( [etarange3[1],etarange2[1]], [lamrange2[1], lammax]), ply

	; now up to the small box
	add_arrval, cel_block( [etarange2[1], etarange4[0]], [lammin,lammax]), ply

	; now left side of box
	add_arrval, cel_block( etarange4, [lammin,lamrange4[0]]), ply
	; now right side of box
	add_arrval, cel_block( etarange4, [lamrange4[1], lammax]), ply

	; now from top of little box to bottom of the upper right strip
	add_arrval, cel_block( [etarange4[1], etarange5[0]], [lammin,lammax] ), ply

	; left side of upper right strip
	add_arrval, cel_block( etarange5, [lammin,lamrange5[0]] ), ply

	; now on up to the top
	add_arrval, cel_block( [etarange5[1], etamax], [lammin,lammax]), ply


    ; add a block for the SGC
	;add_arrval, cel_block( [100,170], [lammin,lammax]), ply


	newply = self->snap_balkanize_unify(ply)
	destruct_polygon, ply
	;newply=ply


	;file=filepath(root=dir,'ngc-qso-nonphoto-newmask.eps')
	;file=filepath(root=dir,'nonphoto-newmask.eps')
	file=filepath(root=dir,'ngc-'+type+'-nonphoto-newmask-'+run+'.eps')
	;begplot,file,xsize=15,ysize=5,/color
	;begplot,file,xsize=8.5,ysize=8,/color
	begplot,file,/color

	if 1 then begin
		inwin_new=is_in_window(newply, ra=str[wall].ra, dec=str[wall].dec)
		wnew = where(inwin_new, comp=wout)


        erase
        multiplot, [1,2], $
            mxtitle=textoidl('\lambda_c'), mxtitsize=2, mxtitoffset=1, $
            mytitle=textoidl('\eta_c'), mytitsize=2, mytitoffset=1


        ; sgc
		plot, clam[wall], ceta[wall], psym=3, $
            xrange=[-70,70], xstyle=3, $
            yrange=[105,165], ystyle=3
		oplot, clam[wall[wout]], ceta[wall[wout]], psym=3, color=c2i('red')

        multiplot

        ; ngc
		plot, clam[wall], ceta[wall], psym=3, $
            xrange=[-70,70], xstyle=3, $
            yrange=[-50,50], ystyle=3
		oplot, clam[wall[wout]], ceta[wall[wout]], psym=3, color=c2i('red')


        multiplot,/reset
		;oplot, str[wnew].ra, str[wnew].dec, psym=3, color=c2i('red')
	endif

	if 0 then begin
		;plot_poly, newply, /over, color=c2i('green')
		ngc=self->chunk_polygon_read('ngc')
		plot_poly, ngc, outline_thick=2, color=c2i('blue'), yrange=[-4,10], xrange=[110,240]
		destruct_polygon, ngc
		plot_poly, newply, outline_thick=2, color=c2i('red'), yrange=[-4,10], xrange=[110,240], /over
	endif
	endplot,/trim,/png, dpi=100


	ply1 = cel_block(etarange1, lamrange1)
	area1 = total(ply1.str)*(180d/!dpi)^2
	destruct_polygon, ply1

	ply2 = cel_block(etarange2, lamrange2)
	area2 = total(ply2.str)*(180d/!dpi)^2
	destruct_polygon, ply2

	ply3 = cel_block(etarange3, lamrange3)
	area3 = total(ply3.str)*(180d/!dpi)^2
	destruct_polygon, ply3

	ply4 = cel_block(etarange4, lamrange4)
	area4 = total(ply4.str)*(180d/!dpi)^2
	destruct_polygon, ply4

	ply5 = cel_block(etarange5, lamrange5)
	area5 = total(ply5.str)*(180d/!dpi)^2
	destruct_polygon, ply5

	print,area1,area2,area3,area4,area5
	print,area1+area2+area3+area4+area5

	;plyfile = file_basename(self->chunk_polygon_file('ngcgood2'))
	plyfile = file_basename(self->chunk_polygon_file('bossgood'))
	plyfile = filepath(root='~/tmp',plyfile)



	print,'writing new polygon file: ',plyfile
	write_mangle_polygons, plyfile, newply
	destruct_polygon, newply

end


;+
; NAME:
;   struct_combine
;
; PURPOSE:
;   Combine 2 equal length arrays of structures into one array of structures,
;   with the UNION of the tags.  Values from the common tags will be from the
;   first structure.  
;
; CATEGORY:
;   IDL Structures
;
; CALLING SEQUENCE:
;   newst=struct_combine(struct_array1, struct_array2)
;
; INPUTS:
;   struct_array1, struct_array2: equal length arrays of structures.
;
; OUTPUTS:
;   new_struct: the output struct with the UNION of the tags.  Values from the
;             common tags will be from the first structure.
;
; PROCEDURE:
;   Get the union of the tags and tag descriptions.  The names are
;   concatenated and the duplicates removed.  The order of tags is preserved
;   except when common tags are found; then the order will be that of the 
;   second structure and the tag definition is also from the second.
;   COPY_STRUCT is used to copy, first from struct_array2 then from 
;   struct_array1.
;
; MODIFICATION HISTORY:
;   04-June-2004: created, E. Sheldon, UofChicago
;   2006-10-06: Now preserves name order.  Also, when structs have the 
;       exactly same tags, struct1 is returned. Renamed to struct_combine 
;       because it completely subsumes the functionality of that program.
;   2007-08-09: Renamed struct_combine and made a function. Erin Sheldon NYU
;-
;
;
;
;  Copyright (C) 2005  Erin Sheldon, NYU.  erin dot sheldon at gmail dot com
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;


function bosstarget::struct_combine, struct_array1, struct_array2, structype=structype

    if n_params() lt 2 then begin 
        print,'-Syntax: newst=struct_combine(struct1, struct2, structype=)'
        print
        print,'Values of common tags copy from 1 over 2'
        on_error, 2
        message,'Halting'
    endif 

    n1 = n_elements(struct_array1)
    n2 = n_elements(struct_array2)

    if (n1 NE n2) then begin 
        message,'Arrays of structures must be same length'
    endif 

    struct1 = struct_array1[0]
    struct2 = struct_array2[0]

    names1 = tag_names(struct1)
    names2 = tag_names(struct2)
    nt1 = n_elements(names1)
    nt2 = n_elements(names2)

    match, names1, names2, m1, m2

    if ( (m1[0] ne -1 and n_elements(m1) EQ nt1) $
        and (m2[0] ne -1 and n_elements(m2) EQ nt2) ) then begin 
        print,'Structures are the same. Setting new struct equal to struct1'
        newstruct = struct1
        return, newstruct
    endif 

    ;; Remove any duplicates from struct1
    tagind1 = lindgen(nt1)
    tagind2 = lindgen(nt2)
    if m1[0] ne -1 then begin 
        remove, m1, tagind1
        remove, m1, names1
        nt1 = n_elements(names1)
    endif 

    ;; Build up structure
    newstruct = create_struct(names1[0], struct_array1[0].(tagind1[0]))
    for i=1L,nt1-1 do begin 
        newstruct = $
            create_struct(newstruct, names1[i], struct_array1[0].(tagind1[i]))
    endfor 
    for i=0L,nt2-1 do begin 
        newstruct = $
            create_struct(newstruct, names2[i], struct_array2[0].(tagind2[i]))
    endfor 

    newstruct = replicate(newstruct, n1)

    copy_struct, struct_array2, newstruct
    copy_struct, struct_array1, newstruct

    return, newstruct
    
end


pro bosstarget::add_extra_pars, pars

	if n_tags(pars) gt 0 then begin

		default_pars = self->pars()

		; pars are not defined, just set to the input
		if n_tags(default_pars) eq 0 then begin
			new_pars = pars
		endif else begin

			new_pars = default_pars

			; first copy new values in over existing tags
			struct_assign, pars, new_pars, /nozero

			; now add new tags
			tnames = tag_names(pars)
			for i=0L, n_elements(tnames)-1 do begin
				if not tag_exist(new_pars, tnames[i]) then begin
					new_pars = create_struct(new_pars, tnames[i], pars.(i))
				endif
			endfor

		endelse

		self->set_pars, new_pars
	endif

end

function bosstarget::default_pars
	pars = {              $
		status_ext: 1,    $
		result_ext: 2,    $
        star_coadd: 0,    $ ; add catalog coadd info?
		commissioning: 0  $
	}
	return, pars
end

pro bosstarget::set_default_pars
	pars=self->default_pars()
	self->set_pars, pars
end


; only functions that should deal with pointers
pro bosstarget::set_pars, pars
	if n_tags(pars) eq 0 then begin
		message,'pars must be a structure'
	endif
	self->free_pars
	self.pars = ptr_new(pars)
end

function bosstarget::pars
	if ptr_valid(self.pars) then begin
		pars = *self.pars
		return, pars
	endif else begin
		return, -1
	endelse
end
pro bosstarget::free_pars
	ptr_free, self.pars
end
pro bosstarget::cleanup
	self->free_pars
end



pro bosstarget__define
	struct = {$
		bosstarget, $
		pars: ptr_new() $
	}
end
