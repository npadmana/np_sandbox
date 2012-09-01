function bosstarget_qsoed::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsoed::process, objs, bitmask=bitmask, pars=pars, galex=galex, _extra=_extra

	nobjs = n_elements(objs)
	if  nobjs eq 0 then begin
		message,'Usage: result=bn->process(objs, bitmask=, pars=, _extra=)'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra
	pars=self->pars()


	if n_elements(bitmask) eq 0 then bitmask=lonarr(nobjs)

	bu=obj_new('bosstarget_util')
	lups = bu->get_lups(objs, /deredden)

	; note if bitmask was sent, the mag cuts were already applied
	; most likely, but we'll repeat the check here just in case.
	wgood=where( $
		(lups[1,*] lt pars.max_gmag or lups[2,*] lt pars.max_rmag) $
		and lups[3,*] gt pars.min_imag $
		and bitmask eq 0, ngood)

	outstruct = self->struct(nobjs)
	if ngood ne 0 then begin
		flux = bu->deredden(objs[wgood].psfflux, objs[wgood].extinction)
		flux_ivar = bu->deredden_error(objs[wgood].psfflux_ivar, objs[wgood].extinction)

		outstruct[wgood] = self->calculate_prob(flux, flux_ivar, galex=galex)
	endif

	return, outstruct

end

function bosstarget_qsoed::process_auxiliary, objs, ukidss=ukidss, galex=galex, zfour=zfour, bitmask=bitmask, pars=pars, _extra=_extra, multi=multi, verbose=verbose

    nobjs = n_elements(objs)
    if  nobjs eq 0 then begin
        message,'Usage: result=bn->process_auxiliary(objs, ukidss=, galex=, /zfour, bitmask=, pars=, _extra=)'
    endif

    self->copy_extra_pars, pars=pars, _extra=_extra
    pars=self->pars()

    if n_elements(bitmask) eq 0 then bitmask=lonarr(nobjs)

    bu=obj_new('bosstarget_util')
    lups = bu->get_lups(objs, /deredden)

    ; note if bitmask was sent, the mag cuts were already applied
    ; most likely, but we'll repeat the check here just in case.
    wgood=where( $
        (lups[1,*] lt pars.max_gmag or lups[2,*] lt pars.max_rmag) $
        and lups[3,*] gt pars.min_imag $
        and bitmask eq 0, ngood)

    outstruct = self->struct(nobjs)

    ;ADM this stores whether we had galex or ukidss matches
    mwstruct = self->multiwave_struct(nobjs)

    if ngood ne 0 then begin
        combined = add_data(objs,galexdata=galex,ukidssdata=ukidss,$
                            raw_uv_matches=raw_uv_matches, raw_nir_matches=raw_nir_matches)

        if raw_uv_matches[0] ne -1 then begin
            mwstruct[raw_uv_matches].galex_matched = 1
        endif
        if raw_nir_matches[0] ne -1 then begin
            mwstruct[raw_nir_matches].ukidss_matched = 1
        endif
        ; ADM to return which objects the ExD code
        ; ADM officially found GALEX or UKIDSS matches for
        ; ADM in add_data, objects that don't have a
        ; ADM match return psfflux_ivar=1/1d5 in every band

        iv = combined.psfflux_ivar


        ; ADM need to determine which indices are occupied by
        ; ADM GALEX and UKIDSS, which varies depending on if 
        ; ADM GALEX and/or UKIDSS are passed

        if n_tags(galex) ne 0 and n_tags(ukidss) ne 0 then begin
            splog, 'GALEX and UKIDSS data available'
            ukidss_matched_good = (iv[7,*] ne 1/1d5 or iv[8,*] ne 1/1d5 or iv[9,*] ne 1/1d5 or iv[10,*] ne 1/1d5)
            galex_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5)
            mwstruct.ukidss_matched_good = ukidss_matched_good[*]
            mwstruct.galex_matched_good = galex_matched_good[*]
        endif else begin
            if n_tags(galex) ne 0 then begin
                splog, 'GALEX data available'
                galex_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5)
                mwstruct.galex_matched_good = galex_matched_good[*]
            endif
            if n_tags(ukidss) ne 0 then begin
                splog, 'UKIDSS data available'
                ukidss_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5 or iv[7,*] ne 1/1d5 or iv[8,*] ne 1/1d5)
                mwstruct.ukidss_matched_good = ukidss_matched_good[*]
            endif
        endelse

        ;use_galex = (where(mwstruct.galex_matched_good ne 0))[0] ne -1
        ;use_ukidss = (where(mwstruct.ukidss_matched_good ne 0))[0] ne -1

        outstruct[wgood] = qsoed_calculate_prob(combined[wgood],$
                                                zfour=zfour,$
                                                galex=galex,$
                                                ukidss=ukidss,$
                                                /nocuts, multi=multi, verbose=verbose)

    endif

	return, struct_combine(outstruct, mwstruct)

