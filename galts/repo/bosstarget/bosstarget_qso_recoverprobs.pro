;+
; NAME:
;   bosstarget_qso_recoverprobs
;
; PURPOSE:
;   	QSO target selection for BOSS through commissioning-2 was not run on a uniform
;   	set of photometry for each of the different methods (KDE, Likelihood, NN)
;	making it hard to compare the methods fairly based on standard outputs from the 
;	targeting code. This code takes a file containing standard BOSS flux information
;  	and calculates some relevant probabilities for each of the methods for that
;   	single set of uniform flux information.
;
; CALLING SEQUENCE:
;	bosstarget_qso_recoverprobs, inputfilename, [/FAST]
;	should run great in same directory as bosstarget_qso__define
;
; INPUTS: 
;	inputfilename - fitsfile structure
;	Ideally, one of Erin Sheldon's QSO target collate files. Generally any structure
;	with at least the standard BOSS ra, dec, psfflux, psfflux_ivar and extinction tags
;
; OPTIONAL INPUTS: 
;	/FAST - set this if you have a properly compiled C wrapper for the likelihood code
;
; OUTPUTS: 
;	A file that has the same filename as the input with '.fits' changed to '-rankprob.fits'
;	This file contains the following:
;	ra, dec : J2000 coordinates
;	dered_u, dered_g, dered_r, dered_i, dered_z: dereddened mags
;	LIKELIHOOD METHOD (many* of these are outputs from likelihood_compute.pro):
;	like_ratio*: The BOSS quasar likelihood ratio [2.2, 3.5 sum(like_qso_z)]/like_everything
;	like_everything*: The likelihood of an object being anything
;	like_qso_z*: The likelihood of being a QSO in 19 bins of 0.1 by redshift over 2.0 < z < 3.9
;	like_qval: Pat McDonald's LyA forest weights in 19 bins of 0.1 by z over 2.0 < z < 3.9
;	like_ratio_pat: BOSS quasar likelihood ratio given P.M.s weights
;		[2.2, 3.5 sum(like_qso_z*like_qval)]/like_everything
;	
;	KDE METHOD (some* of these are derived as in bosstarget_qso__define.pro):
;       x2_star: Joe Hennawi's chi2_star statistic
;	kde_qsodens: KDE QSO density estimate
;	kde_stardens: KDE star density estimate
;	kde_ratio: qso_density/star_density for the KDE method with a training split at g=21
;	kde_prob: qso_density/(star_density+qso_density) with a training split at g=21
;	kde_prob_z: discrete NBC 98% prior probabilities of being a QSO in one of four redshift
;		bins (2.2 < z < 2.45, 2.45 < z < 2.7, 2.7 < z < 3.1, 3.1 < z < 3.5). 1 or 0.
;	kde_qval:  Pat McDonald's LyA forest weights in 4 redshift bins, above
;	kde_prob_pat: kde_prob given P.M.s weights
;	NN_METHOD (many* of these are derived as in bosstarget_qso__define.pro)
;	nn_xnn*: The NN ratio used in targeting
;	nn_znn_phot*: The NN photometric redshift estimate
;	RANKINGS
;	like_rank: An index to  rank-order like_ratio
;	kde_rank: An index to  rank-order kde_prob
;	nn_rank: An index to  rank-order nn_xnn
;	like_rank_pat: An index to  rank-order like_ratio_pat
;	kde_rank_pat: An index to  rank-order kde_prob_pat
;	TARGET INFO
;	targmask: a bitmask to ask if we'd have targeted this based on single-epoch
;		  selection in sweeps. Bits are:
;			2L^0: targeted by bright KDE
;			2L^1: targeted by faint KDE
;			2L^2: targeted by LIKELIHOOD
;			2L^3: targeted by NN
;
; NOTES:
;	The rank ordering is highest is best. So rank = 0 means most likely star and
;	a higher rank means a more likely QSO
;	
; CALLS: Functions in bosstarget_qso__define class (Erin Sheldon BNL, Adam Myers etc.)
;	which in turn calls....
;	c-code for Nearest Neighbor (Christophe Yeche CEA Saclay etc.)
;	likelihood compute code (Joseph Hennawi, David Schlegel, Jessica Kirkpatrick LBNL etc.)
;	nbckde compute code (Alex Gray, Georgia Tech, Gordon Richards, Drexel etc.) 
;
; REVISION HISTORY:
;	29-Oct-2009 Written by Adam D. Myers, UIUC
;	03-Nov-2009 Edited to also add znn for NN method to output file, ADM
;	11-Nov-2009 Now provide rankings for LIKELIHOOD and KDE method based
;			on Pat Mcdonald's quasar values file
;	23-Nov-2009 Now incudes x2-star from Joe Hennawi's chi-square method and
;			stardens and qsodens from KDE method
;			and what the targets would be based on commissioning2
;-
;------------------------------------------------------------------------------
; NAME:
;   bosstarget_qso_recoverprobs_cut2targs
;
; INPUTS: The structure with all the tags except the targmask
;
; OUTPUTS: The structure with the targmask appended
;
; NOTES: The targmask here is the ~80-120 per sq. deg. per method
; that Shirley Ho needs for her ranking method
;
;   Adam D. Myers, UIUC, Nov 22
;------------------------------------------------------------------------------------------------
function bosstarget_qso_recoverprobs_cut2targs, done

