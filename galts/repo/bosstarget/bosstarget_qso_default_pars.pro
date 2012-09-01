function bosstarget_qso_default_pars

	; KDE density-based parameters with which to select targets:
	; can alter selection for bright and faint cuts and for permissive and 
	; restrictive selection 

	; bonus/permissive
	;logqsodensmin_bright_permissive = -0.57
	;logqsodensmin_faint_permissive = -0.57

	;logstardensmax_bright_permissive = -0.095
	;logstardensmax_faint_permissive = -0.52

	; core/restrictive
	logqsodensmin_bright_restrictive = -0.57
	logqsodensmin_faint_restrictive = -0.57

	; New parameters based on parameter space exploration
	; gives 1.1:1 bright/faint ratio for core in -30< ra < 30
	logstardensmax_bright_restrictive = -0.63
	logstardensmax_faint_restrictive = -0.65

	; fiber ratios are 1:1 bright:faint for the restrictive, bonus sample
	; fiber ratios are 5:4 bright:faint for the permissive, 
	;bonus+core sample

	; both are now restrictive 7.0
	x2star_permissive= 7.0
	x2star_restrictive= 7.0

	; new loose cuts for just using kde_prob
	logstardensmax_bright_permissive= 0.5
	logstardensmax_faint_permissive=  0.3
	logqsodensmin_bright_permissive= -1.0
	logqsodensmin_faint_permissive=  -1.0


	btd=getenv('BOSSTARGET_DIR')
	if btd eq '' then message,'$BOSSTARGET_DIR not set'
	datad=filepath(root=btd, 'data')

	bindir=filepath(root=btd, 'bin')
	program=filepath(root=bindir, 'qso-kde')

	if not file_test(program) then begin
		message,'file '+program+' not found'
	endif


	;qso_bonus_tuned_x2star = qso_bonus_tuned_x2_star_read()
	;kde_coadd_tuned_x2star = kde_coadd_tuned_x2_star_read()


	pars= { bosstarget_qso_parstruct, $
		types: 'all', $ ;run all types of selection. Can separate with ;
		multi_epoch_available: 0, $ ; This will be set internally
        ignore_multi_epoch: 0, $ ; even if multi-epoch fluxes detected, don't use them
		add_inchunk: 0, $ ; add flags about chunks the objects are in
		bounds: 'boss', $ ; bounds_bitmask limits to these areas. can
		;                   separate by semicolons: '2;3'
		commissioning: 0, $
		comm2: 0, $
		; if 1, don't use the calib_status information, e.g. photometric
		nocalib: 1, $ 
		loose: 0, $
		oldcache: 0, $
		ignore_resolve: 0, $
		allow_move: 0, $
		ignore_bounds: 0, $
		$
		; target directory, binary for kde and data directory
		bosstarget_dir: btd, $
		prog: program, $
		datadir:datad, $
		; input parameter cuts 
		logqsodensmin_bright_permissive: logqsodensmin_bright_permissive, $
		logstardensmax_bright_permissive: logstardensmax_bright_permissive, $
		logqsodensmin_faint_permissive: logqsodensmin_faint_permissive, $
		logstardensmax_faint_permissive: logstardensmax_faint_permissive, $
		logqsodensmin_bright_restrictive: logqsodensmin_bright_restrictive, $
		logstardensmax_bright_restrictive: logstardensmax_bright_restrictive, $
		logqsodensmin_faint_restrictive: logqsodensmin_faint_restrictive, $
		logstardensmax_faint_restrictive: logstardensmax_faint_restrictive, $
		; command line flags for kernel density estimation
		kdemodel:'kde', $
		kdescaling: 'none', $
		kdekernel: 'gaussian', $
		kdemethod: 'dual_tree', $
		kdebw: '.05', $
		; command line flags for non-parametric bayesian classifier
		nbcmodel:'nbc', $
		nbcscaling: 'none', $
		nbckernel: 'epanechnikov', $
		nbcprior: '0.50', $
		nbcbw: '.05', $
		nbcbw2: '.05', $
		; g magnitude split that defines bright and faint selection
		gsplit:21.0, $
		; input training files for kernel density estimator
		bright_qsofile: 'sdssdr7_qso_star_train_boss_bright_qsos7n.dat', $
		bright_starfile: 'sdssdr7_qso_star_train_boss_bright_stars7n.dat', $
		faint_qsofile: 'sdssdr7_qso_star_train_boss_faint_qsos7n.dat', $
		faint_starfile: 'sdssdr7_qso_star_train_boss_faint_stars7n.dat', $
		; input training files for non-parametric bayesian classifier
		bright_colorfile: 'sdssdr5_qso_star_train_boss_bright_colors5.dat', $
		bright_labelfile: 'sdssdr5_qso_star_train_boss_bright_labels5.dat', $
		faint_colorfile: 'sdssdr5_qso_star_train_boss_faint_colors5.dat', $
		faint_labelfile: 'sdssdr5_qso_star_train_boss_faint_labels5.dat', $
		; do we want to use the nbc to determine pat rankings (1) or not (0)?
		patrank: 0, $
		; begin chi2 pars
		qso_bonus_dotrim: 0, $
		x2star_permissive: x2star_permissive, $
		x2star_restrictive: x2star_restrictive, $
		$
		; for gmag logic (not just gmag any more!)
		max_gmag: 22.0, $
		max_rmag: 21.85, $
		min_imag: 17.8, $
		$
		; about 60/sqdegre
		kde_prob_thresh: 0.43, $
		$
		;
		; we took these from the old comm2 run, what about xnn which has
		; changed definitioin?
		; this gives 35.7/sq deg with no bright end cut, but 
		; 32.8/sq deg when we include the bright end cut in i
		;likelihood_thresh: 0.255, $
		; this one gives 35 with the bright end cut
		; old likelihoods
		;oldlike: 0, $
		likelihood_version: 'v1', $
		$
		; use Christophe's ranking to set qso_bonus_main
		nnrank: 1, $
		; high density, will trim down later to get our 40/sq degree
		nn_value_thresh: 0.30, $
		;
		; about 60/sq degree 
		;likelihood_thresh: 0.13, $
		;likelihood_mcthresh: 0.058, $
		; about 40/sq degree
		likelihood_thresh: 0.234, $
		;
		; gives 20/sq degree in blind test region
		likelihood_thresh_core: 0.543, $
		;
		; ExD parameters
		; gives 20/sq degree in blind test region
		;ed_thresh_core: 0.372, $ ; shadowing value
		;ed_thresh_core: 0.4295, $ ;tuned over ngcgood2
		ed_thresh_core: 0.4240, $ ;tuned over sgc+ngc
		;
		; NN parameters
		use_nn2: 0, $
		;this one gives 20/sq degree for new nn code
		;nn_xnn_thresh: 0.868, $
		; about 60/sq degree
		nn_xnn_thresh: 0.64, $
		nn_xnn2_thresh: 0.868, $
		nn_znn_thresh:2.0, $
		;nn_umg_min: 0.4, $
		nn_umg_min: 0.2, $
		nn_gmi_max: 2.0, $
		nn_urange: [18.0,25.0], $
		nn_grange: [18.0,22.5], $
		nn_rrange: [18.0,22.0], $
		nn_irange: [18.0,22.0], $
		nn_zrange: [18.0,22.5], $
		$
		; (reverse) uvx cut to throw out low-z first objects
		firstuvx:0.4, $
        ; initial matching for double lobe search
        firstlobe_matchrad: 2d/3600d, $
		; the rank cuts for old likelihood
		kde_rank_cut_old: 0.86, $
		like_rank_cut_old: 0.25, $
		nn_rank_cut_old: 0.67, $
		$
		kde_rank_cut_core: 0.99966d, $
		like_rank_cut_core: 0.903d, $
		nn_rank_cut_core: 0.9937d, $
		$
		kde_rank_cut_bonus: 0.843d, $
		like_rank_cut_bonus: 0.243d, $
		nn_rank_cut_bonus: 0.6249d, $
		;
		; some stuff exclusive to older versions of the algorithms
		;
		;qso_bonus_x2_star_struct: qso_bonus_tuned_x2star, $
		ra_dens_bounds:[-15d,30d], $
		$
		x2star_restrictive_region1:7.0, $
		x2star_restrictive_region2:9.34, $
		x2star_restrictive_region3:9.63, $
		$
		;kde_coadd_x2_star_quadfit: kde_coadd_tuned_x2star.quadfit, $
		kde_coadd_dotrim: 1, $
		kde_coadd_x2star_region1:7.75, $; unused
		kde_coadd_x2star_region2:3.0, $ ; unused
		kde_coadd_x2star_region3:8.16, $ ; unused
		kde_coadd_logqsodens_bright: -0.57, $
		kde_coadd_logqsodens_faint: -0.57, $
		kde_coadd_logstardens_bright: 0.065, $
		kde_coadd_logstardens_faint: 0.065, $
		; known object matching
		known_matchrad1: 1.5d,  $ ; initial match radius in arcsec
		known_matchrad2: 2.0d,  $ ; second match radius in arcsec
		known_max_magdiff: 0.5, $ ; max mag diff for second match
		known_zlo: 2.15,        $ ; low end of "mid" z range
		;known_zlo: 2.2,        $ ; low end of "mid" z range
		known_zhi: 9.99,        $ ; high end of "mid" z range
                known_zsupp: 1.8,       $ ; low z of supplementals for second fiber pass
                dr9: 0                  $ ; set to 1 to use dr9 style sweeps (rowv changed)     
              }

	return, pars

end



