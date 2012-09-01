function bosstarget_qsochi2::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsochi2::select, objs, pars=pars, _extra=_extra

	nobjs = n_elements(objs)
	if  nobjs eq 0 then begin
		message,'Usage: boss_target1=bc->select(objs, pars=pars, _extra=_extra)'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	res=self->process(objs)
	return, res

end


function bosstarget_qsochi2::process, objs, Z_IN, zmin=zmin

	nobjs = n_elements(objs)

	pars=self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)
	qsocache->match, 'chi2', self, objs, mobjs, mcache, cache=cache

	if mobjs[0] eq -1 then begin
		message,'Found no matches!!!'
	endif

	nmobjs=n_elements(mobjs)
	if n_elements(mobjs) ne nobjs then begin
		splog,'Some objects did not match the chi2 cached file!'
		splog,'    ',n_elements(mobjs),'/',n_elements(ind),form='(a,i0,a,i0)'
		message,'Halting'
	endif

	splog,'Found ',nmobjs,' chi2 matches',form='(a,i0,a)'

	x2_struct = cache[mcache]
	return, x2_struct
end


pro bosstarget_qsochi2::cache_generate, objs

	pars = self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)

	tm1=systime(1)

	run=objs[0].run
	rerun=objs[0].rerun
	camcol=objs[0].camcol
	file=qsocache->file('chi2',run, rerun, camcol)

	splog,'Will write to file: ',file,form='(a,a)'

	x2_struct = self->calculate_chi2(objs)

	qsocache->write, 'chi2', x2_struct, run, rerun, camcol

end


pro bosstarget_qsochi2::cache_combine


	pars=self->pars()
	qsocache=obj_new('bosstarget_qsocache', pars=pars)
	front=qsocache->front('chi2')
	dir=qsocache->dir()
	pattern = filepath(root=dir,front+'-*-*-*.fits')
	print,pattern
	files=file_search(pattern)

	tmp = mrdfits_multi(files)

	if n_tags(tmp) eq 0 then message,'error'
	self->cache_write, 'chi2', tmp, /combined

end





function bosstarget_qsochi2::calculate_chi2, objs

	common x2_tags_block, locus_set, locus_struct, colorz_set, colorz_struct

	if not keyword_set(locus_set) then begin
		indir=getenv('BOSSTARGET_DIR')
		indir=filepath(root_dir=indir, 'data')

		locusfile = filepath(root_dir=indir, 'stellar_locus.fits')
		locus_struct = mrdfits(locusfile, 1)
		locus_set    = mrdfits(locusfile, 2)
    
	endif

	;; output structure
	nobjs = n_elements(objs)
	x2_struct = self->struct(nobjs)
	struct_assign, objs, x2_struct, /nozero

	;; add some info
	bu=obj_new('bosstarget_util')
	objs_add = bu->deredden_assign(objs)

	; model stars
	nlocus = 300L
	splog,'Getting stellar locus model'
	star_model = self->stellar_locus(locus_struct, locus_set, nlocus)

	; get the actaul x2_star
	splog,'Running star_stat'
	x2_struct.x2_star = self->star_stat(objs_add, star_model, /silent)

	; generate flags
	splog,'Getting target flags'
	x2_struct.boss_target1 = self->get_target_flags(x2_struct)

	return, x2_struct
end

function bosstarget_qsochi2::get_target_flags, res

	nobjs=n_elements(res)
	if nobjs eq 0 then begin
		message,'Usage: flags=bq->get_chi2_target_flags(res, pars=)'
	endif

	pars = self->pars()
	bu=obj_new('bosstarget_util')

	target_flags = lon64arr(nobjs)

	wquasar_bonus = where(res.x2_star ge pars.x2star_permissive, count)

	if count gt 0 then begin
		target_flags[wquasar_bonus] += bu->qsoselectflag('qso_chi2_bonus')
	endif

	wquasar_core = where(res.x2_star ge pars.x2star_restrictive, count)


	if count gt 0 then begin
		target_flags[wquasar_core] += bu->qsoselectflag('qso_chi2_core')
	endif

	return, target_flags

end


