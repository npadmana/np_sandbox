function bosstarget_qsokde::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsokde::select, objs, pars=pars, _extra=_extra


	nobjs = n_elements(objs)
	if  nobjs eq 0 then begin
		message,'Usage: boss_target1=bk->select(objs, pars=pars, _extra=_extra)'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	; inherited from bosstarget_qsopars
	pars = self->pars()

	kde_struct = self->process(objs)


	return, kde_struct
end

function bosstarget_qsokde::process, objs, tmpdir=tmpdir

	; 15-May-2009: Rewritten for parameters to produce continuous KDE densities
	;		essentially changes in parameter calls for the 
	;		command line flags
	;		and 4 calls now (bright/faint, qso/star) in addition
	;		to 2 priors (bright/faint)
	;		broken up so that the code is more modular 
	;		constructs the command line calls within single functions
	;		updates the selection flags in a single function
	;OUTPUT:
	;	function output:
	;	target_flags: whether an object is a KDE BOSS target or not
	;	additional output:
	;	res = kde_struct: a structure with the following tags
	;		pars.gsplit currently is 21.0
	;		'kde_qsodens_bright'	qso kernel density for g < pars.gsplit
	;		'kde_stardens_bright'	star kernel density for g < pars.gsplit
	;		'kde_qsodens_faint'		qso kernel density for g > pars.gsplit
	;		'kde_stardens_faint'		star kernel density for g > pars.gsplit
	;		'nbc_bright'		bayesian classification for g < pars.gsplit
	;		'nbc_faint'		bayesian classification for g > pars.gsplit
	;		'gfaint'			0 for g < pars.gsplit, 1 for g >= pars.gsplit
	;		This code has changed sufficiently from the last version
	;		so I maintained
	;		the old code in full as OLDkde_select at the end of this file
	;		Adam D. Myers, UIUC
	;25-Nov-2009
	;		


	common kde_select_block, combined_kde

	nobjs=n_elements(objs)
	target_flags = lon64arr(nobjs)
	if nobjs eq 0 then begin
		on_error,2
		message,'you must send an object structure'
	endif

	pars=self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)
	qsocache->match, 'kde', self, objs, mobjs, mcache, cache=cache

	nmobjs=n_elements(mobjs)
	if nmobjs ne nobjs then begin
		splog,'Some objects did not match the cached file!'
		splog,'    ',nmobjs,'/',nobjs,form='(a,i0,a,i0)'
		message,'Halting'
	endif

	kde_struct = cache[mcache]
    cache=0

    newstruct = self->add_target_flags(objs, kde_struct)
    return, newstruct

end


function bosstarget_qsokde::add_target_flags, objs, kde_struct
    nobjs = n_elements(objs)
	w=where(kde_struct.kde_ratio ne kde_struct.kde_ratio, nw)
	if nw ne 0 then kde_struct[w].kde_ratio = -9999
	w=where(kde_struct.kde_prob ne kde_struct.kde_prob, nw)
	if nw ne 0 then kde_struct[w].kde_prob = -9999

	bu=obj_new('bosstarget_util')
	lups = bu->get_lups(objs, /deredden)
	target_flags = self->get_kde_target_flags(kde_struct,lups)

	newstruct = create_struct(kde_struct[0], 'boss_target1',0LL)
	newstruct = replicate(newstruct, nobjs)
	struct_assign, kde_struct, newstruct, /nozero
	newstruct.boss_target1 = target_flags
	return, newstruct

end

