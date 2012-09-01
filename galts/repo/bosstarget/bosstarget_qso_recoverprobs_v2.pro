;+
; NAME:
;   bosstarget_qso_recoverprobsV2
;
; PURPOSE:
;	Replaces bosstarget_qso_recoverprobs. See documentation for that program.
;	Essentially does what bosstarget_qso_recoverprobs did without calculating.
;	any of the outputs, just the ranking.
;
; CALLING SEQUENCE:
;	bosstarget_qso_recoverprobs, inputfilename
;	should run great in same directory as bosstarget_qso__define
;
; INPUTS: 
;	inputfilename - fitsfile structure from the post commissioning version
;	of bosstarget_qso__define.
;
; OPTIONAL INPUTS: 
;
;	objs - alternative input...just send this structure rather than the input file
;	outfile - if objs is sent rather than an input file then the output file must be sent
;	ext - set this if the fits extension of interest in the inputfile is not the second extension
;   /KNOWNRANK - set this keyword to place known quasars at the top of any ranking list
;   /FIRSTRANK - set this to place FIRST targets at the top of any ranking list (but below
;	known quasars if you also passed /KNOWNRANK)
;
; OUTPUTS: 
;	A file that has the same filename as the input with '.fits' changed to '-rankprob.fits'
;	This file contains everything from the input structure together with
;	RANKINGS
;	like_rank: An index to rank-order like_ratio
;	kde_rank: An index to rank-order kde_prob
;	nn_rank: An index to rank-order nn_xnn
;	nn_rank2: An index to to rank-order nn_xnn
;	like_rank_pat: An index to  rank-order like_ratio_pat
;	kde_rank_pat: An index to  rank-order kde_prob_pat
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bosstarget_qso_recoverprobs.pro;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	29-Oct-2009 Written by Adam D. Myers, UIUC
;	03-Nov-2009 Edited to also add znn for NN method to output file, ADM
;	11-Nov-2009 Now provide rankings for LIKELIHOOD and KDE method based
;			on Pat Mcdonald's quasar values file
;	23-Nov-2009 Now incudes x2-star from Joe Hennawi's chi-square method and
;			stardens and qsodens from KDE method
;			and what the targets would be based on commissioning2
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bosstarget_qso_recoverprobsV2.pro (this file);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	1-Dec-2009 Written by Adam D. Myers UIUC
;-
;------------------------------------------------------------------------------


function _get_inwindow, chunk, ra, dec
	dir=getenv('BOSSTILELIST_DIR')
	if dir eq '' then message,'bosstilelist is not setup'

	chunkstr=string(chunk,f='(i0)')
	bossname='boss'+chunkstr

	fname = 'geometry-'+bossname+'.ply'
	file = filepath(root=dir,subdir=['outputs',bossname], fname)

	read_mangle_polygons, file, tilepoly, tile_poly_ids

	inwindow=is_in_window(tilepoly, ra=ra, dec=dec)


	destruct_polygon, tilepoly

	return, inwindow

end

function rankattop, ranker, btflag, topval
; ranker is a structure (that we can alter) containing the values we rank on
; which are like_ratio,  like_ratio_pat, kde_prob, kde_prob_pat, nn_xnn, nn_znn_phot
; btflag is the boss target flag we want to rerank (e.g., 2L^18 for qso_first_boss)
; topval is the value we want to change things with btflag too (e.g., really large integer, 0, -1 etc.)
;ADM
	rads = where(ranker.boss_target1 and btflag, count)

	if count gt 0 then begin
		ranker[rads].like_ratio = topval
		ranker[rads].like_ratio_pat = topval
		ranker[rads].kde_prob = topval
		ranker[rads].kde_prob_pat = topval
		ranker[rads].nn_xnn = topval
; this last one just assures that all the good boss_targets 
; are set to have a photoz in the boss
		ranker[rads].nn_znn_phot = 3.0
	endif

	return,  ranker
end
;---------------------------------------------------------------------------