; load all the functions needed from bosstarget_qso__define
	bq = obj_new('bosstarget_qso')

; We'll append targmask to the passed structure
	nobjs = n_elements(done)

; add structure to store the target selected bitmask
	targs = replicate({targmask:0},  nobjs)

	 done = struct_combine(done,targs) 

; all of the needed inputs are stored in pars
	pars = bq->parscomm2()

	print, "FIND KDE TARGETS"

; Don't need the core!! It's redundant because all of the core wil be targeted 
; in bonus and Shirley doesn't care about the distinction!!!
;	wcorebright = where($
;		done.x2_star gt 7.0						$
;		and done.kde_qsodens ge 10d^pars.logqsodensmin_bright_restrictive 	$
;		and done. kde_stardens lt 10d^pars.logstardensmax_bright_restrictive 	$
;		and done.dered_g lt 21., ncorebright)
;
;	if ncorebright ne 0 then begin
;		done[wcorebright].targmask += 2L^0
;	endif
;
;
;	wcorefaint = where($
;		done.x2_star gt 7.0						$
;		and done.kde_qsodens ge 10d^pars.logqsodensmin_faint_restrictive 	$
;		and done. kde_stardens lt 10d^pars.logstardensmax_faint_restrictive 	$
;		and done.dered_g ge 21., ncorefaint)
;	if ncorefaint ne 0 then begin
;		done[wcorefaint].targmask += 2L^1
;	endif

	wbonusbright = where($
		done.x2_star gt 3.0						$
		and done.kde_qsodens ge 10d^pars.logqsodensmin_bright_permissive 	$
		and done. kde_stardens lt 10d^pars.logstardensmax_bright_permissive 	$
		and done.dered_g lt 21., nbonusbright)

	if nbonusbright ne 0 then begin
		done[wbonusbright].targmask += 2L^0
	endif


	wbonusfaint = where($
		done.x2_star gt 3.0						$
		and done.kde_qsodens ge 10d^pars.logqsodensmin_faint_permissive 	$
		and done. kde_stardens lt 10d^pars.logstardensmax_faint_permissive 	$
		and done.dered_g ge 21., nbonusfaint)
	if nbonusfaint ne 0 then begin
		done[wbonusfaint].targmask += 2L^1
	endif

	print, "FIND LIKELIHOOD TARGETS"

;	like_thresh = bq->likelihood_threshold()
; ADM I commented here because the Likelihood method seems to return
; a more sensible density with 0.1 rather than the like_thresh used in comm2
; not sure why this is but the goal is to get Shirley ~120 per sq. deg. per method
	like_thresh = 0.1
	print, 'like_thresh', like_thresh
	w=where(done.like_ratio gt like_thresh, nw)
	if nw ne 0 then begin
		done[w].targmask += 2L^2
	endif

	print, "FIND NN TARGETS"

	nn_thresh=bq->nn_xnn_threshold()
	print, 'nn_thresh', nn_thresh
	wthresh=where(done.nn_xnn gt nn_thresh, nthresh)
	if nthresh ne 0 then begin
		done[wthresh].targmask += 2L^3
	endif

	return, done

end

;------------------------------------------------------------------------------
function nbc_cmnd_redshift, nobjs, infile, colorfilename, labelfilename, $ 
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

;load all the functions needed from bosstarget_qso__define
	bq = obj_new('bosstarget_qso')
;kde parameters
	pars = bq->parscomm2()