end

function bosstarget_qsoed::calculate_prob, flux, flux_ivar, lumfunc=lumfunc, $
                         galex=galex

         ;;Read the differential number counts
         dataDir= '$BOSSTARGET_DIR/data/qso-ed/numcounts/'
         IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07'
         dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
         dndi_qsofile= dndipath(3.5,6.,lumfunc)
         dndi_qsolowzfile= dndipath(0.3,2.2,lumfunc)
         dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'

	read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
	read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
	read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
	read_dndi, dndi_everythingfile, i_everything, dndi_everything

	;;Now calculate all of the factors in turn
        bossqsolike= eval_colorprob(flux,flux_ivar,/qso,/bossz,galex=galex)
        bossqsonumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)
        qsolike= eval_colorprob(flux,flux_ivar,/qso,galex=galex)
        qsonumber= eval_iprob(flux[3,*],i_qso,dndi_qso)
        qsolowzlike= eval_colorprob(flux,flux_ivar,/qso,/lowz,galex=galex)
        qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)
        everythinglike= eval_colorprob(flux,flux_ivar,galex=galex)
        everythingnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)

	;;Calculate the probability that a target is a high-redshift QSO
	pqso= (bossqsolike*bossqsonumber)
	nonzero= where(pqso NE 0., n_nonzero)
	if n_nonzero gt 0 then begin
            pqso[nonzero]= pqso[nonzero]/(qsolike[nonzero]*qsonumber[nonzero]+$
                                          qsolowzlike[nonzero]*qsolowznumber[nonzero]+$
                                          everythinglike[nonzero]*everythingnumber[nonzero]+$
                                          pqso[nonzero])
        endif

	out = self->struct(n_elements(pqso))
	out.pqso= pqso
	out.bossqsolike= bossqsolike
	out.bossqsonumber= bossqsonumber
	out.qsolike= qsolike
	out.qsonumber= qsonumber
	out.qsolowzlike= qsolowzlike
	out.qsolowznumber= qsolowznumber
	out.everythinglike= everythinglike
	out.everythingnumber= everythingnumber

	return, out

end

function bosstarget_qsoed::struct, num
	st = {$
		pqso:				-9999d, $
		bossqsolike:		-9999d, $
		bossqsonumber:		-9999d, $
		qsolike:			-9999d, $
		qsonumber:			-9999d, $
		qsolowzlike:		-9999d, $
		qsolowznumber:		-9999d, $
		everythinglike:		-9999d, $
		everythingnumber:	-9999d  $
	}

	if n_elements(num) ne 0 then begin
		st = replicate(st, num)
	endif

	return, st
end

function bosstarget_qsoed::multiwave_struct, num
  ;Adam D. Myers, UIUC December 9, 2010
  ;structure to record where the ExD code
  ;found GALEX or UKIDSS matches 

        st = {$
             ;ADM these are populated with 1 where
             ;ADM we find galex or ukidss matches
                ukidss_matched:                 0, $
                galex_matched:                  0, $
                ukidss_matched_good:            0, $
                galex_matched_good:             0  $
             }

	if n_elements(num) ne 0 then begin
		st = replicate(st, num)
	endif

	return, st
end


pro bosstarget_qsoed__define
	struct = {$
		bosstarget_qsoed, $
		inherits bosstarget_qsopars $
	}
end


