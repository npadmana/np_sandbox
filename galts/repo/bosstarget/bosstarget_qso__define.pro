function bosstarget_qso::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

;docstart::bosstarget_qso::select
; NAME:
;   bosstarget_qso::select
;
; PURPOSE:
;   Make the BOSS QSO target catalog from the datasweeps
;
; CALLING SEQUENCE:
;	bq = obj_new('bosstarget_qso', pars=, _extra=)
;   res=bq->select(calibobj, pars=, _extra=)
;   
; INPUTS:
;	calibobj:  A calibobj, or datasweep, file
;   
; OUTPUTS:
;	A structure with the .boss_target1 flags and a large set of other
;	parameters.  See the ::struct method for the tag list.
;
; OPTIONAL INPUTS:
;	Any of the parameters defined in the .pars sub-structure can be set
;	by sending the pars= structure as an argument to the ::select method
;	or as an argument during construction (bl=obj_new('bosstarget_qso',pars=)
;
;	Also any keywords sent during construcion or to the ::select method
;	will get copied in over the default pars.  pars= takes precedence over
;	keywords.  The exception is when commissioning or comm2 to is set, then
;	the commissioning parameters will always be used and override any others
;	set by pars= or keywords.
;
; REVISION HISTORY:
;   16-Jul-2008 Written by D. Schlegel, LBL
;   7-Aug-2008, Modified by R. da Silva, LBL
;	13-Jan-2009: Moved into class file, minor tweaks and formatting, 
;		Erin Sheldon, BNL
;   02-March-2009: Fixed bugs in selection across multiple bands.
;		There is now a positive-logic flag for quasar selection.
;		Marking of "bad flags" kept in a separate structure field.  
;		Only objects that have no bad flags set are sent to the
;		chi^2 code in order to make the code finish faster.
;		Objects not primary or photometric *are* sent to the code
;		and these tags are kept in the output structure.
;		In order to run all objects just call this method for the 
;		chi^2 code
;			res=bq->chi2_select(calibobj)
;		or this method for the kde code
;			res=bq->kde_select(calibobj)
;		Erin Sheldon, BNL
;   15-May-2009: Changed to the expected target selection as of BOSS commissioning:
; 		removed all uses of a color box for x2 statistics calculation
;	         	calculate_chi2 sped up to only calculate x2star not other x2 stats
;		changed struct so that only x2star (not x2phot, z_phot) exists to be filled
;	           	rewrote flag_logic almost completely for current flag cuts
;		rewrote gmag_logic for g and r band limits, fixed mag limit bug
;		rewrote kde to call for qsodens and stardens rather than priors
;		kde_select now also returns kde_res a struct of useful kde info
;		allow both permissive and restrictive cuts on kde and chi2 selection
;		these permissive/restrictive cuts alter sdssMaskbits.par so that
;		added qsoselectflag so that qso selection is tracked internally to this code
;		we then  only need to export the following single flags to boss targeting
;
; maskbits boss_target1 10 QSO_CORE      # restrictive qso selection
; maskbits boss_target1 11 QSO_BONUS     # permissive qso selection
;
;		Adam D. Myers, UIUC
;
;	2009-06-04: Added extra_logic= keyword, a string that can be used
;		to generate new logic.  e.g. 'str.ra gt 100' or something.  This
;		is negated and if not zero is added as a new "badflag" with value
;		->badflag('extra_logic')  Erin Sheldon, BNL
;
;   2009-06-06:  Require photometric for setting target flags.
;		Added matching against known qsos.
;	2009-06-18:  Modularized so you can calculate target_flags on a struct
;		without runnin the full target code if the struct has the right
;		parameters.  get_kde_target_flags, get_chi2_target_flags.  Also
;		can send in pars= keyword to add or override parameters.  Added
;		/reselect so we can make use of these quickly.
;	23-June-2009: added ignore_bounds keyword to check fields regardless of tiling plan
; 		fixed bug that was throwing out bonus objects with either kde or chi2 $
;		selection overlapping the core (rather than both kde and chi2 selection)
;		made bsoft = fltarr(5,n_elements(objs))
;		Adam D. Myers, UIUC
;	29and30-Sept-2009: added /comm2 keyword for second part of commissioning that
;		won't have the benefit of the coadds in stripe82
;		Made a parscomm2 file and followed the comm2 keyword logic through to it
;		so that we can have different parameters for commissioning2 while
;		retaining everything we ran for initial commissioning
;		Followed commissioning logic through to nn_file and likelihood_file
;		so we can change these quickly
;		Followed comm2 logic through to known_qso_file
;		Added read of the knownqso file for comm2 (knownquasars.092909.fits)
;		Added (cached) matching to FIRST radio survey..requires
; maskbits BOSS_TARGET1 18 QSO_FIRST_BOSS          # FIRST radio match
;		Added new NN file for commissioning-part2
;		Changed code so .nn_xnn .nn_znn_phot are added to output /struct
;		Changed convert_nn_to_fits to produce .nn_xnn .nn_znn_phot tags
;		Added UVES quasars to know quasars file
;		Fixed bug in Keck HIRES quasars in known quasars (Decs were wrong)
;		Adam D. Myers, UIUC
; 2009-11-25:  Send /comm2 or /commissioning on instantiation now.  Generate
;	like_ratio_pat for likelihood code.  ESS, BNL
; 25-Nov-2009: Generate kde_prob and kde_prob_pat for KDE code
;	includes new classes bosstarget_qso::nbc_cmnd and 
;	bosstarget_qso::makeKDEpatsprobsarray, Adam D. Myers, UIUC
;	Most keywords now absorbed into pars=.  main pars is now pars_main(), and 
;	pars() is the equivalent of callcorrectpars before
;		2010-01-12, Erin Sheldon, BNL
;
; ... we stopped writing changes in here....
;docend::bosstarget_qso::select


function bosstarget_qso::select, objs_in, $
		pars=extra_pars, $
		extra_logic=extra_logic, $
		count=count, $
		types=typesin, $
		reselect=reselect, $
		_extra=_extra

	; ADM added keyword for quick check of fields that are 
	; nowhere near the plane of the galaxy 

	if n_elements(objs_in) eq 0 then begin
		splog,"usage:"
		splog,"  btqso=obj_new('bosstarget_qso', pars=, _extra=)"
		splog,"  t=btqso->select(calibobj, /struct, count=count, types=, pars=, /reselect, extra_logic=)"
		on_error, 2
		message,'Halting'
	endif

	self->copy_extra_pars, pars=extra_pars, _extra=_extra
	pars=self->pars()

	if tag_exist(objs_in,'PSF_CLEAN_NUSE') and not pars.ignore_multi_epoch then begin
        splog,'Multi-epoch available'
		self.pars.multi_epoch_available = 1
	endif else begin
		self.pars.multi_epoch_available = 0
	endelse

	; add survey coordinates and galactic
	objs = self->add_flux_and_coords(objs_in)
	nobjs = n_elements(objs)


	bu=obj_new('bosstarget_util')

	; these go into boss_target1
	boss_target1 = lon64arr(nobjs)
	; more fine grained flags
	target_flags = lon64arr(nobjs)

	types = self->get_types(types=typesin)

	tm0=systime(1)


	; main flag checking routine
	flag_bitmask = self->flag_logic(objs)


	if n_elements(extra_logic) ne 0 then begin
		; note for qsos we use bitmask == 0 as good, so we will take things
		; that don't pass the logic and add the new flag to them
		tmp_logic = self->extra_logic(objs, extra_logic)
		tmp_bad = tmp_logic eq 0
		flag_bitmask += tmp_bad*self->badflag('extra_logic')

		self->debug_flags,'extra_logic',tmp_logic
	endif

	; magnitude range
	gmag_bitmask = self->gmag_logic(objs)

	;ADM need this for FIRST (don't need to cut bright FIRST objects only faint)
	gmag_bitmask_nob = self->gmag_logic(objs, /no_bright_cut)

	;ADM don't care about color box
	;	splog,'checking colors'
	;	color_bitmask = self->color_logic(objs)

	resolve_bitmask = self->resolve_logic(objs)
	calib_bitmask = self->calib_logic(objs)


	; ADM added ignore_bounds keyword for quick check of fields that are 
	; nowhere near the plane of the galaxy
	if pars.ignore_bounds then begin
		bounds_bitmask = lonarr(n_elements(objs))
	endif else begin
		bounds_bitmask = self->bounds_bitmask(objs)
	endelse


	; this is a combined bitmask used in a number of the codes.  It isn't 
	; really "all" any more.
	all_bitmask = bounds_bitmask+flag_bitmask+gmag_bitmask
	if not pars.ignore_resolve then begin
		all_bitmask += resolve_bitmask
	endif
	if not pars.nocalib then begin
		splog,'Cutting to photometric'
		all_bitmask += calib_bitmask
	endif else begin
		splog,'NOT cutting to photometric'
	endelse

    ;
    ; *
    ; * Get the core sample from the pre-cached file
    ; * core is now fixed for the remainder of the survey: 2010-12-06
    ; *
    ;

    if in(types,'all') or in(types,'core') then begin
        bc = obj_new('bosstarget_qso_core')
        boss_target1[*] += bc->match(objs, qsoed_prob_core=qsoed_prob_core)
    endif


	;
	; *
	; * For known objects we match single-epoch
	; *
	;

	self->set_flux, objs, 'single-epoch'

	if in(types,'all') or in(types,'core') or in(types,'knownqso') then begin
		known_flagsend = bounds_bitmask + resolve_bitmask
		if not pars.nocalib then known_flagsend += calib_bitmask

		bknown=obj_new('bosstarget_qsoknown', pars=pars)
		bknown->match, objs, known_flagsend, $
			known_matchflags, known_target_flags, known_matchids

		boss_target1[*] += known_target_flags
	endif
	

	;
	; *
	; * Now for everything else use multi-epoch if available
	; *
	;

	self->set_flux, objs, 'multi-epoch'

	if in(types,'all') or in(types,'bonus') or in(types,'like') then begin
		like_keep = where(all_bitmask eq 0, nlike)
		if nlike ne 0 then begin

			bl = obj_new('bosstarget_qsolike', pars=pars)
			like_struct_bonus = bl->process(objs[like_keep])

		endif
	endif


	; extreme deconvolution
	; ADM switched to bonus format
	if in(types,'all') or in(types,'ed') then begin
        ed_struct_bonus = self->run_qsoed(objs, bitmask=all_bitmask)
	endif
	

	; note we always run NN, even if re-selecting, since it is quite fast
	if in(types,'all') or in(types,'nn') then begin
		bn = obj_new('bosstarget_qsonn', pars=pars)
		nn_struct = bn->select(objs, bitmask=all_bitmask)

		boss_target1[*] += nn_struct.boss_target1
	endif


	; ADM to make a reverse UVX cut on the FIRST objects to recover hi-z 
	; matches only
	; ADM, moved this down here (below self->set_flux, objs, 'multi-epoch')
	; on 04/21/10 as there's no reason not to use the
	; coadded colors for the reverse UVX cut, if available
	first_color_bitmask = self->first_color_logic(objs)

	first_bitmask = $
		bounds_bitmask $
		+flag_bitmask  $
		+gmag_bitmask_nob $
		+first_color_bitmask
	if not pars.ignore_resolve then begin
		first_bitmask += resolve_bitmask
	endif
	if not pars.nocalib then begin
		first_bitmask += calib_bitmask
	endif


	if in(types,'all') or in(types,'first') then begin

		bf = obj_new('bosstarget_qsofirst', pars=pars)
		boss_target1[*] += $
			bf->match(objs,bitmask=first_bitmask, $
			firstradio_struct=firstradio_struct2)
	endif


	; we will match all in this case, setting flags for "stars"
	; but copying in kband and id for all matches
	;ADM there isn't any UKIDSS data for commissioing-2, I think

	;if in(types,'all') or in(types,'ukidss') then begin
	;	if pars.commissioning then begin
	;		bukidss = obj_new('bosstarget_ukidss',pars=pars)
	;		boss_target1[*] = bukidss->match(objs, ukidss_id=ukidss_id)
	;   endif
	;endif




	; should we perform kde selection?
	if in(types,'all') or in(types,'kde') then begin
		splog,'--------------------------------------------------'
		splog,'Running kde selection'

		; run alex gray code
		; pre-select the flags and basic magnitude limits only

		kde_keep = where( all_bitmask eq 0,nkde)

		if nkde ne 0 then begin

			splog,'sending '+strn(nkde)+' to kde code'

			bk = obj_new('bosstarget_qsokde', pars=pars)
			kde_res = bk->select(objs[kde_keep])
			target_flags[kde_keep] += kde_res.boss_target1

		endif 

	endif

	; should we perform chi^2 seletion?
	if in(types,'all') or in(types,'chi2') then begin
		splog,'--------------------------------------------------'
		splog,'Running chi2 selection'

		; run Joe Hennawi's code
		; pre-select the flags, basic magnitude limits, and color limits

		chi2_preselect = where( all_bitmask eq 0,nchi2)
		if nchi2 gt 0 then begin
			splog,'sending '+strn(nchi2)+' to chi2 code'
			;tflags = $
			;	self->chi2_select(objs[chi2_preselect], $
			;	res=chi2_res)
			;target_flags[chi2_preselect] += tflags

			bc=obj_new('bosstarget_qsochi2', pars=pars)
			chi2_res = bc->select(objs[chi2_preselect])
			target_flags[chi2_preselect] += chi2_res.boss_target1
		endif

	endif

	; ADM only want a yes/no flag output for both kde and chi2, so have to $
	; combine the flags to only those objects selected by *both* methods


	splog,'--------------------------------------------------'

	coreflag = $
		bu->qsoselectflag('qso_kde_core') $
		+ bu->qsoselectflag('qso_chi2_core')
	bonusflag = $
		bu->qsoselectflag('qso_kde_bonus') $
		+ bu->qsoselectflag('qso_chi2_bonus')


	; ADM added /nozero keyword so that the initial assign values for $
	; st aren't overwritten
	st = self->struct(count=nobjs)
	struct_assign, objs, st, /nozero

	;ADM switched to core/bonus format for ed
	if n_elements(qsoed_prob_core) ne 0 then begin
		st.qsoed_prob_core = qsoed_prob_core
	endif


	if n_elements(ed_struct_bonus) ne 0 then begin
		st.qsoed_prob_bonus = ed_struct_bonus.pqso
        st.qsoed_prob_bonus_multi = ed_struct_bonus.pqso_multiwave
        st.galex_matched = ed_struct_bonus.galex_matched
        st.galex_matched_raw = ed_struct_bonus.galex_matched_raw
        st.ukidss_matched = ed_struct_bonus.ukidss_matched
        st.ukidss_matched_raw = ed_struct_bonus.ukidss_matched_raw
	endif


	if n_elements(nn_struct) ne 0 then begin
		st.nn_xnn = nn_struct.xnn
		st.nn_xnn2 = nn_struct.xnn2
		st.nn_znn_phot = nn_struct.znn_phot
	endif


	if n_elements(firstradio_struct) ne 0 then begin
		st.firstradio_id = firstradio_struct.firstradio_id
		st.firstradio_dist = firstradio_struct.firstradio_dist
	endif



	if n_elements(like_struct_core) ne 0 then begin
		if nlike ne 0 then begin
			st[like_keep].like_ratio_core = like_struct_core.like_ratio
		endif
	endif

	if n_elements(like_struct_bonus) ne 0 then begin
		if nlike ne 0 then begin
			st[like_keep].like_ratio_bonus = like_struct_bonus.like_ratio
			if tag_exist(like_struct_bonus,'like_ratio_pat') then begin
				st[like_keep].like_ratio_bonus_pat = like_struct_bonus.like_ratio_pat
			endif
		endif
	endif

	st.primary = (resolve_bitmask eq 0)
	st.photometric = (calib_bitmask eq 0)

	if n_elements(kde_res) ne 0 then begin
		st[kde_keep].kde_qsodens_bright = kde_res.kde_qsodens_bright
		st[kde_keep].kde_stardens_bright = kde_res.kde_stardens_bright
		st[kde_keep].kde_qsodens_faint = kde_res.kde_qsodens_faint
		st[kde_keep].kde_stardens_faint = kde_res.kde_stardens_faint
		st[kde_keep].nbc_bright = kde_res.nbc_bright
		st[kde_keep].nbc_faint = kde_res.nbc_faint
		st[kde_keep].gfaint = kde_res.gfaint
		st[kde_keep].kde_prob = kde_res.kde_prob
		st[kde_keep].kde_prob_pat = kde_res.kde_prob_pat
	endif
	if n_elements(chi2_res) ne 0 then begin
		;ADM only care about x2_star as of commissioning selection. 
		; This will probably also be the case going forward but I've left 
		; the other possibilities in case we revamp later
		;			st[chi2_preselect].x2_phot = chi2_res.x2_phot
		st[chi2_preselect].x2_star = chi2_res.x2_star
		;			st[chi2_preselect].z_phot = chi2_res.z_phot
	endif



	wkde = where( (target_flags and bonusflag) eq bonusflag $
		and st.kde_prob gt pars.kde_prob_thresh, nkde)
	splog,'Found '+strn(nkde)+' kde'
	if nkde ne 0 then begin
		boss_target1[wkde] += sdss_flagval('boss_target1','qso_kde') 
	endif



	st.bitmask = $
		flag_bitmask $
		+ gmag_bitmask $
		;ADM don't care about color box
		;			+ color_bitmask $
		+ resolve_bitmask $
		+ calib_bitmask $
		+ bounds_bitmask

	st.qsoselectmethod = target_flags
	st.boss_target1 = boss_target1


	if n_elements(known_matchflags) ne 0 then begin
		st.known_qso_matchflags = known_matchflags
		st.known_qso_id = known_matchids
	endif


	; should we info whether these objects are in various
	; chunks?
	if pars.add_inchunk then begin
		self->add_inchunk, st
	endif




	; Christophe's NN combinator method
	if in(types,'all') or in(types,'combinator') then begin
		splog,'--------------------------------------------------'
		splog,'Running combinator'


		bqnn=obj_new('bosstarget_qsonn', pars=pars)

		gmag = 22.5-2.5*alog10(objs.psfflux[1] > 0.001) - objs.extinction[1]
        value_struct = bqnn->value_select(gmag, $
                                          st.like_ratio_bonus, $
                                          st.kde_prob, $
                                          st.nn_xnn, $
                                          st.nn_znn_phot, $
                                          st.qsoed_prob_bonus, $
                                          st.qsoed_prob_bonus_multi)
        st.nn_value = value_struct.value
        st.nn_weight_value = value_struct.weight_value
        st.nn_value_with_ed = value_struct.value_with_ed
        st.nn_value_with_ed_ukidss = value_struct.value_with_ed_ukidss
        st.boss_target1 += value_struct.boss_target1
	endif

	self->print_pars
	splog,'Total qso time: ',(systime(1)-tm0)/60.,' minutes',$
		form='(a,g0.2,a)'

	return, st


end

function bosstarget_qso::run_qsoed, objs, bitmask=bitmask, multi=multi, verbose=verbose
	splog,'Running extreme deconvolution...bonus'

    nobj = n_elements(objs)
	st = replicate({pqso:             -9999d, $
                    pqso_multiwave:   -9999d, $ ; either have galex or ukidss
                    ukidss_matched:        0, $
                    ukidss_matched_raw:    0, $
                    galex_matched:         0,  $
                    galex_matched_raw:     0  $
                   }, nobj)

    splog,'Matching UKIDSS'
    bukidss = obj_new('bosstarget_qsoukidss')
    ukidss = bukidss->match(objs)

    splog,'Matching GALEX'
    bgalex = obj_new('bosstarget_qsogalex')
    galex = bgalex->match_byrow(objs)

    be=obj_new('bosstarget_qsoed', pars=pars)
    splog,'Normal Processing'
    tmp = be->process_auxiliary(objs,$
                                bitmask=bitmask, $
                                /zfour,          $
                                multi=multi,     $
                                verbose=verbose)
    st.pqso = tmp.pqso


    if n_tags(ukidss) ne 0 or n_tags(galex) ne 0 then begin
        splog,'Running ExD with ukidss/galex'
        tmp = be->process_auxiliary(objs,            $
                                    bitmask=bitmask, $
                                    ukidss=ukidss,   $
                                    galex=galex,     $
                                    /zfour,          $
                                    multi=multi,     $
                                    verbose=verbose)

        w=where(tmp.ukidss_matched_good ne 0 or tmp.galex_matched_good ne 0, nw)
        if nw ne 0 then begin
            st[w].pqso_multiwave = tmp[w].pqso
        endif

        ; "good" matched according to Jo
        st.ukidss_matched = tmp.ukidss_matched_good
        st.galex_matched = tmp.galex_matched_good

        ; all matches
        st.ukidss_matched_raw = tmp.ukidss_matched
        st.galex_matched_raw = tmp.galex_matched

        w=where(tmp.ukidss_matched ne 0, nw)
        wgood=where(tmp.ukidss_matched_good ne 0, ngood)
        splog,'    ',nw,' TOTAL and ',ngood,' GOOD ukidss matched from qsoed',format='(a,i0,a,i0,a)'
        if nw gt 0 then begin
            if nw ne n_elements(ukidss) then message,'not all ukidss matched'
        endif


        w=where(tmp.galex_matched ne 0, nw)
        wgood=where(tmp.galex_matched_good ne 0, ngood)
        splog,'    ',nw,' TOTAL and ',ngood,' GOOD galex matched from qsoed',format='(a,i0,a,i0,a)'
        if nw gt 0 then begin
            if nw ne n_elements(galex) then message,'not all galex matched'
        endif

    endif
	
    return, st

end

function bosstarget_qso::select_varcats, objs_in, nolike=nolike, multi=multi
    tm0 = systime(1)
    ;; no flag logic applied
    ;; no cacheing for kde oqso_r like
    ;; boss_target1 is only set for known and first

	;
	; *
	; * Now for everything else besides core likelihood and known, 
	; * use multi-epoch if available
	; *
	;

    pars = self->pars()

	if tag_exist(objs_in,'PSF_CLEAN_NUSE') and not pars.ignore_multi_epoch then begin
        splog,'Multi-epoch available'
		self.pars.multi_epoch_available = 1
	endif else begin
		self.pars.multi_epoch_available = 0
	endelse

	; add survey coordinates and galactic
	objs = self->add_flux_and_coords(objs_in)
	nobjs = n_elements(objs)
	boss_target1 = lon64arr(nobjs)




	; magnitude range
	gmag_bitmask = self->gmag_logic(objs)
	resolve_bitmask = self->resolve_logic(objs)

	if pars.ignore_bounds then begin
		bounds_bitmask = lonarr(n_elements(objs))
	endif else begin
		bounds_bitmask = self->bounds_bitmask(objs)
	endelse

	;ADM need this for FIRST (don't need to cut bright FIRST objects only faint)
	gmag_bitmask_nob = self->gmag_logic(objs, /no_bright_cut)

	all_bitmask = bounds_bitmask+gmag_bitmask+resolve_bitmask


	self->set_flux, objs, 'single-epoch'

    known_flagsend = bounds_bitmask + resolve_bitmask

    bknown=obj_new('bosstarget_qsoknown', pars=pars)
    bknown->match, objs, known_flagsend, $
        known_matchflags, known_target_flags, known_matchids

    boss_target1[*] += known_target_flags
	


	self->set_flux, objs, 'multi-epoch'


    ; like

    if not keyword_set(nolike) then begin
        bl = obj_new('bosstarget_qsolike', pars=pars)
        like_keep = where(all_bitmask eq 0, nlike)
        if nlike gt 0 then begin
            ;like_struct_bonus = bl->process(objs[like_keep])
            tmps = bl->run(objs[like_keep])
            like_struct_bonus = bl->add_like_ratio(tmps)
        endif
    endif


	splog,'Running extreme deconvolution'
        be=obj_new('bosstarget_qsoed', pars=pars)
	ed_struct_bonus = be->process(objs, bitmask=all_bitmask)
	

	bn = obj_new('bosstarget_qsonn', pars=pars)
	nn_struct = bn->select(objs, bitmask=all_bitmask)
    ;boss_target1[*] += nn_struct.boss_target1


	; ADM to make a reverse UVX cut on the FIRST objects to recover hi-z 
	; matches only
	; ADM, moved this down here (below self->set_flux, objs, 'multi-epoch')
	; on 04/21/10 as there's no reason not to use the
	; coadded colors for the reverse UVX cut, if available
	first_color_bitmask = self->first_color_logic(objs)

	first_bitmask = $
		bounds_bitmask $
		+gmag_bitmask_nob $
		+first_color_bitmask $
		+resolve_bitmask

	bf = obj_new('bosstarget_qsofirst', pars=pars)
    boss_target1[*] += $
        bf->match(objs,bitmask=first_bitmask, firstradio_struct=firstradio_struct2)


	; should we perform kde selection?
	splog,'--------------------------------------------------'
    splog,'Running kde selection'

	kde_keep = where( all_bitmask eq 0,nkde)

	if nkde ne 0 then begin

        splog,'sending '+strn(nkde)+' to kde code'

        bk = obj_new('bosstarget_qsokde', pars=pars)
        kde_res = bk->run(objs[kde_keep])

    endif 

    splog,'--------------------------------------------------'
    splog,'Running chi2 selection'



	; ADM added /nozero keyword so that the initial assign values for $
	; st aren't overwritten
	st = self->struct(count=nobjs)
	struct_assign, objs, st, /nozero


	if n_elements(ed_struct_bonus) ne 0 then begin
		st.qsoed_prob = ed_struct_bonus.pqso
	endif


	if n_elements(nn_struct) ne 0 then begin
		st.nn_xnn = nn_struct.xnn
		st.nn_xnn2 = nn_struct.xnn2
		st.nn_znn_phot = nn_struct.znn_phot
	endif


	if n_elements(firstradio_struct) ne 0 then begin
		st.firstradio_id = firstradio_struct.firstradio_id
		st.firstradio_dist = firstradio_struct.firstradio_dist
	endif

	if n_elements(like_struct_bonus) ne 0 then begin
		if nlike ne 0 then begin
			st[like_keep].like_ratio_bonus = like_struct_bonus.like_ratio
			if tag_exist(like_struct_bonus,'like_ratio_pat') then begin
				st[like_keep].like_ratio_bonus_pat = like_struct_bonus.like_ratio_pat
			endif
		endif
	endif

	st.primary = (resolve_bitmask eq 0)

	if n_elements(kde_res) ne 0 then begin
		st[kde_keep].kde_qsodens_bright = kde_res.kde_qsodens_bright
		st[kde_keep].kde_stardens_bright = kde_res.kde_stardens_bright
		st[kde_keep].kde_qsodens_faint = kde_res.kde_qsodens_faint
		st[kde_keep].kde_stardens_faint = kde_res.kde_stardens_faint
		st[kde_keep].nbc_bright = kde_res.nbc_bright
		st[kde_keep].nbc_faint = kde_res.nbc_faint
		st[kde_keep].gfaint = kde_res.gfaint
		st[kde_keep].kde_prob = kde_res.kde_prob
		st[kde_keep].kde_prob_pat = kde_res.kde_prob_pat
	endif

	st.bitmask = $
		+ gmag_bitmask $
		+ resolve_bitmask $
		+ bounds_bitmask

	st.boss_target1 = boss_target1


	if n_elements(known_matchflags) ne 0 then begin
		st.known_qso_matchflags = known_matchflags
		st.known_qso_id = known_matchids
	endif


	; should we info whether these objects are in various
	; chunks?
	if pars.add_inchunk then begin
		self->add_inchunk, st
	endif




	; Christophe's NN combinator method
    splog,'--------------------------------------------------'
    splog,'Running combinator'


    bqnn=obj_new('bosstarget_qsonn', pars=pars)

    gmag = 22.5-2.5*alog10(objs.psfflux[1] > 0.001) - objs.extinction[1]
    value_struct = $
        bqnn->value_select(gmag, st.like_ratio_bonus, st.kde_prob, st.nn_xnn, st.nn_znn_phot)
    st.nn_value = value_struct.value
    st.nn_weight_value = value_struct.weight_value
    ;st.boss_target1 += value_struct.boss_target1

	self->print_pars
	splog,'Total qso time: ',(systime(1)-tm0)/60.,' minutes',$
		form='(a,g0.2,a)'

	return, st


end

function bosstarget_qso::get_types, types=typesin
	pars = self->pars()
	if n_elements(typesin) eq 0 then types=pars.types else types=typesin

	bu=obj_new('bosstarget_util')
	return, bu->split_by_semicolon(types)
end


function bosstarget_qso::add_flux_and_coords, str
	; Always call this function first!
	pars = self->pars()



	splog,'Adding alternative coordinates'
	eq2csurvey, str.ra, str.dec, clambda, ceta
	glactc, str.ra, str.dec, 2000.0, l, b, 1, /degree

	newst = { $
		clambda:0d, $
		ceta:0d, $
		l: 0d, $
		b: 0d $
	}


	if pars.multi_epoch_available then begin
		tmp = { $
			psfflux_se: fltarr(5), $
			psfflux_se_ivar: fltarr(5), $
			psfflux_me: fltarr(5), $
			psfflux_me_ivar: fltarr(5), $
			psfflux_me_nuse: fltarr(5) $
		}
		newst = create_struct(newst, tmp)
	endif

	newst = create_struct(str[0], newst)
	newst = replicate(newst, n_elements(str))

	struct_assign, str, newst, /nozero
	newst.clambda = clambda
	newst.ceta = ceta
	newst.l = l
	newst.b = b

	if pars.multi_epoch_available then begin
		; check to see if we have psf_clean_nuse > 0 for any objects and
		; if so copy in the combined fluxes over the regular psfflux

		splog,'Copying se and me fluxes'
		newst.psfflux_se = newst.psfflux
		newst.psfflux_se_ivar = newst.psfflux_ivar

		newst.psfflux_me = newst.psfflux_clean
		newst.psfflux_me_ivar = newst.psfflux_clean_ivar
		newst.psfflux_me_nuse = newst.psf_clean_nuse

	endif
	return, newst
end


pro bosstarget_qso::set_flux, str, type
	; ignore this call if we don't have multi epoch

	pars = self->pars()
	if pars.multi_epoch_available then begin

		;; always start with se
		str.psfflux = str.psfflux_se
		str.psfflux_ivar = str.psfflux_se_ivar

		if type eq 'multi-epoch' then begin
			splog,'Setting multi-epoch flux'
			for i=0,4 do begin

                ; changed to gt 0: sometimes, when the primary object is
                ; non-photometric, the flux from a single photometric 
                ; secondary object can be used.  nuse for psfflux in
                ; the stars datasweep will be zero if the object is not 
                ; primary

				w=where(str.psfflux_me_nuse[i] gt 0, nw)
				if nw gt 0 then begin
					splog,'  band: ',i,': ',nw,form='(a,i0,a,i0)'
					str[w].psfflux[i] = str[w].psfflux_me[i]
					str[w].psfflux_ivar[i] = str[w].psfflux_me_ivar[i]
				endif
			endfor
		endif

	endif
end


function bosstarget_qso::extra_logic, str, extra_logic, negate=negate
	command = 'logic = '+extra_logic
	splog,'getting extra logic with command = ',command,format='(a,a)'
	if not execute(command) then begin
		message,'Failed to execute extra logic command: '+command
	endif

	if keyword_set(negate) then begin
		logic = logic eq 0
	endif

	return, logic
end



function bosstarget_qso::flag_logic, objs
; 15-May-2009: rewritten extensively for new flags requirements
;		old version remains in this file "flag_logicOLD"
;		now only check composites...makes colorflags_check redundant
;		Adam D. Myers, UIUC

	pars=self->pars()

	;-----
	; Select Point sources, bit 0
	;

	splog,'checking flags'
	check = (objs.objc_type NE 6) 
	bitmask = check*self->badflag('extended')
	self->debug_flags,'objc_type',bitmask

	;-----
	; Check bad photometry flags
	;
	;filters of interest, can be easily changed to remove z filter
;	jfilt=[0, 1, 2, 3, 4] 

;	object1_flags = objs.flags
;	object2_flags = objs.flags2
;
; ADM we just need to check on the composite flags, so don't call colorflags_check anymore
; ADM rather we just call sdss_flagval to look for the composite flag

	;-----
	; Are the photometric errors in g,r,i too high?
	; softening parameters from EDR paper in units of 1.0e-10 
	; (Stoughton et al. 2002) in inelegantly created 5-element array
	bsoft = fltarr(5,n_elements(objs))
	bsoft[0,*] = 1.4
	bsoft[1,*] = 0.9
	bsoft[2,*] = 1.2
	bsoft[3,*] = 1.8
	bsoft[4,*] = 7.4

	bu=obj_new('bosstarget_util')
	psfmagerrs = bu->ivar2magerr(objs.psfflux_ivar,objs.psfflux,bsoft)

	magerrset = $
		reform(psfmagerrs[1,*] gt 0.2 or $
			psfmagerrs[2,*] gt 0.2 or psfmagerrs[3,*] gt 0.2)

	; does this object have interpolation problems? 
	; defined as INTERP PROBLEMS = (PSF FLUX INTERP &&
	; 	(gerr > 0.2 || rerr > 0.2 || ierr > 0.2)) || BAD COUNTS ERROR ||
	;	(INTERP CENTER && CR)
	
	pfiset = (objs.objc_flags2 and sdss_flagval('object2','psf_flux_interp')) ne 0
	bceset =  (objs.objc_flags2 and sdss_flagval('object2','bad_counts_error')) ne 0
	icset = (objs.objc_flags2 and sdss_flagval('object2','interp_center')) ne 0
	crset = (objs.objc_flags and sdss_flagval('object1','cr')) ne 0
	check = (pfiset and magerrset) or bceset or (icset and crset)
	bitmask += check*self->badflag('interp_problems')
	self->debug_flags,'interp_problems',bitmask

	; does this object have deblend problems? 
	; defined as DEBLEND PROBLEMS = PEAKCENTER || NOTCHECKED
	; || (DEBLEND NOPEAK && (gerr > 0.2 || rerr > 0.2 || ierr > 0.2)) 

	pcset = (objs.objc_flags and sdss_flagval('object1','peakcenter')) ne 0
	ncset = (objs.objc_flags and sdss_flagval('object1','notchecked')) ne 0
	dbnpset = (objs.objc_flags2 and sdss_flagval('object2','deblend_nopeak')) ne 0
	check = pcset or ncset or (dbnpset and magerrset)
	bitmask += check*self->badflag('deblend_problems')
	self->debug_flags,'deblend_problems',bitmask

	; does this object have binned1 flag UNSET? Not, remember, set!
	check = (objs.objc_flags and sdss_flagval('object1','binned1')) eq 0
	bitmask += check*self->badflag('not_binned1')
	self->debug_flags,'not_binned1',bitmask

	; does this object have bright flag set?
	check = (objs.objc_flags and sdss_flagval('object1','bright')) ne 0
	bitmask += check*self->badflag('bright')
	self->debug_flags,'bright',bitmask

	; does this object have satur (saturated) flag set?
	check = (objs.objc_flags and sdss_flagval('object1','satur')) ne 0
	bitmask += check*self->badflag('satur')
	self->debug_flags,'satur',bitmask

	; does this object have edge flag set?
	check = (objs.objc_flags and sdss_flagval('object1','edge')) ne 0
	bitmask += check*self->badflag('edge')
	self->debug_flags,'edge',bitmask

	; does this object have blended flag set?
	check = (objs.objc_flags and sdss_flagval('object1','blended')) ne 0
	bitmask += check*self->badflag('blended')
	self->debug_flags,'blended',bitmask

	; does this object have nodeblend flag set?
	check = (objs.objc_flags and sdss_flagval('object1','nodeblend')) ne 0
	bitmask += check*self->badflag('nodeblend')
	self->debug_flags,'nodeblend',bitmask

	; does this object have noprofile flag set?
	check = (objs.objc_flags and sdss_flagval('object1','noprofile')) ne 0
	bitmask += check*self->badflag('noprofile')
	self->debug_flags,'noprofile',bitmask

	; Check if object is moving
	if not pars.allow_move then begin
		mvflag = sdss_flagval('OBJECT2','DEBLENDED_AS_MOVING')
               ;ADM check if we are using the dr9 sweeps for which
               ;ADM rowv and colv were rescaled (linearly) and renamed
               ;ADM rowvdeg and colvdeg
                if pars.dr9 then begin
                   qmaybe_moved = $
                      (objs.objc_flags2 AND mvflag) NE 0 $
                      AND (abs(objs.rowvdeg) GE 3.0*abs(objs.rowvdegerr) $
                           OR abs(objs.colvdeg) GE 3.0*abs(objs.colvdegerr)) $
                      AND objs.rowvdegerr GT 0 AND objs.colvdegerr GT 0                
                endif else begin
                   qmaybe_moved = $
                      (objs.objc_flags2 AND mvflag) NE 0 $
                      AND (abs(objs.rowv) GE 3.0*abs(objs.rowverr) $
                           OR abs(objs.colv) GE 3.0*abs(objs.colverr)) $
                      AND objs.rowverr GT 0 AND objs.colverr GT 0
                endelse
		self->debug_flags,'moved',bitmask

		bitmask+=qmaybe_moved * self->badflag('moved')
	endif

	return, bitmask

end

function bosstarget_qso::gmag_logic, objs, no_bright_cut = no_bright_cut
; 15-May-2009: rewritten for BOSS selection circa commissioning
;		extinction correct magnitude limits
;		switched to asinh magnitudes not maggies
;		fixed i < gmag_min bug
;		added reform of array to multiple band logic
;		Adam D. Myers, UIUC
;8-Dec-2009
;		Now if you pass the /no_bright_cut keyword it
;		will ignore the bright end cut
;		Adam D. Myers, UIUC


	splog,'checking mags'
	;------- 
	;------- 
	; Initial color box: g<22, u-g>0.3, g-r<1

	pars = self->pars()
	min_imag = pars.min_imag
	max_gmag = pars.max_gmag
	max_rmag = pars.max_rmag

	;max_gmag = 22.0
	;min_gmag = 15.0
	;min_imag = 17.8
	;max_rmag = 21.85
	;min_umg = 0.3
	;max_gmr = 1.0

	; don't extinction correct for mag cut
	;ADM extinction correct for mag cut
	bu=obj_new('bosstarget_util')
	deredflux =  bu->deredden(objs.psfflux, objs.extinction)

	;ADM  inelegant way of creating 5-element softening array
	bsoft = fltarr(5,n_elements(objs))

	; softening parameters from EDR paper in units of 1.0e-10 
	; (Stoughton et al. 2002)
	bsoft[0,*] = 1.4
	bsoft[1,*] = 0.9
	bsoft[2,*] = 1.2
	bsoft[3,*] = 1.8
	bsoft[4,*] = 7.4

	;ADM changed to strict asinh magnitudes
	;	psfmags = 22.5-2.5*alog10(objs.psfflux > 0.001)
	bu=obj_new('bosstarget_util')
	psfmags = bu->flux2mags(deredflux,bsoft)

	;ADM this was a bug, I think. should have been psfmags[1,*] not psfmags[1,*]
	;ADM changed to selection in g and r anyway
	;	check = reform(psfmags[1,*] gt max_gmag or psfmags[3,*] lt min_gmag)
	;	bitmask = check*self->badflag('gmag_range')
	;	self->debug_flags,'gmag range',bitmask

	; we might want to implement this logic
	; remember, these are those we are throwing out
	; here is what we would keep
	;check = $
	;	psfmags[1,*] gt min_gmag and $
	;		( (psfmags[1,*] lt max_gmag) or (psfmags[3,*] lt max_imag) )
	;	

	;ADM this is the correct logic, I think I had to add a "reform"
	;	check = $
	;		reform(psfmags[1,*] lt min_gmag or $
	;			( (psfmags[1,*] gt max_gmag) and (psfmags[2,*] gt max_rmag) ))

	;ADM changed to min being imag
	;ADM fixed gmag_range/gmag_range_no_bright_cut badflag bug on June 30, 2010
	if not keyword_set(no_bright_cut) then begin
		check = $
			reform(psfmags[3,*] lt min_imag or $
				( (psfmags[1,*] gt max_gmag) and (psfmags[2,*] gt max_rmag) ))
		bitmask = check*self->badflag('gmag_range')
		self->debug_flags,'gmag range',bitmask
	endif else begin
		check = $
			reform(( (psfmags[1,*] gt max_gmag) and (psfmags[2,*] gt max_rmag) ))
		bitmask = check*self->badflag('gmag_range_no_bright_cut')
		self->debug_flags,'gmag range_no_bright_cut',bitmask	
	endelse
	return, bitmask
end
	
function bosstarget_qso::color_logic, objs

	min_umg = 0.3
	max_gmr = 1.0

	psfmags = 22.5-2.5*alog10(objs.psfflux > 0.001)
	psfmags = psfmags - objs.extinction

	check = reform( (psfmags[0,*] - psfmags[1,*]) lt min_umg)
	bitmask = check*self->badflag('umg_too_blue')
	self->debug_flags,'umg',bitmask
	check = reform( (psfmags[1,*] - psfmags[2,*]) gt max_gmr)*2L^10
	bitmask += check*self->badflag('gmr_too_red')
	self->debug_flags,'gmr',bitmask

	; this old code was reversed in logic
	;thisflux = objs.psfflux*10^(objs.extinction/2.5) ;dereddening the colors

	;bitmask+= ((thisflux[1,*] GT 10.^(22.5 - 22.0)/2.5) $
	;	AND (thisflux[1,*] GT thisflux[0,*]*10.^(0.3/2.5)) $
	;	AND (thisflux[2,*] LT thisflux[1,*]*10.^(1/2.5)) EQ 0) * 2L^10
	;self->debug_flags,'color',bitmask

	return, bitmask

end


function bosstarget_qso::first_color_logic, objs
;ADM make a reverse UVX cut for first objects
;will flag things as bad if they have uvx < pars.firstuvx

	pars = self->pars()

	min_umg = pars.firstuvx

	bu=obj_new('bosstarget_util')
	lups = bu->get_lups(objs, /deredden)
	umg = reform(lups[0,*]-lups[1,*])

	check = reform( umg lt min_umg)
	bitmask = check*self->badflag('first_match_umg_too_blue')

	return, bitmask

end


function bosstarget_qso::resolve_logic, objs

	splog,'checking resolve'
	primaryflag = sdss_flagval('RESOLVE_STATUS','SURVEY_PRIMARY')
	check = ((objs.resolve_status AND primaryflag) eq 0)

	bitmask = check*self->badflag('not_primary')
	self->debug_flags,'primary',bitmask

	return, bitmask
end

function bosstarget_qso::calib_logic, objs

	;----
	; Check to see if the observation was photometric. Set bit  if it is
	; *not* photometric

	splog, 'checking calib'
	check = self->colorflags_check(objs.calib_status, $
							'calib_status','photometric', /notset)
	bitmask = check*self->badflag('not_photometric')

	self->debug_flags,'photometric',bitmask

	return, bitmask

end

function bosstarget_qso::bounds_bitmask, objs, $
		stripe82=stripe82


	nobjs=n_elements(objs)

	pars=self->pars()
	bu=obj_new('bosstarget_util')
	chunks = bu->split_by_semicolon(pars.bounds)
	nchunk = n_elements(chunks)

	bitmask = lonarr(nobjs)

	bt=obj_new('bosstarget')
	inchunk = intarr(nobjs)
	for i=0L, nchunk-1 do begin
		chunk=chunks[i]
		splog,'checking polygon region: "',chunk,'"',format='(a,a,a)'
		inchunk[*] += bt->is_in_chunk(chunk, objs.ra, objs.dec)
	endfor
	obj_destroy, bt

	wbad=where(inchunk eq 0, nbad)
	if nbad ne 0 then begin
		bitmask[wbad] = 1
		bitmask = bitmask*self->badflag('out_of_bounds')
	endif

	splog,'Passed region check: ',nobjs-nbad,'/',nobjs,form='(a,i0,a,i0)'
	
	return, bitmask


end

pro bosstarget_qso::debug_flags, type, bitmask
	;splog,'    ',type
	w=where(bitmask eq 0, nw)
	splog,type,'  pass ',nw,' / ',n_elements(bitmask), $
		format='(a,a,i0,a,i0)'
end

function bosstarget_qso::colorflags_check, flags, objflagtype, flagname, $
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




function bosstarget_qso::badflag, name, $
                photo_flags=photo_flags, $
                mag_flags=mag_flags
; 15-May-2009: Rewritten extensively for new flags requirements
;		flag names all changed
;		Adam D. Myers, UIUC
; 8-Dec-2009	added flag for things that are too red or too faint for first


	nnames = n_elements(name)
	if n_elements(name) gt 1 then begin
		flagtot=0LL
		for i=0LL, nnames-1 do begin
			flagtot += self->badflag(name[i])
		endfor
		return, flagtot
	endif

	if keyword_set(photo_flags) then begin
		flagnames=['extended','interp_problems', $
		'deblend_problems','not_binned1','edge','bright','satur','moved', $
		'blended','nodeblend','noprofile']

		return, self->badflag(flagnames)
	endif

	if keyword_set(mag_flags) then begin
		flagnames=['gmag_range']
		return, self->badflag(flagnames)
	endif

	case strlowcase(name) of

		'extended': return, 2L^0
		'interp_problems': return, 2L^1
		'deblend_problems': return, 2L^2
		'not_binned1': return, 2L^3	
		'edge': return, 2L^4
		'bright': return, 2L^5
		'satur': return, 2L^6
		'moved': return, 2L^7
		'blended': return, 2L^8
		'nodeblend': return, 2L^9
		'noprofile': return, 2L^10

		'gmag_range': return, 2L^11
		'gmag_range_no_bright_cut': return, 2L^12

		'not_primary': return, 2L^13
		'not_photometric': return, 2L^14
		'extra_logic': return, 2L^15
		'out_of_bounds': return, 2L^16

		'first_match_umg_too_blue': return, 2L^17

		else: begin
			on_error,2
			message,'Unknown select type: '+string(name)
		end
	endcase

end




function bosstarget_qso::struct, count=count
	st = { $
		run: 0L, $
		rerun: '', $
		camcol: 0L, $
		field: 0L, $
		id: 0L, $
		ra: -9999d, $
		dec: -9999d, $
		resolve_status: 0L, $
		primary:0b, $
		photometric:0b, $
; ADM commented out only need x2_star as of commissioning. This will probably also
; be the case going forward but I've left the commented out stats in case we revamp
;		x2_phot:-9999.9, $
		x2_star:-9999.9, $
;		z_phot:-9999.9, $
		kde_qsodens_bright:-9999.9, $
		kde_stardens_bright:-9999.9, $
		kde_qsodens_faint:-9999.9, $
		kde_stardens_faint:-9999.9, $
		nbc_bright: [-9999.9d0,-9999.9d0,-9999.9d0,-9999.9d0], $
		nbc_faint: [-9999.9d0,-9999.9d0,-9999.9d0,-9999.9d0], $
		kde_prob: -9999.9d0, $
		kde_prob_pat: -9999.9d0, $
		gfaint:-1, $
		bitmask: 0LL, $
; ADM added qsoselectmethod...track qso selection internally so we can have yes/no bosstaget flag
		qsoselectmethod: 0LL, $
		known_qso_matchflags: 0LL, $
		known_qso_id: -9999L, $
		$
		like_ratio_core: -9999., $
		like_ratio_bonus: -9999., $
		like_ratio_bonus_pat: -9999., $
		$
		nn_id: -9999L, $
		nn_xnn: -9999.9, $
		nn_xnn2: -9999.9, $
		nn_znn_phot: -9999.9, $
		$
		firstradio_id: -9999L, $
		firstradio_dist: -9999.9, $
		$
		kde_coadd_id:-9999L,$
		kde_coadd_x2_star: -9999L, $
		kde_coadd_kde_qsodens_bright: -9999.0, $
		kde_coadd_kde_qsodens_faint: -9999.0, $
		kde_coadd_kde_stardens_bright: -9999.0, $
		kde_coadd_kde_stardens_faint: -9999.0, $
		$
		ukidss_id: -9999L, $
		$
		; a combined quantity from xnn,like_ratio,kde_prob
		nn_value: -9999.0, $
		nn_weight_value: -9999.0, $
        nn_value_with_ed: -9999.0, $
        nn_value_with_ed_ukidss: -9999.0, $
		$
		inchunk:0LL, $
		inchunk_bounds:0LL, $
		intest_region: 0, $
		$
		qsoed_prob_core: -9999d, $
		qsoed_prob_bonus: -9999d, $
		qsoed_prob_bonus_multi: -9999d, $
        ;ADM these are populated with 1 where
        ;ADM we find galex or ukidss matches
        ukidss_matched: 0, $
        ukidss_matched_raw: 0, $
        galex_matched: 0, $
        galex_matched_raw: 0, $
		$
		boss_target1_pre: 0LL, $
		boss_target1: 0LL}

	; need to set this parameter *before* calling this function!
	pars = self->pars()
	if pars.multi_epoch_available then begin
		new_struct = { $
			psfflux_se: replicate(-9999.0,5),      $
			psfflux_se_ivar: replicate(-9999.0,5), $
			psfflux_me: replicate(-9999.0,5),      $
			psfflux_me_ivar: replicate(-9999.0,5),  $
			psfflux_me_nuse: intarr(5) $
		}
		st = create_struct(st, new_struct)
	endif


	if n_elements(count) ne 0 then begin
		st = replicate(st, count)
	endif

	return, st
end


















































pro bosstarget_qso::add_inchunk, str
	; add info if these objects are in chunk window functions
	bt=obj_new('bosstarget')

	str.inchunk_bounds=0
	str.inchunk=0
	str.intest_region=0

	for chunk=1,10 do begin
		flag = 2LL^(chunk-1)

		splog,'  inchunk flag: ',flag
		splog,'  * checking bounds window for chunk: ',chunk,form='(a,i0)'
		inchunk = bt->is_in_chunk(chunk,str.ra,str.dec,/bounds)
		str.inchunk_bounds += inchunk*flag

		; we can speed the full check up a lot by only using objects
		; that pass the bounds window check
		w = where(inchunk, nw)
		splog,'  * found ',nw,form='(a,i0)'
		if nw gt 0 then begin
			splog,'  * checking full window for chunk: ',chunk,form='(a,i0)'
			inchunk=bt->is_in_chunk(chunk,str[w].ra,str[w].dec)
			str[w].inchunk += inchunk*flag
			
			w2=where(inchunk,nw2)
			splog,'  * found ',nw2,form='(a,i0)'
		endif else begin
			splog,'  * No objects in bounds window, skipping full check'
		endelse
	endfor


	
	w=where(str.inchunk_bounds gt 0,nw)
	splog,'Found total of ',nw,' in bounds',form='(a,i0,a)'



	; this is a big test region in the ngc
	flag = 2^0
	inchunk = bt->is_in_chunk('ngc-large', str.ra, str.dec)	
	str.intest_region += inchunk*flag
	w=where(str.intest_region gt 0,nw)
	splog,'Found total of ',nw,' in ngc-large',form='(a,i0,a)'

	; need to create this one
	;flag = 2^1
	;inchunk = bt->is_in_chunk('sgc-large', str.ra, str.dec)	
	;str.intest_region = inchunk*flag


	obj_destroy,bt

end




pro bosstarget_qso::print_pars, pars
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





pro bosstarget_qso__define
	parstruct = bosstarget_qso_default_pars()
	struct = {$
		bosstarget_qso, $
		inherits bosstarget_qsopars $
	}
end