function bosstarget_qsokde::get_kde_target_flags, kde_struct, lups, pars=pars

	nobjs=n_elements(kde_struct)
	if nobjs eq 0 then begin
		message,'Usage: target_flags = bq->get_kde_target_flags(kde_struct [, lups, pars=])',/inf
		message,'If lups not sent, psfflux must be in the structure'
	endif

	bu = obj_new('bosstarget_util')
	if n_elements(lups) eq 0 then begin
		lups = bu->get_lups(kde_struct, /deredden)
	endif
	if n_elements(pars) eq 0 then begin
		pars = self->pars()
	endif

	target_flags = lon64arr(nobjs)

	;ADM now create the flags for the kde selection information
	;ADM see the pars file for the current range cuts (qsodensmin_bright_restrictive etc.)
	;ADM don't currently cut on nbc classifications as well as densities but could in future

	;ADM restrictive cut for a core, efficient sample 
	;ADM combine faint and bright kde selections into one core selection flag
	; core, faint
	wcorefaint = where($
		kde_struct.kde_qsodens_faint ge 10d^pars.logqsodensmin_faint_restrictive $
		and kde_struct.kde_stardens_faint lt 10d^pars.logstardensmax_faint_restrictive $
		and lups[1,*] ge pars.gsplit, ncorefaint)
	if ncorefaint ne 0 then begin
		target_flags[wcorefaint] += $
			bu->qsoselectflag('qso_kde_core')
	endif


	; core, bright
	wcorebright = where($
		kde_struct.kde_qsodens_bright ge 10d^pars.logqsodensmin_bright_restrictive $
		and kde_struct.kde_stardens_bright lt 10d^pars.logstardensmax_bright_restrictive $
		and lups[1,*] lt pars.gsplit, ncorebright)

	if ncorebright ne 0 then begin
		target_flags[wcorebright] += $
			bu->qsoselectflag('qso_kde_core')
	endif

	;splog,'!!!!!!!!!: pars.logstardensmax_faint_restrictive: ',pars.logstardensmax_faint_restrictive
	;splog,'!!!!!!!!!: pars.logstardensmax_bright_restrictive: ',pars.logstardensmax_bright_restrictive
	;help,wcorefaint,wcorebright

	;ADM permissive cut for a bonus, complete sample
	;ADM combine faint and bright kde selections into one bonus selection flag

	;bonus, faint
	wbonusfaint = where($
		kde_struct.kde_qsodens_faint ge 10d^pars.logqsodensmin_faint_permissive $
		and kde_struct.kde_stardens_faint lt 10d^pars.logstardensmax_faint_permissive $
		and lups[1,*] ge pars.gsplit, nbonusfaint)
	if nbonusfaint ne 0 then begin
		target_flags[wbonusfaint] += $
			bu->qsoselectflag('qso_kde_bonus')
	endif

	;bonus, bright
	wbonusbright = where($
		kde_struct.kde_qsodens_bright ge 10d^pars.logqsodensmin_bright_permissive $
		and kde_struct.kde_stardens_bright lt 10d^pars.logstardensmax_bright_permissive $
			and lups[1,*] lt pars.gsplit, nbonusbright)
	if nbonusbright ne 0 then begin
		target_flags[wbonusbright] += $
			bu->qsoselectflag('qso_kde_bonus')
	endif



	;ADM update the output structure to contain  information from this routine

	return,target_flags
		
end

function bosstarget_qsokde::rands
    rr1=string( long(randomu(seed)*100000), f='(i0)')
    rr2=string( long(randomu(seed)*100000), f='(i0)')
    rands= rr1+'-'+rr2
    return, rands
end
function bosstarget_qsokde::file, type, run, rerun, camcol, dir=dir, ext=ext

	if n_elements(dir) eq 0 then dir=''
	if n_elements(ext) eq 0 then ext='.dat'
	els=[run, long(rerun), camcol]

	fname_base='qso-kde-'+type+'-'+string(els, f='(i06,"-",i0,"-",i0)')

	if dir ne '' then begin
		fname_base = filepath(root=dir, fname_base)
	endif

    rands = self->rands()
	fname = fname_base+'-'+rands+ext

	i=0L
	while file_test(fname) do begin
        rands = self->rands()
        fname = fname_base+'-'+rands+ext
		i+= 1
	endwhile

	return,fname
end