;ADM construct the fill directories for the nbc training set files
	full_color_file=filepath(root=pars.datadir, colorfilename)
	full_label_file=filepath(root=pars.datadir, labelfilename)
	bq->check_file_exists, full_color_file
	bq->check_file_exists, full_label_file

;ADM construct the full directory structure for the output file
	outfile_noext = bq->kde_file(outfilename,run,rerun,camcol,dir=tmpdir,ext='')

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
	bq->kde_run_command, nbc_command

	struct_entries = bq->kde_output_read(outfile)
	nout=n_elements(where(struct_entries  gt -9999.0))
	if nout ne nobjs then begin
		message,'length of faint output file does not match input: '+strn(nout)+' instead of '+strn(nobjs)
	endif

;ADM clean up temporary file
	splog,'cleaning up temporary file '+outfile
	file_delete, outfile

	return, struct_entries

end

function makeLIKEpatsprobsarray
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
	
;---------------------------------------------------------------------------------------------------
function makeKDEpatsprobsarray
; read in Pat Mcdonald's probability file return array in a format
; such that for a given g value we have an array of probabilities
; corresponding to zmin and zmax for the KDE method
; Adam D. Myers, UIUC

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

;------------------------------------------------------------------------------------------------
pro bosstarget_qso_recoverprobs, inputcollatefile, ext=ext, objs=objs, outfile=outfile, $
		fast=fast

	tm0=systime(1)
	nobjs = n_elements(objs)
	if nobjs eq 0 then begin
		if n_elements(inputcollatefile) eq 0 then begin
			message,'Either send input file or objs= and outfile='
		endif
		; read input file 
		if n_elements(ext) eq 0 then ext=2
		print,'Reading file: ',inputcollatefile
		objs = mrdfits(inputcollatefile,ext)
		nobjs = n_elements(objs)

		; name the output file
		outputversion='V4'
		outfile = strsplit(inputcollatefile,'.fits',/REGEX, /EXTRACT) $
			+'-rankprob-patrank'+outputversion+'.fits'
	endif else begin
		if n_elements(outfile) eq 0 then begin
			message,'you must send outfile= if objs are input'
		endif
	endelse

	print,'Will write to output file: ',outfile


	; load all the functions needed from bosstarget_qso__define
	bq = obj_new('bosstarget_qso')

	
	; create output structure
	done =  replicate({ra:-9999.9d0, dec:-9999.9d0, 				$
			dered_u:-9999.9, 					$
			dered_g:-9999.9, 					$
			dered_r:-9999.9, 					$
			dered_i:-9999.9, 					$
			dered_z:-9999.9,					$
			like_ratio:-9999.9d0, like_everything:-9999.9d0,		$ 
			like_qso_z:dblarr(19), like_qval:dblarr(19),		$ 
			like_ratio_pat:-9999.9d0,				$
;			like_qso_zmin:dblarr(19), like_qso_zmax:dblarr(19), 	$
			kde_qsodens:-9999.9d0, kde_stardens:-9999.9d0, 		$
			x2_star:-9999.9d0,					$
			kde_ratio:-9999.9d0,  kde_prob:-9999.9d0, 		$
			kde_prob_z:dblarr(4), kde_qval:dblarr(4),		$
			kde_prob_pat:-9999.9d0,				$
			nn_xnn:-9999.9d0, nn_znn_phot:-9999.9d0, 		$
			like_rank:-1LL, kde_rank:-1LL, nn_rank:-1LL,		$
			like_rank_pat:-1LL, kde_rank_pat:-1LL			$
			},  nobjs)

	done.ra = objs.ra
	done.dec = objs.dec

	; calculate chi2star parameters

	res=bq->calculate_chi2(objs) 
	done.x2_star = res.x2_star

	; calculate likelihood parameters
	st = {flux:fltarr(5), flux_ivar:fltarr(5)}
	sendstruct = replicate(st, nobjs)

	flux=bq->deredden(objs.psfflux, objs.extinction)
	flux_ivar=bq->deredden_error(objs.psfflux_ivar, objs.extinction)

	sendstruct.flux = flux
	sendstruct.flux_ivar = flux_ivar

	if keyword_set(fast) then begin
		likelihood_compute, sendstruct, outstruct, /fast
	endif else begin
		likelihood_compute, sendstruct, outstruct
	endelse

	print, 'Likelihood redshift bins...'
	print, outstruct[0].qso_zmin
	print, outstruct[0].qso_zmax

	; add output from likelihood code to final struct 
	done.like_ratio = outstruct.l_ratio
	done.like_everything = outstruct.l_everything
	done.like_qso_z = outstruct.l_qso_z