;docstart::bosstarget_qsochi2::stellar_locus
; NAME:
;   bosstarget_qsochi2::stellar_locus
;
; PURPOSE:
;    Generate a stellar locus using the b-spline fit constructed by 
;    create_stellar_locus.pro
;
; CALLING SEQUENCE:
;	bq = obj_new('bosstarget_qso')
;   stars= bq->stellar_locus(locus_struct, locus_set, nstars $
;            [, ug = , gr = , ri = , iz = , gi = ,) 
; INPUTS:
;   locus_struct  - structure with information on the how the locus
;                   was constructed
;   locus_set     - structure containing the spline set generated
;                   by bspline_iterfit
;
; OUTPUTS: 
;    stars        - Structure with fluxes and flux errors for the stars
;                   along the model locus. This has nstars elements, i.e.
;                   one for each point along the locus.  
; OPTIONAL KEYWORDS:
;    ug       =  Optionally output all the colors and color-errors
; COMMENTS:
;   
;
; EXAMPLE:
;    locusfile = '/u/jhennawi/Projects/hiz/data/stellar_locus.fits'
;    locus_struct = mrdfits(locusfile, 1)
;    locus_set    = mrdfits(locusfile, 2)
;    stars=stellar_locus(locus_struct, locus_set, 300)
;
; PROCEDURES CALLED:
;      bspline_valu
;   
; REVISION HISTORY:
;   1-Sep-2005  Written by Joe Hennawi UCB 
;	13-Jan-2009: Moved into class file, formatting.
;		Erin Sheldon, BNL
;    
;docend::bosstarget_qsochi2::stellar_locus

function bosstarget_qsochi2::STELLAR_LOCUS, locus_struct, locus_set, nstars $
                        , ug = ug, gr = gr, ri = ri, iz = iz, gi = gi $
                        , sig_ug = sig_ug, sig_gr = sig_gr, sig_ri = sig_ri $
                        , sig_iz = sig_iz, sig_gi = sig_gi $
                        , param_gi = param_gi

	bu = obj_new('bosstarget_util')
	; softening parameters from EDR paper in units of 1.0e-10 
	; (Stoughton et al. 2002)
	b_u = 1.4
	b_g = 0.9
	b_r = 1.2
	b_i = 1.8
	b_z = 7.4

	; bspline sets
	uset   = locus_set[0]
	gset   = locus_set[1]
	rset   = locus_set[2]
	iset   = locus_set[3]
	zset   = locus_set[4]
	udset  = locus_set[5]
	gdset  = locus_set[6]
	rdset  = locus_set[7]
	idset  = locus_set[8]
	zdset  = locus_set[9]

	; r-i colors parameterizes locus
	IF NOT KEYWORD_SET(PARAM_GI) THEN BEGIN
		gi_min = locus_struct.GI_MIN
		gi_max = locus_struct.GI_MAX
		param_gi = gi_min + (gi_max-gi_min)*findgen(nstars)/float(nstars-1L)
	ENDIF ELSE nstars = n_elements(param_gi)

	fu   = bspline_valu(param_gi, uset) > 0.0
	fg   = bspline_valu(param_gi, gset) > 0.0
	fr   = bspline_valu(param_gi, rset) > 0.0
	fi   = bspline_valu(param_gi, iset) > 0.0
	fz   = bspline_valu(param_gi, zset) > 0.0

	sig_fu = bspline_valu(param_gi, udset)
	sig_fg = bspline_valu(param_gi, gdset)
	sig_fr = bspline_valu(param_gi, rdset)
	sig_fi = bspline_valu(param_gi, idset)
	sig_fz = bspline_valu(param_gi, zdset)

	; Create output structure
	star_proto = CREATE_STRUCT('PSFFLUX', fltarr(5), 'PSFFLUX_IVAR', fltarr(5))
	stars = replicate(star_proto, nstars)

	stars.PSFFLUX[0] = fu
	stars.PSFFLUX[1] = fg
	stars.PSFFLUX[2] = fr
	stars.PSFFLUX[3] = fi
	stars.PSFFLUX[4] = fz

	ivar_u = fltarr(nstars) 
	ivar_g = fltarr(nstars) 
	ivar_r = fltarr(nstars) 
	ivar_i = fltarr(nstars) 
	ivar_z = fltarr(nstars) 

	good_u = WHERE(sig_fu GT 0.0, nu)
	good_g = WHERE(sig_fg GT 0.0, ng)
	good_r = WHERE(sig_fr GT 0.0, nr)
	good_i = WHERE(sig_fi GT 0.0, ni)
	good_z = WHERE(sig_fz GT 0.0, nz)

	IF nu GT 0 THEN ivar_u[good_u] = 1.0/sig_fu[good_u]^2
	IF ng GT 0 THEN ivar_g[good_g] = 1.0/sig_fg[good_g]^2
	IF nr GT 0 THEN ivar_r[good_r] = 1.0/sig_fr[good_r]^2
	IF ni GT 0 THEN ivar_i[good_i] = 1.0/sig_fi[good_i]^2
	IF nz GT 0 THEN ivar_z[good_z] = 1.0/sig_fz[good_z]^2

	stars.PSFFLUX_IVAR[0] = ivar_u
	stars.PSFFLUX_IVAR[1] = ivar_g
	stars.PSFFLUX_IVAR[2] = ivar_r
	stars.PSFFLUX_IVAR[3] = ivar_i
	stars.PSFFLUX_IVAR[4] = ivar_z

	; Compute colors also
	u1 = bu->flux2mags(fu, b_u)
	g1 = bu->flux2mags(fg, b_g)
	r1 = bu->flux2mags(fr, b_r)
	i1 = bu->flux2mags(fi, b_i)
	z1 = bu->flux2mags(fz, b_z)

	sigu = bu->ivar2magerr(ivar_u, fu, b_u)
	sigg = bu->ivar2magerr(ivar_g, fg, b_g)
	sigr = bu->ivar2magerr(ivar_r, fr, b_r)
	sigi = bu->ivar2magerr(ivar_i, fi, b_i)
	sigz = bu->ivar2magerr(ivar_z, fz, b_z)

	ug = u1-g1
	gr = g1-r1
	ri = r1-i1
	iz = i1-z1
	gi = g1-i1

	sig_ug = sqrt(sigu^2 + sigg^2)
	sig_gr = sqrt(sigg^2 + sigr^2)
	sig_ri = sqrt(sigr^2 + sigi^2)
	sig_iz = sqrt(sigi^2 + sigz^2)
	sig_gi = sqrt(sigg^2 + sigi^2)



	return, stars
end

function bosstarget_qsochi2::star_stat, qso, stars, $
	star_match = star_match, a = a $
	, i_match = i_match, silent = silent

	tm0 = systime(1)

	nstars = n_elements(stars)
	n_qso = n_elements(qso)
	x2 = fltarr(n_qso)
	a = fltarr(n_qso)
	star_proto = self->zero_struct(stars[0])
	star_match = replicate(star_proto, n_qso)
	i_match = lon64arr(n_qso)

	; Generate sequence of stellar locus fluxes
	for j = 0l, n_qso-1l do begin
		;   counter
		if not keyword_set(silent) then begin
			splog, format = '("STAR ",i7," of ",i7,a1,$)', $
				j, n_qso, string(13b)
		endif
		X2_temp = self->qso_stat(replicate(qso[j], nstars), stars, $
								 A = A_temp, /NO_SWAP, BAD_VAL = -1.0)
		X2[j] = min(X2_temp, i_star)

		star_match[j] = stars[i_star]
		A[j] = A_temp[i_star]
		i_match[j] = i_star

	endfor

	splog,'Time: ',systime(1)-tm0

	return, x2
end

function bosstarget_qsochi2::qso_stat, qso_match, data_match, $
		A = A, NO_SWAP = NO_SWAP $
		, bad_flag = bad_flag, BAD_VAL = BAD_VAL $
		, DEBUG = DEBUG, NOCONV = NOCONV

	tm0 = systime(1)
	times = [tm0]
	names = ['beginning']

	; to ensure that this statistic is always the same independent of
	; which quasar is considered to be the model and which is considered
	; to be data, the model will always be chosen to be the brighter of
	; the two objects in the i-band. For the case of qso-qso pairs where
	; one is a spcectroscopic target, this should almost always gurantee
	; that the spectro qso is the 'model'

	if not keyword_set(bad_val) then bad_val = 1.0e8

	n_match = n_elements(qso_match)
	qso_proto = CREATE_STRUCT('PSFFLUX', fltarr(5), 'PSFFLUX_IVAR', fltarr(5))
	qso_model = replicate(qso_proto, n_match)
	qso_data = replicate(qso_proto, n_match)

	IF KEYWORD_SET(NO_SWAP) THEN BEGIN
		qso_proto = CREATE_STRUCT(      $
			'PSFFLUX', fltarr(5),       $
			'PSFFLUX_IVAR', fltarr(5))
		qso_model = replicate(qso_proto, n_match)
		qso_data = replicate(qso_proto, n_match)

		qso_data.PSFFLUX = qso_match.PSFFLUX
		qso_data.PSFFLUX_IVAR = qso_match.PSFFLUX_IVAR
    
		qso_model.PSFFLUX = data_match.PSFFLUX
		qso_model.PSFFLUX_IVAR = data_match.PSFFLUX_IVAR

		times = [times, systime(1)]
		names = [names, 'keyword set noswap']
    
	ENDIF ELSE BEGIN

		qso_bright = WHERE(qso_match.PSFFLUX[3] GE data_match.PSFFLUX[3] $
						   , n_qso, COMPLEMENT = data_bright $
                           , NCOMPLEMENT = n_data)
    
		IF n_qso NE 0 THEN BEGIN
			qso_model[qso_bright].PSFFLUX = qso_match[qso_bright].PSFFLUX
			qso_data[qso_bright].PSFFLUX = data_match[qso_bright].PSFFLUX
        
			qso_model[qso_bright].PSFFLUX_IVAR = $
				qso_match[qso_bright].PSFFLUX_IVAR
			qso_data[qso_bright].PSFFLUX_IVAR = $
				data_match[qso_bright].PSFFLUX_IVAR
		ENDIF

		IF n_data NE 0 THEN BEGIN
			qso_model[data_bright].PSFFLUX = data_match[data_bright].PSFFLUX
			qso_data[data_bright].PSFFLUX = qso_match[data_bright].PSFFLUX
        
			qso_model[data_bright].PSFFLUX_IVAR = $
				data_match[data_bright].PSFFLUX_IVAR
			qso_data[data_bright].PSFFLUX_IVAR  =  $
				qso_match[data_bright].PSFFLUX_IVAR
		ENDIF
	ENDELSE
    
	A_first = fltarr(n_match)
	bad_flag = intarr(n_match)
	bad_A = intarr(n_match)
    
	; assign fluxes and flux errors
	f_model_u = qso_model.PSFFLUX[0]
	f_model_g = qso_model.PSFFLUX[1]
	f_model_r = qso_model.PSFFLUX[2]
	f_model_i = qso_model.PSFFLUX[3]
	f_model_z = qso_model.PSFFLUX[4]

	f_data_u = qso_data.PSFFLUX[0]
	f_data_g = qso_data.PSFFLUX[1]
	f_data_r = qso_data.PSFFLUX[2]
	f_data_i = qso_data.PSFFLUX[3]
	f_data_z = qso_data.PSFFLUX[4]

	ivar_model_u = qso_model.PSFFLUX_IVAR[0]
	ivar_model_g = qso_model.PSFFLUX_IVAR[1]
	ivar_model_r = qso_model.PSFFLUX_IVAR[2]
	ivar_model_i = qso_model.PSFFLUX_IVAR[3]
	ivar_model_z = qso_model.PSFFLUX_IVAR[4]

	ivar_data_u = qso_data.PSFFLUX_IVAR[0]
	ivar_data_g = qso_data.PSFFLUX_IVAR[1]
	ivar_data_r = qso_data.PSFFLUX_IVAR[2]
	ivar_data_i = qso_data.PSFFLUX_IVAR[3]
	ivar_data_z = qso_data.PSFFLUX_IVAR[4]

	; now wherever the ivar_model eq 0 we will flag it as being bad, but
	; then set it 1.0 to avoid overflow errors
	bad_flag =  bad_flag $
		OR ivar_model_u EQ 0.0 $
		OR ivar_model_g EQ 0.0 $
		OR ivar_model_r EQ 0.0 $
		OR ivar_model_i EQ 0.0 $
		OR ivar_model_z EQ 0.0 


	times = [times, systime(1)]
	names = [names, 'ivar zero']

	bad_inds = WHERE(bad_flag, n_bad_flag)
	IF n_bad_flag NE 0 THEN BEGIN
		ivar_model_u[bad_inds] = 1.0
		ivar_model_g[bad_inds] = 1.0
		ivar_model_r[bad_inds] = 1.0
		ivar_model_i[bad_inds] = 1.0
		ivar_model_z[bad_inds] = 1.0
	ENDIF


	; calculate the initial guess for  A_first as the ratio of i_band fluxes
	first_good = WHERE(f_model_i NE 0.0, n_good, COMPLEMENT = first_bad $
					   , NCOMPLEMENT = n_bad)
	IF n_good NE 0 THEN begin
		A_first[first_good] = abs(f_data_i[first_good]/f_model_i[first_good])
	endif
	IF n_bad NE 0 THEN begin
		A_first[first_bad] = 1.0
	endif

	; iterate seven times to solve the implicit equation for A
	max_iter = 7
	A_now = A_first
	FOR iter = 0, max_iter-1 DO BEGIN
		bad_A = 0*bad_A             ; reset bad_A
		A = self->get_a(A_now, bad_flag $
			, f_data_u, f_data_g, f_data_r, f_data_i, f_data_z           $
			, f_model_u, f_model_g, f_model_r, f_model_i, f_model_z      $
			, ivar_data_u, ivar_data_g, ivar_data_r, ivar_data_i     $
			, ivar_data_z                                               $
			, ivar_model_u, ivar_model_g, ivar_model_r, ivar_model_i $
			, ivar_model_z)
		A_now = A
		IF KEYWORD_SET(DEBUG) THEN BEGIN
			splog, 'A=' + string(A[0])
			IF iter EQ max_iter-2L THEN A_last = A
		ENDIF
	ENDFOR

	times = [times, systime(1)]
	names = [names, 'a_iter']

	IF KEYWORD_SET(DEBUG) THEN begin
		noconv = WHERE(abs(A_last-A)/abs(A) GT 0.02)
	endif


	; calculate the total errors using the new value of A
	err_u = 1.0 + ivar_data_u*A^2/ivar_model_u
	err_g = 1.0 + ivar_data_g*A^2/ivar_model_g
	err_r = 1.0 + ivar_data_r*A^2/ivar_model_r
	err_i = 1.0 + ivar_data_i*A^2/ivar_model_i
	err_z = 1.0 + ivar_data_z*A^2/ivar_model_z

	; calculate the X2, don't explicitly set dX2/dA to zero, since that
	; could give you a negative X2
	X2_u = ivar_data_u*(f_data_u - A*f_model_u)^2/err_u
	X2_g = ivar_data_g*(f_data_g - A*f_model_g)^2/err_g
	X2_r = ivar_data_r*(f_data_r - A*f_model_r)^2/err_r
	X2_i = ivar_data_i*(f_data_i - A*f_model_i)^2/err_i
	X2_z = ivar_data_z*(f_data_z - A*f_model_z)^2/err_z

	X2 = X2_u + X2_g + X2_r + X2_i + X2_z

	; set X2 equal to large numbers for bad points
	bad_inds = WHERE(bad_flag, n_tot_bad)
	IF n_tot_bad NE 0 THEN begin
		X2[bad_inds] = BAD_VAL
	endif

	times = [times, systime(1)]
	names = [names, 'xi_calc']

	;for i=1L,n_elements(times)-1 do begin
	;	splog,names[i]+': '+strn(times[i]-times[i-1])
	;endfor

	return,  X2
end


;docstart::bosstarget_qsochi2::get_a
; NAME:
;  bosstarget_qsochi2::get_a
;PURPOSE 
;	to iteratively solve for the A-coefficient used as the parameter
;	for the chi^2 fits done by qso_stat written by J. Hennawi.
;	See Equations 2 and 3 from BINARY QUASARS IN THE SLOAN DIGITAL SKY SURVEY: 
;	EVIDENCE FOR EXCESS CLUSTERING ON SMALL SCALES by Hennawi et al for details
;	
;SYNTAX
;	bq = obj_new('bosstarget_qso')
;	A=bq->get_a( A_guess, bad_flag $
;                , f_data_u, f_data_g, f_data_r, f_data_i, f_data_z $
;                , f_model_u, f_model_g, f_model_r, f_model_i, f_model_z $
;                , ivar2_data_u, ivar2_data_g, ivar2_data_r, ivar2_data_i $
;                , ivar2_data_z $
;                , ivar2_model_u, ivar2_model_g, ivar2_model_r, ivar2_model_i $
;                , ivar2_model_z)
;INPUTS	
;	NOTE: ALL INPUTS MUST BE IN LINEAR FLUX UNITS
;	A_guess: a guess at the a value (an idea is the ratio of the i-band fluxes)
;	bad_flag: set to 1 for all objects that have bad data (e.g. inverse variance = 0)
;	f_data_u: the u-band flux of the data
;	f_data_g: the g-band flux of the data
;       f_data_r: the r-band flux of the data
;       f_data_i: the i-band flux of the data
;       f_data_z: the z-band flux of the data
;	f_model_u: the model u-band flux
;       f_model_g: the model g-band flux
;       f_model_r: the model r-band flux
;       f_model_i: the model i-band flux
;       f_model_z: the model z-band flux
;	ivar2_data_u: the inverse variance of the data u-band flux
;       ivar2_data_g: the inverse variance of the data g-band flux
;       ivar2_data_r: the inverse variance of the data r-band flux
;       ivar2_data_i: the inverse variance of the data i-band flux
;       ivar2_data_z: the inverse variance of the data z-band flux
;       ivar2_model_u: the inverse variance of the model u-band flux
;       ivar2_model_g: the inverse variance of the model g-band flux
;       ivar2_model_r: the inverse variance of the model r-band flux
;       ivar2_model_i: the inverse variance of the model i-band flux
;       ivar2_model_z: the inverse variance of the model z-band flux

;OUTPUTS
;	A: the value of the a parameter (which is a measure of the brightness of the object)
;
;Written by J. Hennawi

;Documentation header by R. da Silva
; 13-Jan-2009:  Moved into class file, formatting.  Erin Sheldon, BNL
;docend::bosstarget_qsochi2::get_a

function bosstarget_qsochi2::get_A, A_guess, bad_flag $
                , f_data_u, f_data_g, f_data_r, f_data_i, f_data_z $
                , f_model_u, f_model_g, f_model_r, f_model_i, f_model_z $
                , ivar2_data_u, ivar2_data_g, ivar2_data_r, ivar2_data_i $
                , ivar2_data_z $
                , ivar2_model_u, ivar2_model_g, ivar2_model_r, ivar2_model_i $
                , ivar2_model_z


	n_tot = n_elements(f_data_u)

	A_den = fltarr(n_tot)
    
	conv_u = f_data_u*f_model_u*ivar2_data_u
	mod2_u =  f_model_u*f_model_u*ivar2_data_u
	err_u = 1.0 + ivar2_data_u*A_guess^2/ivar2_model_u
	A_num_u = conv_u/err_u
	A_den_u = mod2_u/err_u

	conv_g = f_data_g*f_model_g*ivar2_data_g
	mod2_g =  f_model_g*f_model_g*ivar2_data_g
	err_g = 1.0 + ivar2_data_g*A_guess^2/ivar2_model_g
	A_num_g = conv_g/err_g
	A_den_g = mod2_g/err_g

	conv_r = f_data_r*f_model_r*ivar2_data_r
	mod2_r =  f_model_r*f_model_r*ivar2_data_r
	err_r = 1.0 + ivar2_data_r*A_guess^2/ivar2_model_r
	A_num_r = conv_r/err_r
	A_den_r = mod2_r/err_r

	conv_i = f_data_i*f_model_i*ivar2_data_i
	mod2_i =  f_model_i*f_model_i*ivar2_data_i
	err_i = 1.0 + ivar2_data_i*A_guess^2/ivar2_model_i
	A_num_i = conv_i/err_i
	A_den_i = mod2_i/err_i

	conv_z = f_data_z*f_model_z*ivar2_data_z
	mod2_z =  f_model_z*f_model_z*ivar2_data_z
	err_z = 1.0 + ivar2_data_z*A_guess^2/ivar2_model_z
	A_num_z = conv_z/err_z
	A_den_z = mod2_z/err_z

	A_num = A_num_u + A_num_g +  A_num_r + A_num_i + A_num_z
	A_den = A_den_u + A_den_g +  A_den_r + A_den_i + A_den_z
	den_zero = WHERE(A_den EQ 0.0, n_zero)
	IF n_zero NE 0 THEN BEGIN
		A_den[den_zero] = 1.0
		bad_flag[den_zero] = 1

	ENDIF

	A = A_num/A_den


	RETURN, A
END


;docstart::bosstarget_qsochi2::qso_photoz
; NAME:
;   qso_photoz
;
; PURPOSE:
;   Find photometric redshift of quasar
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; REQUIRED KEYWORDS:
;
; OPTIONAL KEYWORDS:
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
; COMMENTS:
;
; EXAMPLES:
;
; BUGS:
;   At the moment the minimum redshift is z=2.3
;
; PROCEDURES CALLED:
;
; INTERNAL SUPPORT ROUTINES:
;
; REVISION HISTORY:
;   12-Sep-2005 Written by JFH UC Berkeley
;   11-Aug-2008 Modified *slightly* by R. da Silva, LBNL
;	13-Jan-2009:  Moved into class file, formatting, Erin Sheldon, BNL
;docend::bosstarget_qsochi2::qso_photoz

function bosstarget_qsochi2::qso_photoz, qso, z_model = z_model, $
	X2 = X2, qso_match = qso_match $
	, A = A, SILENT = SILENT $
	, colorz_struct = colorz_struct, colorz_set = colorz_set, $
	z_min_fit=z_min_fit, z_max_fit=z_max_fit

	IF NOT KEYWORD_SET(COLORZ_SET) THEN BEGIN
		colorzfile = '/home/jhennawi/Projects/hiz/data/colorz_locus.fits'
		colorz_struct = mrdfits(colorzfile, 1)
		colorz_set    = mrdfits(colorzfile, 2)
	ENDIF

	tm0 = systime(1)

	;Z_MIN_FIT = colorz_struct.Z_MIN
	;; < 0.7 photo-zs not working well
	if n_elements(z_min_fit) EQ 0 then Z_MIN_FIT = 2.3

	if NOT keyword_set(z_max_fit) then Z_MAX_FIT = colorz_struct.Z_MAX

	IF KEYWORD_SET(Z_MODEL) THEN BEGIN
		bad_ind = WHERE(z_model LT Z_MIN_FIT OR z_model GT Z_MAX_FIT, nbad)
		IF nbad NE 0 THEN message, 'Redshift is out of range'
	ENDIF ELSE BEGIN
		IF KEYWORD_SET(Z_MIN1) AND KEYWORD_SET(Z_MAX1) THEN BEGIN
			Z_MIN = Z_MIN1
			Z_MAX = Z_MAX1 
		ENDIF ELSE BEGIN
			Z_MIN = z_MIN_FIT
			Z_MAX = Z_MAX_FIT
		ENDELSE
		nz = 425L
		z_model = Z_MIN + (Z_MAX-Z_MIN)*dindgen(nz+1L)/double(nz)
	ENDELSE

	qso_model = self->qso_colorz(z_model, colorz_struct, colorz_set)
	nmodel = n_elements(z_model)
	nqso = n_elements(qso)
	X2 = fltarr(nqso)
	A = fltarr(nqso)
	z_photo = fltarr(nqso)
	qso_proto = self->zero_struct(qso_model[0])
	qso_match = replicate(qso_proto, nqso)

	; Generate sequence of quasar color fluxes
	FOR j = 0L, nqso-1L DO BEGIN
		;   counter
		IF NOT KEYWORD_SET(SILENT) THEN $
			splog, format = '("PHOTOZ ",i7," of ",i7,a1,$)' $
			, j, nqso, string(13b)
		X2_temp = self->qso_stat(replicate(qso[j], nmodel), qso_model $
			, A = A_temp, /NO_SWAP, BAD_VAL = -1.0D)

		X2[j] = min(X2_temp, i_qso)
		IF X2[j] LT 0.0 THEN BEGIN
			z_photo[j] = -1.0
			A[j] = -1.0
		ENDIF ELSE BEGIN
			z_photo[j] = z_model[i_qso]
			A[j] = A_temp[i_qso]
			qso_match[j] = qso_model[i_qso]
		ENDELSE
	ENDFOR

	splog,'Time: ',systime(1)-tm0
	RETURN, z_photo
END



function bosstarget_qsochi2::qso_colorz, ztemp, colorz_struct, colorz_set $
                     , ug = ug, gr = gr, ri = ri $
                     , iz = iz, gi = gi, sig_ug = sig_ug, sig_gr = sig_gr $
                     , sig_ri = sig_ri, sig_iz = sig_iz, sig_gi = sig_gi $
                     , sigfu = sigfu, sigfg = sigfg, sigfr = sigfr $
                     , sigfi = sigfi, sigfz = sigfz


	; softening parameters from EDR paper in units of 1.0e-10 
	; (Stoughton et al. 2002)
	b_u = 1.4
	b_g = 0.9
	b_r = 1.2
	b_i = 1.8
	b_z = 7.4

	Z_MIN = colorz_struct.Z_MIN 
	Z_MAX = colorz_struct.Z_MAX
	z = ztemp > Z_MIN
	z = z < Z_MAX

	nqso = n_elements(z)
	A = fltarr(nqso)
	bad_ind = WHERE(z LT colorz_struct.Z_MIN OR z GT colorz_struct.Z_MAX, nbad)
	IF nbad NE 0 THEN splog, 'Redshift is out of range'

	uset   = colorz_set[0]
	gset   = colorz_set[1]
	rset   = colorz_set[2]
	iset   = colorz_set[3]
	zset   = colorz_set[4]
	udset  = colorz_set[5]
	gdset  = colorz_set[6]
	rdset  = colorz_set[7]
	idset  = colorz_set[8]
	zdset  = colorz_set[9]

	fu   = bspline_valu(z, uset) > 0.0
	fg   = bspline_valu(z, gset) > 0.0
	fr   = bspline_valu(z, rset) > 0.0
	fi   = bspline_valu(z, iset) > 0.0
	fz   = bspline_valu(z, zset) > 0.0

	sig_fu = bspline_valu(z, udset)
	sig_fg = bspline_valu(z, gdset)
	sig_fr = bspline_valu(z, rdset)
	sig_fi = bspline_valu(z, idset)
	sig_fz = bspline_valu(z, zdset)


	IF TAG_EXIST(colorz_struct, 'Z_DROP_U') THEN BEGIN
		drop_u = WHERE(z GE 1.05D*colorz_struct.Z_DROP_U OR fu LT 0.0, ndropu)
		IF ndropu NE 0 THEN BEGIN
			fu[drop_u] = 0.0D
			sig_fu[drop_u] = 0.0D
		ENDIF
	ENDIF
	IF TAG_EXIST(colorz_struct, 'Z_DROP_G') THEN BEGIN
		drop_g = WHERE(z GE 1.05D*colorz_struct.Z_DROP_G OR fg LT 0.0, ndropg)
		IF ndropg NE 0 THEN BEGIN
			fg[drop_g] = 0.0D
			sig_fg[drop_g] = 0.0D
		ENDIF
	ENDIF

	qso_proto = CREATE_STRUCT('PSFFLUX', fltarr(5), 'PSFFLUX_IVAR', fltarr(5))
	qsos = replicate(qso_proto, nqso)

	qsos.PSFFLUX[0] = fu
	qsos.PSFFLUX[1] = fg
	qsos.PSFFLUX[2] = fr
	qsos.PSFFLUX[3] = fi
	qsos.PSFFLUX[4] = fz

	ivar_u = fltarr(nqso) + 1.0d3
	ivar_g = fltarr(nqso) + 1.0d3
	ivar_r = fltarr(nqso) + 1.0d3
	ivar_i = fltarr(nqso) + 1.0d3
	ivar_z = fltarr(nqso) + 1.0d3

	good_u = WHERE(sig_fu GT 0.0, nu)
	good_g = WHERE(sig_fg GT 0.0, ng)
	good_r = WHERE(sig_fr GT 0.0, nr)
	good_i = WHERE(sig_fi GT 0.0, ni)
	good_z = WHERE(sig_fz GT 0.0, nz)

	IF nu GT 0 THEN ivar_u[good_u] = 1.0/sig_fu[good_u]^2
	IF ng GT 0 THEN ivar_g[good_g] = 1.0/sig_fg[good_g]^2
	IF nr GT 0 THEN ivar_r[good_r] = 1.0/sig_fr[good_r]^2
	IF ni GT 0 THEN ivar_i[good_i] = 1.0/sig_fi[good_i]^2
	IF nz GT 0 THEN ivar_z[good_z] = 1.0/sig_fz[good_z]^2

	qsos.PSFFLUX_IVAR[0] = ivar_u
	qsos.PSFFLUX_IVAR[1] = ivar_g
	qsos.PSFFLUX_IVAR[2] = ivar_r
	qsos.PSFFLUX_IVAR[3] = ivar_i
	qsos.PSFFLUX_IVAR[4] = ivar_z

	; Compute colors also
	u1 = bu->flux2mags(fu, b_u)
	g1 = bu->flux2mags(fg, b_g)
	r1 = bu->flux2mags(fr, b_r)
	i1 = bu->flux2mags(fi, b_i)
	z1 = bu->flux2mags(fz, b_z)

	sigu = bu->ivar2magerr(ivar_u, fu, b_u)
	sigg = bu->ivar2magerr(ivar_g, fg, b_g)
	sigr = bu->ivar2magerr(ivar_r, fr, b_r)
	sigi = bu->ivar2magerr(ivar_i, fi, b_i)
	sigz = bu->ivar2magerr(ivar_z, fz, b_z)

	ug = u1-g1
	gr = g1-r1
	ri = r1-i1
	iz = i1-z1
	gi = g1-i1

	sig_ug = sqrt(sigu^2 + sigg^2)
	sig_gr = sqrt(sigg^2 + sigr^2)
	sig_ri = sqrt(sigr^2 + sigi^2)
	sig_iz = sqrt(sigi^2 + sigz^2)
	sig_gi = sqrt(sigg^2 + sigi^2)

	RETURN, qsos
END




function bosstarget_qsochi2::struct, n
	st={run:0, $
		rerun:'',$
		camcol:0,$
		field:0,$
		id:0,$
		x2_star:0.0, $
		boss_target1: 0LL}
	if n_elements(n) ne 0 then begin
		st=replicate(st,n)
	endif
	return, st
end


;docstart::bosstarget_qso::zero_struct
;
; NAME:
;    ZERO_STRUCT
;       
; PURPOSE:
;    "Zero" all the elements in a structure. Numbers are set to zero,
;           strings to '', pointers and objects references to NULL
;
; CALLING SEQUENCE:
;    zs = zero_struct(struct)
;
; INPUTS: 
;    struct: Structure to be zeroed. Can be an array of structures.
;
; REVISION HISTORY:
;   Created 26-OCT-2000 Erin Sheldon
;   Better way using struct_assign. 2006-July-21 E.S.
;	13-Jan-2009: copied from sdssidl and made function to match whatever
;		was called in the above procedures. E.S. BNL
;docend::bosstarget_qso::zero_struct

function bosstarget_qsochi2::zero_struct, struct_in

  IF N_params() EQ 0 THEN BEGIN 
     splog,'-Syntax: zst=zero_struct(struct)'
     splog,''
     splog,'Use doc_library,"zero_struct"  for more help.'  
	 message,'halting'
  ENDIF 

  ; make a copy
  struct = struct_in

  IF size(struct,/tname) NE 'STRUCT' THEN BEGIN
      message,'Input value must be a structure'
  ENDIF 
  
  ;; Make a structure with a random variable name and use struct_assign 
  ;; to "copy" between structures.  By default, fields that do not match
  ;; are zeroed

  tagname = 'randomFront'
  numstr =  $
    strtrim(string(ulong64(1000*systime(1))), 2) + 'moreRandom' + $
    strtrim(string(long(1000000*randomu(seed))), 2)

  tagname = tagname + numstr
  cst = create_struct(tagname, 0)

  struct_assign, cst, struct
  return, struct
END




pro bosstarget_qsochi2__define
	struct = {$
		bosstarget_qsochi2, $
		inherits bosstarget_qsopars $
	}
end