function bosstarget_qsokde::nbc_cmnd_redshift, nobjs, infile, colorfilename, labelfilename, $ 
			bw, bw2, outfilename, $
			run,rerun,camcol,tmpdir
	; 10-Nov-2009: Construct an nbc-style command line call, execute it and read the output info
	;		allowing variable bandwidth for different redshift bins
	;	INPUTS: nobjs=number of elements in the iput structure that was written to infile
	;		infile=full directory path of input file that contains 4 color luptitudes
	;		colorfilename=color training file (just name not directory) for this nbc call
	;		labelfilename=label training file (just name not directory) for this nbc call
	;		bw = first band width
	;		bw2 = second band width
	;		outfilename=temporary output file name (name not directory) for this nbc call
	;		runrerun,camcol,tmpdir=other information that defines temporary output file
	;						name and directory
	;	OUTPUTS:
	;		the information outputed from the KDE code as a single vector float array
	;
	;		Adam D. Myers, UIUC
	; 25-Nov-2009: Imported from bosstarget_qso_recoverprobs.pro into bosstarget_qso__define.pro
	;		and restructured as class
	;		Adam D. Myers, UIUC

	bu = obj_new('bosstarget_util')

	pars = self->pars()

	;ADM construct the fill directories for the nbc training set files
	full_color_file=filepath(root=pars.datadir, colorfilename)
	full_label_file=filepath(root=pars.datadir, labelfilename)
	bu->check_file_exists, full_color_file
	bu->check_file_exists, full_label_file

	;ADM construct the full directory structure for the output file
	outfile_noext = self->file(outfilename,run,rerun,camcol,dir=tmpdir,ext='')

	;ADM add extension ".class" to read nbc files as they are naturally outputted by Alex Gray's code
	outfile = outfile_noext+".class"

	;ADM the full nbc style command line call
	nbc_command_base=pars.prog+' '+$
		'-model nbc '+$
		'-scaling none '+$
		'-kernel epanechnikov '+$
		'-prior 0.98 '+$
		'-bw '+bw + ' '+$
		'-bw2 '+bw2 + ' '+$
		'-query '+infile

	nbc_command = nbc_command_base + ' '+'-data '+full_color_file+' '+$
		'-dtarget '+full_label_file+' '+'-basename '+outfile_noext

	;ADM run the command
	splog
	splog,'running nbc style command for '+outfilename
	splog,'-------------------------------------------- '
	self->run_command, nbc_command

	struct_entries = self->output_read(outfile)
	nout=n_elements(where(struct_entries  gt -9999.0))
	if nout ne nobjs then begin
		message,'length of faint output file does not match input: '+strn(nout)+' instead of '+strn(nobjs)
	endif

	;ADM clean up temporary file
	splog,'cleaning up temporary file '+outfile
	file_delete, outfile

	return, struct_entries

end


function bosstarget_qsokde::kde_cmnd, nobjs,infile, trainfilename, outfilename,run,rerun,camcol,tmpdir

	; 15-May-2009: Construct a kde-style command line call, execute it and read the output info
	;
	;	INPUTS: nobjs=number of elements in the iput structure that was written to infile
	;		infile=full directory path of input file that contains 4 color luptitudes
	;		trainfilename=training file name (just name not directory) for this kde call
	;		outfilename=temporary output file name (name not directory) for this kde call
	;		runrerun,camcol,tmpdir=other information that defines temporary output file
	;						name and directory
	;	OUTPUTS:
	;		the information outputed from the KDE code as a single vector float array
	;
	;		Adam D. Myers, UIUC

	;kde parameters
	pars = self->pars()

	bu = obj_new('bosstarget_util')
	;ADM full directory for the training set data

	full_train_file= filepath(root=pars.datadir, trainfilename)
	bu->check_file_exists, full_train_file

	;ADM construct the full directory structure for the output file
	outfile_noext = self->file(outfilename,run,rerun,camcol,dir=tmpdir,ext='')

	;ADM add extension ".dens" to read files as they are naturally outputted by Alex Gray's kde code
	outfile = outfile_noext+".dens"

	;ADM construct full command line call for kde style command
 	kde_command_base=pars.prog+' '+$
		'-model '+pars.kdemodel + ' '+$
		'-scaling '+pars.kdescaling + ' '+$
		'-kernel '+pars.kdekernel + ' '+$
		'-method '+pars.kdemethod + ' '+$
		'-bw '+pars.kdebw + ' '+$
		'-query '+infile

	kde_command =  kde_command_base + ' ' $
			+ '-data '+full_train_file+' '+'-basename '+ outfile_noext

		;ADM run the command
	splog
	splog,'running kde style command for '+outfilename
	splog,'-----------------------------------------------'
	self->run_command, kde_command

	struct_entries = self->output_read(outfile)
	nout=n_elements(where(struct_entries  gt -9999.0))
	if nout ne nobjs then begin
		message,'length of faint output file does not match input: '+strn(nout)+' instead of '+strn(nobjs)
	endif

	;ADM clean up temporary files
    splog,'cleaning up temporary file '+outfile
    file_delete, outfile, /quiet
    splog,'cleaning up temporary file '+outfile+'_hi'
    file_delete, outfile+'_hi', /quiet
    splog,'cleaning up temporary file '+outfile+'_lo'
    file_delete, outfile+'_lo', /quiet
    splog,'cleaning up temporary file '+outfile_noext+'.plot_lkcv'
    file_delete, outfile_noext+'.plot_lkcv', /quiet


	return, struct_entries