;	done.like_qso_zmin = outstruct.qso_zmin
;	done.like_qso_zmax = outstruct.qso_zmax
	

	; get KDE parameters
	; this is harmless as nothing we call in this main program is ;
	; commissioning-timeframe-dependent
	commissioning=0
	comm2 = 1

	; structure to store the qso and star densities as well as the nbc 
	; classifications

	proto = create_struct( $
		'kde_qsodens_bright', -9999.9d0, $
		'kde_stardens_bright', -9999.9d0, $
		'kde_qsodens_faint', -9999.9d0, $
		'kde_stardens_faint', -9999.9d0, $
		'nbc_bright', dblarr(4),  $
		'nbc_faint', [-9999.9d0,-9999.9d0,-9999.9d0,-9999.9d0],  $
		'gfaint',-1)

	kde_struct = replicate(proto, n_elements(objs))

	; all of the needed inputs are stored in pars
	pars = bq->parscomm2()

	; various parameters that are needed for file names
	if n_elements(tmpdir) eq 0 then tmpdir='/tmp'
	run=objs[0].run
	rerun=objs[0].rerun
	camcol=objs[0].camcol

	; name the input file for the kde code
	infile = bq->kde_file('input',run,rerun,camcol,dir=tmpdir)

	; get the luptitudes for the kde input file
	lups = bq->get_lups(objs, /deredden)

	done.dered_u = reform(lups[0,*])
	done.dered_g = reform(lups[1,*])
	done.dered_r = reform(lups[2,*])
	done.dered_i = reform(lups[3,*])
	done.dered_z = reform(lups[4,*])

	; write out gmag to output structure for easy debugging
	kde_struct.gfaint = reform(lups[1,*] ge pars.gsplit)

	; write out gmag to output structure for eabsy debugging

	; write the input file for the kde code (writes four colors to file 
	; from the u,g,r,i,z luptitudes)
	bq->kde_input_write, lups, infile

	; construct command line commands for the brightqso, brightstar, 
	; faintqso, faintstar 
	; commands for the kde probabilities
	; from the input files, training files and output files names
	; and then run the command line calls to estimate bright/faint 
	; nbc classifications and bright and faint  qso/star kernel density 
	; estimates and fill the kde_struct

	kde_struct.kde_qsodens_bright = bq->kde_cmnd(nobjs,infile, pars.bright_qsofile, $
				commissioning=commissioning, $
				comm2=comm2,  $
				'bright-qso-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_qsodens_faint = bq->kde_cmnd(nobjs,infile, pars.faint_qsofile,  $
				commissioning=commissioning, $
				comm2=comm2,  $
				'faint-qso-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_stardens_bright = bq->kde_cmnd(nobjs,infile, pars.bright_starfile, $
				commissioning=commissioning, $
				comm2=comm2,  $
				'bright-star-output',run,rerun,camcol,tmpdir)
	kde_struct.kde_stardens_faint = bq->kde_cmnd(nobjs,infile, pars.faint_starfile, $
				commissioning=commissioning, $
				comm2=comm2,  $
				'faint-star-output',run,rerun,camcol,tmpdir)


	done.kde_qsodens = kde_struct.kde_qsodens_bright
	done[where(kde_struct.gfaint)].kde_qsodens =  $
		kde_struct[where(kde_struct.gfaint)].kde_qsodens_faint 

	done.kde_stardens = kde_struct.kde_stardens_bright
	done[where(kde_struct.gfaint)].kde_stardens =  $
		kde_struct[where(kde_struct.gfaint)].kde_stardens_faint 

	done.kde_ratio = kde_struct.kde_qsodens_bright/kde_struct.kde_stardens_bright
	done.kde_prob = kde_struct.kde_qsodens_bright/	$
			(kde_struct.kde_stardens_bright+kde_struct.kde_qsodens_bright)
	done[where(kde_struct.gfaint)].kde_ratio =  $
		kde_struct[where(kde_struct.gfaint)].kde_qsodens_faint / $
			kde_struct[where(kde_struct.gfaint)].kde_stardens_faint
	done[where(kde_struct.gfaint)].kde_prob =  $
		kde_struct[where(kde_struct.gfaint)].kde_qsodens_faint / 	$
			(kde_struct[where(kde_struct.gfaint)].kde_stardens_faint+	$
				kde_struct[where(kde_struct.gfaint)].kde_qsodens_faint)

	; Need to repeat the KDE calculation in redshift bins using the NBC...

	reddy = ['2p33','2p58','2p90','3p30']
	brightbw = ['0.25','0.21','0.17','0.25']
	brightbw2 = ['0.09','0.13','0.15','0.21']
	faintbw = ['0.25','0.25','0.15','0.25']
	faintbw2 = ['0.13', '0.13', '0.17', '0.19']

	for i = 0,3 do begin
		bqcolfile = 'sdssdr5_qso_star_train_boss_bright_colors4_z'+reddy[i]+'clean.dat'
		bqlabfile = 'sdssdr5_qso_star_train_boss_bright_labels4_z'+reddy[i]+'clean.dat'
		fqcolfile = 'sdssdr5_qso_star_train_boss_faint_colors4_z'+reddy[i]+'clean.dat'
		fqlabfile = 'sdssdr5_qso_star_train_boss_faint_labels4_z'+reddy[i]+'clean.dat'

		nbcout = nbc_cmnd_redshift(nobjs, infile, bqcolfile, 		$
					bqlabfile, brightbw[i], brightbw2[i],	$
				'bright-qso-output',run,rerun,camcol,tmpdir)
		kde_struct.nbc_bright[i,*] = transpose(nbcout)
		nbcout =  nbc_cmnd_redshift(nobjs, infile, fqcolfile, 		$
					fqlabfile, faintbw[i], faintbw2[i],	$
				'faint-qso-output',run,rerun,camcol,tmpdir)
		kde_struct.nbc_faint[i,*] = transpose(nbcout)
	endfor

	done.kde_prob_z = kde_struct.nbc_bright
	done[where(kde_struct.gfaint)].kde_prob_z = 				$
			kde_struct[where(kde_struct.gfaint)].nbc_faint

	splog,'cleaning up temporary input file'
	file_delete, infile

	; compute the NN probabilities
	
	bq->nn_run, objs, xnn, znn

	done.nn_xnn = xnn
	done.nn_znn_phot = znn

	; Determine the Likelihood score using Pat Mcdonald's quasar value file
	; retrieve quasar values array for likelihood

	parr = makeLIKEpatsprobsarray()

	; This is a function to limit the weighted sum over only 2.2 < z < 3.5

	zmirror = (indgen(19)*0.1)+2.05
	zselect = where(zmirror gt 2.2 and zmirror lt 3.5)

	; where nint(10*(a.dered_g-18.1)) is the entry of all redshifts in 
	; Pat's array for a given magnitude
	done.like_qval = parr[*,nint(10*(done.dered_g-18.1))]
	eps = 1e-30	; prevent divide by zero as in likelihood code
	done.like_ratio_pat = 				$
		(total(done.like_qval[zselect]*done.like_qso_z[zselect],1)+eps)/	$
					(done.like_everything + eps)

	; don't forget the 1 in total to sum across the first dimension

	; Determine the KDE score using Pat Mcdonald's quasar value file
	; retrieve quasar values array for likelihood

	parr = makeKDEpatsprobsarray()

	; here nint(10*(a.dered_g-18.1)) is the entry of all redshifts in 
	; Pat's array for a given magnitude

	done.kde_qval = parr[*,nint(10*(done.dered_g-18.1))]	
	done.kde_prob_pat = done.kde_prob*			$
		total(done.kde_qval*done.kde_prob_z,1)/total(done.kde_prob_z,1)

	; Sort on the various parameters and append the rank

	done.like_rank=sort(sort(done.like_ratio))
	done.like_rank_pat=sort(sort(done.like_ratio_pat))
	done.kde_rank=sort(sort(done.kde_prob))
	done.kde_rank_pat=sort(sort(done.kde_prob_pat))
	done.nn_rank=sort(sort(done.nn_xnn))

	; Finally, populate "targmask" with a flag to say whether we targeted
	; the object in single-epoch data and which approach by calling 
	; bosstarget_qso_recoverprobs_cut2targs

	done = bosstarget_qso_recoverprobs_cut2targs(done)
	
	; and write out the final file

	print,'Writing file: ',outfile
	mwrfits, done, outfile, /create

	tm1=systime(1)
	ptime,tm1-tm0

end

