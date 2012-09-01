function bosstarget_qsonn::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsonn::select, objs, bitmask=bitmask, pars=pars, _extra=_extra


	nobjs = n_elements(objs)
	if  nobjs eq 0 then begin
		message,'Usage: boss_target1=bn->select(objs, bitmask=, pars=, _extra=)'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra


	nn_struct = self->process(objs, bitmask=bitmask)
	return, nn_struct
end


function bosstarget_qsonn::process, objs, bitmask=bitmask

	if n_elements(objs) eq 0 then begin
		on_error,2
		message,'usage: boss_target1 = bq->nn_select(objs,nn_struct=,bitmask=)'
	endif

	pars=self->pars()

	nobj=n_elements(objs)
	
	nmask=n_elements(bitmask)
	if nmask eq 0 then begin
		bitmask = intarr(nobj)
	endif else begin
		if nmask ne nobj then message,'require len(bitmask)=len(objs)'
	endelse


	bu=obj_new('bosstarget_util')
	lups = bu->get_lups(objs, err=lupserr, /deredden)

	umag = reform(lups[0,*])
	gmag = reform(lups[1,*])
	rmag = reform(lups[2,*])
	imag = reform(lups[3,*])
	zmag = reform(lups[4,*])
	umagerr = reform(lupserr[0,*])
	gmagerr = reform(lupserr[1,*])
	rmagerr = reform(lupserr[2,*])
	imagerr = reform(lupserr[3,*])
	zmagerr = reform(lupserr[4,*])


	umg = umag - gmag
	gmi = gmag - imag

	lups=0
	
	nn_struct = self->struct(nobj)

	boss_target1 = lon64arr(nobj)


	splog,'Getting NN sanity logic, will cut down later'
	sanity_logic = $
		umag gt 0 $
		and gmag gt 0 $
		and rmag gt 0 $
		and imag gt 0 $
		and zmag gt 0 $
		and umagerr gt 0 $
		and gmagerr gt 0 $
		and rmagerr gt 0 $
		and imagerr gt 0 $
		and zmagerr gt 0 $
		and (bitmask eq 0)



	w=where(sanity_logic, nw)
	if nw eq 0 then begin
		return, nn_struct
	endif


	splog,'Running: ',nw,'/',nobj,' through NN code', form='(a,i0,a,i0,a)'

	self->nn_run, objs[w], xnn, znn, xnn2
	nn_struct[w].xnn = xnn
	nn_struct[w].xnn2 = xnn2
	nn_struct[w].znn_phot = znn

	splog,'    Using NN thresholds: '
	splog,'      umg >  ',pars.nn_umg_min,form='(a,g0)'
	splog,'      gmi <  ',pars.nn_gmi_max,form='(a,g0)'
	splog,'      urange ',pars.nn_urange,form='(a,"[",g0,", ",g0,"]")'
	splog,'      grange ',pars.nn_grange,form='(a,"[",g0,", ",g0,"]")'
	splog,'      rrange ',pars.nn_rrange,form='(a,"[",g0,", ",g0,"]")'
	splog,'      irange ',pars.nn_irange,form='(a,"[",g0,", ",g0,"]")'
	splog,'      zrange ',pars.nn_zrange,form='(a,"[",g0,", ",g0,"]")'
	splog,'      xnn >  ',pars.nn_xnn_thresh,form='(a,g0)'
	splog,'      znn >  ',pars.nn_znn_thresh,form='(a,g0)'




	; tighter logic for actual qso_nn selection
	tight_logic = $
		umag gt pars.nn_urange[0] and umag lt pars.nn_urange[1] $
		and gmag gt pars.nn_grange[0] and gmag lt pars.nn_grange[1] $
		and rmag gt pars.nn_rrange[0] and rmag lt pars.nn_rrange[1] $
		and imag gt pars.nn_irange[0] and imag lt pars.nn_irange[1] $
		and zmag gt pars.nn_zrange[0] and zmag lt pars.nn_zrange[1] $
		and umagerr gt 0 $
		and gmagerr gt 0 $
		and rmagerr gt 0 $
		and imagerr gt 0 $
		and zmagerr gt 0 $
		and (umg gt pars.nn_umg_min) $
		and (gmi lt pars.nn_gmi_max) $
		and (bitmask eq 0)



	keep = where($
		tight_logic $
		and (nn_struct.xnn gt pars.nn_xnn_thresh) $
		and (nn_struct.znn_phot gt pars.nn_znn_thresh), nkeep)

	if nkeep gt 0 then begin
		nn_struct[keep].boss_target1 = sdss_flagval('boss_target1','qso_nn')
	endif

	splog,'    Found: ',nkeep,' passed NN threshold',form='(a,i0,a)'
	return, nn_struct