end

function bosstarget_qsokde::nbc_cmnd, nobjs, infile, colorfilename, labelfilename, $ 
			outfilename, $
							run,rerun,camcol,tmpdir
	; 15-May-2009: Construct an nbc-style command line call, execute it and read the output info
	;
	;	INPUTS: nobjs=number of elements in the iput structure that was written to infile
	;		infile=full directory path of input file that contains 4 color luptitudes
	;		colorfilename=color training file (just name not directory) for this nbc call
	;		labelfilename=label training file (just name not directory) for this nbc call
	;		outfilename=temporary output file name (name not directory) for this nbc call
	;		runrerun,camcol,tmpdir=other information that defines temporary output file
	;						name and directory
	;	OUTPUTS:
	;		the information outputed from the KDE code as a single vector float array
	;
	;		Adam D. Myers, UIUC

						;kde parameters
	pars = self->pars()
	bu=obj_new('bosstarget_util')

	;ADM construct the fill directories for the nbc training set files
	full_color_file=filepath(root=pars.datadir, colorfilename)
	full_label_file=filepath(root=pars.datadir, labelfilename)
	bu->check_file_exists, full_color_file
	bu->check_file_exists, full_label_file

	;ADM construct the full directory structure for the output file
	outfile_noext = self->file(outfilename,run,rerun,camcol,dir=tmpdir,ext='')

	;ADM add extension ".class" to read nbc files as they are naturally outputted by Alex Gray's code
	outfile = outfile_noext+".class"

	;ADM the full nbc style command line call
	nbc_command_base=pars.prog+' '+$
		'-model '+pars.nbcmodel + ' '+$
		'-scaling '+pars.nbcscaling + ' '+$
		'-kernel '+pars.nbckernel + ' '+$
		'-prior '+pars.nbcprior + ' '+$
		'-bw '+pars.nbcbw + ' '+$
		'-bw2 '+pars.nbcbw2 + ' '+$
		'-query '+infile

	nbc_command = nbc_command_base + ' '+'-data '+full_color_file+' '+$
		'-dtarget '+full_label_file+' '+'-basename '+outfile_noext

	;ADM run the command
	splog
	splog,'running nbc style command for '+outfilename
	splog,'-------------------------------------------- '
	self->run_command, nbc_command

	struct_entries = self->output_read(outfile)
	nout=n_elements(where(struct_entries  gt -9999.0))
	if nout ne nobjs then begin
		message,'length of faint output file does not match input: '+strn(nout)+' instead of '+strn(nobjs)
	endif

	;ADM clean up temporary file
	splog,'cleaning up temporary file '+outfile
	file_delete, outfile

	return, struct_entries

end