pro bosstarget_qso_recoverprobs_v2, inputcollatefile, $
		ext=ext, objs=objs, outfile=outfile, $
		knownrank=knownrank, firstrank=firstrank, $
		chunk=chunk

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
		outputversion=''
		outfile = strsplit(inputcollatefile,'.fits',/REGEX, /EXTRACT) $
			+'-rankprob-patrank'+outputversion+'.fits'
		; don't clobber due to parsing errors
		if outfile eq inputcollatefile then message,'Could not parse input file'
		if ext eq 2 then begin
			front = mrdfits(inputcollatefile,1)
			print,'writing extension 1 to output file: ',outfile
			mwrfits, front, outfile, /create
		endif
	endif else begin
		if n_elements(outfile) eq 0 then begin
			message,'you must send outfile= if objs are input'
		endif
	endelse

	print,'Will write to output file: ',outfile

	; load all the functions needed from bosstarget_qso__define
	bq = obj_new('bosstarget_qso')

	; create output structure

	outstruct = {$
		dered_u:-9999.9, dered_u_err:-9999.9,		$
		dered_g:-9999.9, dered_g_err:-9999.9,		$
		dered_r:-9999.9, dered_r_err:-9999.9,		$
		dered_i:-9999.9, dered_i_err:-9999.9,		$
		dered_z:-9999.9, dered_z_err:-9999.9,		$
		like_rank:-1LL, like_rank_pat:-1LL, 		$
		kde_rank:-1LL, kde_rank_pat:-1LL,		$
		nn_rank:-1LL, nn_rank2:-1LL, nn_rank3:-1LL	$
		}
	if n_elements(chunk) ne 0 then begin
		outstruct = create_struct(outstruct, 'chunk', chunk, 'inwindow', 0)
	endif
	outstruct = create_struct(objs[0], outstruct)
	done =  replicate(outstruct,  nobjs)
	struct_assign, objs, done, /nozero

	if n_elements(chunk) ne 0 then begin
		print,'Adding "inwindow"'
		done.inwindow = _get_inwindow(chunk, done.ra, done.dec)
	endif


	; get the dereddened luptitudes, errors 
	flux=bq->deredden(objs.psfflux, objs.extinction)
	ivar=bq->deredden_error(objs.psfflux_ivar, objs.extinction)
	lups = bq->flux2lups(flux)
	err = bq->ivar2lupserr(ivar, flux)

	;and add them in directly to the output structure
	done.dered_u = reform(lups[0,*])
	done.dered_g = reform(lups[1,*])
	done.dered_r = reform(lups[2,*])
	done.dered_i = reform(lups[3,*])
	done.dered_z = reform(lups[4,*])

	done.dered_u_err = reform(err[0,*])
	done.dered_g_err = reform(err[1,*])
	done.dered_r_err = reform(err[2,*])
	done.dered_i_err = reform(err[3,*])
	done.dered_z_err = reform(err[4,*])


; Erin: I couldn't think of an obvious way to rank the FIRST radio  and known quasars
; highest without potentially having Christophe rerank them down his list for nn_rank3. 
; This seemed cleanest for now.
; When we have control of Shirley's code we could always reorder things top-to-bottom
; rather than bottom-to-top and set rval and kval to -1 and -2 to have them 
; ranked lowest without 
; If we get access to the code Christophe uses to make nn_rank3 we can do a proper 
; restacking on integers in the ranked list

	; set up a dummy structure we can muck around with
	ranker =  replicate({like_ratio:-9999.9d0, like_ratio_pat:-9999.9d0,	$
			kde_prob:-9999.9d0, kde_prob_pat:-9999.9d0,	$
			nn_xnn:-9999.9d0, nn_znn_phot:-9999.9d0,	$
			boss_target1:0LL				$
			},  nobjs)
	
	ranker.like_ratio = objs.like_ratio
	ranker.like_ratio_pat = objs.like_ratio_pat
	ranker.kde_prob = objs.kde_prob
	ranker.kde_prob_pat = objs.kde_prob_pat
	ranker.nn_xnn = objs.nn_xnn
	ranker.nn_znn_phot = objs.nn_znn_phot
	ranker.boss_target1 = objs.boss_target1


	;this sets everything with rflag set to have a value of rval (so it will be ranked highly) 
	if keyword_set(firstrank) then begin
		rflag =  sdss_flagval('boss_target1','QSO_FIRST_BOSS')	
		rval = 1d307
		ranker = rankattop(ranker, rflag, rval)
	endif

	;this sets everything with kflag set to have a value of kval (so it will be ranked highly) 
	if keyword_set(knownrank) then begin
		kflag = sdss_flagval('boss_target1','QSO_KNOWN_MIDZ')	
		kval = 1d308
		ranker = rankattop(ranker, kflag, kval)
	endif

	done.like_rank=sort(sort(ranker.like_ratio))
	done.like_rank_pat=sort(sort(ranker.like_ratio_pat))
	done.kde_rank=sort(sort(ranker.kde_prob))
	done.kde_rank_pat=sort(sort(ranker.kde_prob_pat))
	done.nn_rank=sort(sort(ranker.nn_xnn))

	;nn_rank2 is a three stage process
	;
	;(1) rank everything with nn_znn_phot ge 2.1 and nn_xnn lt 0 lowest
	lownn = where(ranker.nn_znn_phot ge 2.1 and ranker.nn_xnn lt 0.)
	done[lownn].nn_rank2 = sort(sort(ranker[lownn].nn_xnn))
	nextrank = max(done[lownn].nn_rank2) + 1

	;(2) rank everything with nn_znn_phot lt 2.1 at the next equal rank
	midnn = where(ranker.nn_znn_phot lt 2.1)
	done[midnn].nn_rank2 = nextrank
	nextrank += n_elements(midnn)
	;note that nextrank is now the total stack for the low and mid ranges

	;(3) rank everything with nn_znn_phot ge 2.1 and nn_xnn ge 0 up to the top of the pile
	hinn =  where(ranker.nn_znn_phot ge 2.1 and ranker.nn_xnn ge 0.)
	done[hinn].nn_rank2 = sort(sort(ranker[hinn].nn_xnn))+nextrank

	if ext eq 2 then begin
		print,'Writing extension 2 (ranking results) to output file: ',outfile
		mwrfits, done, outfile
	endif else begin
		print,'Writing file: ',outfile
		mwrfits, done, outfile, /create
	endelse


	tm1=systime(1)
	ptime,tm1-tm0

	return

end