end

pro bosstarget_qsonn::nn_run, objs, xnn, znn, xnn2, $
		lups=psfmag, lups_err=psfmag_err


	dir=getenv('BOSSTARGET_DIR')
	name='qsonn_idl'
	path=filepath(root=dir, subdir=['src','qso-nn'], name+'.so')

	nobj = n_elements(objs)

	bu=obj_new('bosstarget_util')
	psfmag = bu->get_lups(objs, err=psfmag_err, /deredden)
	psfmag=float(psfmag)
	psfmag_err=float(psfmag_err)

	xnn=fltarr(nobj)
	znn=fltarr(nobj)
	xnn2=fltarr(nobj)
	retval = call_external($
		path, name, $
		n_elements(objs), psfmag, psfmag_err, xnn, znn, xnn2)

end


function bosstarget_qsonn::value_select, $
        gmag, like_ratio, kde_prob, nn_xnn, nn_znn, qsoed_prob, qsoed_prob_multi

;ADM November 29, 2010, updated to include call to ExD output
;ADM December 9, 2010, updated to base boss_target1 off value
;                      where we don't have ukidss or galex matches from ExD

; note using same threshold for all as of now: ok, just need to make it loose for
; pixel tuning later

	pars = self->pars()

	str = self->value_struct(n_elements(gmag))

	self->value, $
        gmag, like_ratio, kde_prob, nn_xnn, nn_znn, qsoed_prob, qsoed_prob_multi, $
        value, weight_value, value_with_ed, value_with_ed_ukidss
	str.value = value
	str.weight_value = weight_value
    str.value_with_ed = value_with_ed
    str.value_with_ed_ukidss = value_with_ed_ukidss

	splog,'using NN value cut > ',pars.nn_value_thresh

    ; using same thresh for all
    w=where( (str.value gt pars.nn_value_thresh) $
            or (str.value_with_ed gt pars.nn_value_thresh) $
            or (str.value_with_ed_ukidss gt pars.nn_value_thresh), nw)

	if nw gt 0 then begin
		splog,'Found ',nw,' NN value',form='(a,i0,a)'
		str[w].boss_target1 = sdss_flagval('boss_target1','qso_bonus_main')
	endif else begin
		splog,'Found no objects passing any NN value'
	endelse

	return, str
end

pro bosstarget_qsonn::value, $
        gmag, like_ratio, kde_prob, nn_xnn, nn_znn, qsoed_prob, qsoed_prob_multi, $
		value, weight_value, value_with_ed, value_with_ed_ukidss
;ADM November 29, 2010, updated to include call to ExD output

    ; gmag is log mags, extinction corrected

    dir=getenv('BOSSTARGET_DIR')
    name='qsocomb_idl'
    path=filepath(root=dir, subdir=['src','qso-nn'], name+'.so')

    nobj = n_elements(gmag)

    value = fltarr(nobj)
    weight_value = fltarr(nobj)
    value_with_ed = fltarr(nobj)
    value_with_ed_ukidss = fltarr(nobj)

    retval = call_external($
        path, $
        name, $
        long(nobj), $
        float(like_ratio), $
        float(kde_prob), $
        float(nn_xnn), $
        float(nn_znn), $
        float(gmag), $
        float(qsoed_prob), $
        float(qsoed_prob_multi), $
        value, $
        weight_value, $
        value_with_ed, $
        value_with_ed_ukidss $
        )


end




function bosstarget_qsonn::struct,n
	nn_struct = {$
		nn_id:-9999L, $
		xnn:-9999.,$
		xnn2:-9999.,$
		znn_phot:-9999., $
		boss_target1: 0LL $
	}
	if n_elements(n) ne 0 then begin
		nn_struct = replicate(nn_struct, n)
	endif

	return, nn_struct
end

function bosstarget_qsonn::value_struct,n
;ADM November 29, 2010, updated to include call to ExD output
;ADM uses extra value "value_with_ed"
	str = {$
		value: 0.0, $
		weight_value: 0.0, $
        value_with_ed: 0.0, $
        value_with_ed_ukidss: 0.0, $
		boss_target1: 0LL $
	}
	if n_elements(n) ne 0 then begin
		str = replicate(str, n)
	endif

	return, str
end








pro bosstarget_qsonn__define
	struct = {$
		bosstarget_qsonn, $
		inherits bosstarget_qsopars $
	}
end