pro bosstarget_qsokde::run_command, command
	splog,'command'
	splog,'  ',command,format='(a,a)'
	spawn,command,out,err,exit_status=ex
	if ex ne 0 then begin
		message,'Execution failed',/inf
		splog,'stdout:'
		splog,'--------------------------'
		splog,out,format='(a)'
		splog,'stderr:'
		splog,'--------------------------'
		splog,err,format='(a)'
		message,'halting'
	endif
end

function bosstarget_qsokde::input_struct, count
	stdef = {umg:0., gmr:0., rmi:0., imz:0.}
	if n_elements(count) ne 0 then begin
		stdef = replicate(stdef, count)
	endif
	return, stdef
end

pro bosstarget_qsokde::writefile, outfile, outst
    dir=file_dirname(outfile)
    file_mkdir, dir

	openw, lun, outfile, /get_lun
	printf, lun, outst, format='(4F)'
	free_lun, lun
end
pro bosstarget_qsokde::input_write, psflups, outfile

	;n=(size(psflups))[2]
	n=n_elements(psflups)/5
	outst = self->input_struct(n)

	outst.umg = reform(psflups[0,*] - psflups[1,*]) > (-9999) < 9999
	outst.gmr = reform(psflups[1,*] - psflups[2,*]) > (-9999) < 9999
	outst.rmi = reform(psflups[2,*] - psflups[3,*]) > (-9999) < 9999
	outst.imz = reform(psflups[3,*] - psflups[4,*]) > (-9999) < 9999
	
	splog,'Writing luptitude colors to input file: ',outfile,format='(a,a)'
    self->writefile, outfile, outst

end
function bosstarget_qsokde::output_read, file
	nl=file_lines(file)
    if nl eq 0 then begin
        message,'file is empty: '+file
    endif

; ADM continuous values are needed for densities
	flags = fltarr(nl)
;	flags = intarr(nl)
	splog,'Reading '+strn(nl)+' lines from file: ',file,format='(a,a)'
	openr, lun, file, /get_lun
	readf, lun, flags
	free_lun, lun

	return, flags
end

function bosstarget_qsokde::run, objs, tmpdir=tmpdir

	; ADM structure to store the qso and star densities as well as the nbc 
	; classifications

	bu = obj_new('bosstarget_util')

	pars = self->pars()

	nobjs = n_elements(objs)
	run=objs[0].run
	rerun=objs[0].rerun
	camcol=objs[0].camcol

	proto = create_struct( $
		'run', 0L, $
		'rerun', '', $
		'camcol', 0, $
		'field', 0, $
		'id', 0L, $
		'kde_qsodens_bright', -9999.9, $
		'kde_stardens_bright', -9999.9, $
		'kde_qsodens_faint', -9999.9, $
		'kde_stardens_faint', -9999.9,				$ 
		'kde_ratio', -9999.9d0, 'kde_prob', -9999.9d0, 		$
		'kde_prob_z', dblarr(4), 'kde_qval', dblarr(4),		$
		'kde_prob_pat', -9999.9d0,				$
		; These now store the NBC photometric redshift discrete probability 
		; in 4 redshift bins
		'nbc_bright',  [-9999.9d0,-9999.9d0,-9999.9d0,-9999.9d0],  $
		'nbc_faint', [-9999.9d0,-9999.9d0,-9999.9d0,-9999.9d0],  $
		'dered_g', -9999.9, 					$
		;Need the g magnitude when we create Pat's rankings which are a 
		; function of g
		'gfaint',-1)

	kde_struct = replicate(proto, n_elements(objs))

	; copy in the id info
	struct_assign, objs, kde_struct, /nozero

	; ADM various parameters that are needed for file names
	if n_elements(tmpdir) eq 0 then begin
        tmpdir=getenv('BOSS_TARGET')
        tmpdir=filepath(root=tmpdir, 'tmp')
    endif

	; ADM name the input file for the kde code
	infile = self->file('input',run,rerun,camcol,dir=tmpdir)

	; ADM get the luptitudes for the kde input file
	lups = bu->get_lups(objs, /deredden)

	; ADM need for calling Pat's weighting function
	kde_struct.dered_g = reform(lups[1,*])

	; ADM write out gmag to output structure for easy debugging
	kde_struct.gfaint = reform(lups[1,*] ge pars.gsplit)

	; ADM write the input file for the kde code (writes four colors to 
	; file from the u,g,r,i,z luptitudes)
	self->input_write, lups, infile

	; ADM construct command line commands for the bright faint nbc 
	; classifications and the brightqso, brightstar, faintqso, faintstar 
	; commands for the kde probabilities from the input files, training 
	; files and output files names
	; and then run the command line calls to estimate bright/faint nbc 
	; classifications and
	; bright and faint  qso/star kernel density estimates and fill the 
	; kde_struct


	kde_struct.kde_qsodens_bright = $
		self->kde_cmnd(nobjs,infile, pars.bright_qsofile, $
			'bright-qso-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_qsodens_faint = $
		self->kde_cmnd(nobjs,infile, pars.faint_qsofile,  $
			'faint-qso-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_stardens_bright = $
		self->kde_cmnd(nobjs,infile, pars.bright_starfile, $
			'bright-star-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_stardens_faint = $
		self->kde_cmnd(nobjs,infile, pars.faint_starfile, $
			'faint-star-output',run,rerun,camcol,tmpdir)

	; ADM populate the ratio and probability for the KDE
	kde_struct.kde_ratio = $
		kde_struct.kde_qsodens_bright/kde_struct.kde_stardens_bright

	kde_struct.kde_prob = kde_struct.kde_qsodens_bright/	$
			(kde_struct.kde_stardens_bright+kde_struct.kde_qsodens_bright)

	;ADM Need to repeat the calculation in redshift bins using the NBC...
	;ADM but only if we've specified to patrank in the parameters file

	wfaint = where(kde_struct.gfaint, nfaint)
	if nfaint ne 0 then begin
		kde_struct[wfaint].kde_ratio =  $
			kde_struct[wfaint].kde_qsodens_faint / $
				kde_struct[wfaint].kde_stardens_faint

		kde_struct[wfaint].kde_prob =  $
			kde_struct[wfaint].kde_qsodens_faint / 	$
				(kde_struct[wfaint].kde_stardens_faint+	$
					kde_struct[wfaint].kde_qsodens_faint)

	endif



	if pars.patrank then begin

		reddy = ['2p33','2p58','2p90','3p30']
		brightbw = ['0.25','0.21','0.17','0.25']
		brightbw2 = ['0.09','0.13','0.15','0.21']
		faintbw = ['0.25','0.25','0.15','0.25']
		faintbw2 = ['0.13', '0.13', '0.17', '0.19']

		for i = 0,3 do begin
			bqcolfile = $
			  'sdssdr5_qso_star_train_boss_bright_colors4_z'+reddy[i]+'clean.dat'
			bqlabfile = $
			  'sdssdr5_qso_star_train_boss_bright_labels4_z'+reddy[i]+'clean.dat'
			fqcolfile = $
		  	'sdssdr5_qso_star_train_boss_faint_colors4_z'+reddy[i]+'clean.dat'
			fqlabfile = $
		  	'sdssdr5_qso_star_train_boss_faint_labels4_z'+reddy[i]+'clean.dat'

			nbcout = self->nbc_cmnd_redshift(nobjs, infile, bqcolfile, 	$
					bqlabfile, brightbw[i], brightbw2[i],	$
				'bright-qso-output',run,rerun,camcol,tmpdir)
			kde_struct.nbc_bright[i,*] = transpose(nbcout)
			nbcout =  self->nbc_cmnd_redshift(nobjs, infile, fqcolfile, 	$
					fqlabfile, faintbw[i], faintbw2[i],	$
				'faint-qso-output',run,rerun,camcol,tmpdir)
			kde_struct.nbc_faint[i,*] = transpose(nbcout)
		endfor

		kde_struct.kde_prob_z = kde_struct.nbc_bright
		if nfaint ne 0 then begin
			kde_struct[wfaint].kde_prob_z = kde_struct[wfaint].nbc_faint
		endif



		; ADM Determine the KDE score using Pat Mcdonald's quasar value file
		; retrieve quasar values array for lklihood

		parr = self->makeKDEpatsprobsarray()

		; ADM here nint(10*(a.dered_g-18.1)) is the entry of all redshifts in 
		; Pat's array for a given magnitude

		indices = nint(10*(kde_struct.dered_g-18.1))
		wgood = where(indices ge 0, ngood)
		if ngood gt 0 then begin
			kde_struct.kde_qval = parr[*,indices[wgood]]	
		endif
		kde_struct.kde_prob_pat = kde_struct.kde_prob*			$
			total(kde_struct.kde_qval*kde_struct.kde_prob_z,1)/	$	
					total(kde_struct.kde_prob_z,1)	


		; this if block was only run if patrank was 1 in the parameters file
	endif

	splog,'cleaning up temporary input file'
	file_delete, infile

    return, kde_struct
end



pro bosstarget_qsokde::cache_generate, objs, tmpdir=tmpdir

	; ADM structure to store the qso and star densities as well as the nbc 
	; classifications

	bu = obj_new('bosstarget_util')

	pars = self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)

	nobjs = n_elements(objs)
	run=objs[0].run
	rerun=objs[0].rerun
	camcol=objs[0].camcol

	outfile=qsocache->file('kde',run,rerun,camcol)
	splog,'Will write cached kde file to ',outfile,form='(a,a)'

    kde_struct = self->run(objs, tmpdir=tmpdir)

	qsocache->write,'kde',kde_struct,run,rerun,camcol
end


pro bosstarget_qsokde::cache_combine

	columns=[$
		'run','rerun','camcol','field','id', $
		'kde_qsodens_faint','kde_stardens_faint', $
		'kde_qsodens_bright','kde_stardens_bright', $
		'nbc_bright','nbc_faint','gfaint',$
		'kde_prob','kde_prob_pat']

	pars=self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)
	front=qsocache->front('kde')
	dir=qsocache->dir()
	pattern = filepath(root=dir,front+'-*-*-*.fits')
	print,pattern
	files=file_search(pattern)

	tmp = mrdfits_multi(files,columns=columns)

	if n_tags(tmp) eq 0 then message,'error'
	qsocache->write, 'kde', tmp, /combined
end






function bosstarget_qsokde::makeKDEpatsprobsarray
; read in Pat Mcdonald's probability file return array in a format
; such that for a given g value we have an array of probabilities
; corresponding to zmin and zmax for the KDE method
; Adam D. Myers, UIUC, Nov 15, 2009
; 25-Nov-2009: Imported from bosstarget_qso_recoverprobs.pro into bosstarget_qso__define.pro
;		and restructured as class
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
       
; The KDE file contains an array with the bins in redshift from [2.2, 2.45], [2.45,2.7], [2.7,3.1]
; [3.1,3.5] We will smooth Pat's file to correspond to these bins.

; Now build an array such that element 0 contains the Prob values for the entire z range
; in 4 bins from 2.05 to 3.85 for magnitude g=18.1, element 1 is the same for g=18.2 etc.
	probarr = dblarr(4,50)
	for i = 0, 49 do begin	
		maglo = (i*0.1)+18.09
		maghi = (i*0.1)+18.11
		zarr =  zval[where(gval gt maglo and gval lt maghi)] 
		parr =  pval[where(gval gt maglo and gval lt maghi)] 
		probarr[0,i] = mean(parr(where(zarr gt 2.21 and zarr lt 2.44)))
		probarr[1,i] = mean(parr(where(zarr gt 2.46 and zarr lt 2.69)))
		probarr[2,i] = mean(parr(where(zarr gt 2.71 and zarr lt 3.09)))
		probarr[3,i] = mean(parr(where(zarr gt 3.11 and zarr lt 3.49)))
	endfor	

	return, probarr

end





pro bosstarget_qsokde__define
	struct = {$
		bosstarget_qsokde, $
		inherits bosstarget_qsopars $
	}
end


