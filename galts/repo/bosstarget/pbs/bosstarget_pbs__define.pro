function bosstarget_pbs::init
	return, 1
end

pro bosstarget_pbs::qso_main016

    ; The only  change from 015 is new ukidss data, no new tag of code

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_18'

    queue = 'batch'
    target_run = 'main016'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end



pro bosstarget_pbs::qso_main015

    ; running with the bug-fixed ukidss data, sgc+ngc
    ; this is the kludge matching ra/dec not a true fix from
    ; richard

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_18'

    queue = 'batch'
    target_run = 'main015'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end




pro bosstarget_pbs::qso_2011_10_27

    ; running with the bug-fixed ukidss data, sgc+ngc
    ; this is the kludge matching ra/dec not a true fix from
    ; richard

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    ;idlutils_v='-r /home/esheldon/exports/idlutils-work'
    idlutils_v='v5_4_24'
    ;bosstarget_v='v2_0_17'
    bosstarget_v='-r ~esheldon/exports/bosstarget-work'

    queue = 'batch'
    target_run = '2011-10-27'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end



pro bosstarget_pbs::qso_main014

    ; running with just the bug-fixed ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    ;idlutils_v='-r /home/esheldon/exports/idlutils-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_17'

    queue = 'batch'
    target_run = 'main014'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end

pro bosstarget_pbs::qso_2011_06_28

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    ;idlutils_v='-r /home/esheldon/exports/idlutils-work'
    idlutils_v='v5_4_24'
    bosstarget_v='-r ~esheldon/exports/bosstarget-work'

    queue = 'batch'
    target_run = '2011-06-28'

    ;self->create_pbs_bycamcol, 'qso', target_run, $
    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end




pro bosstarget_pbs::qso_2011_06_26

    ; running with just the bug-fixed ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    ;idlutils_v='-r /home/esheldon/exports/idlutils-work'
    idlutils_v='v5_4_24'
    bosstarget_v='-r ~esheldon/exports/bosstarget-work'

    queue = 'batch'
    target_run = '2011-06-26'

    ;self->create_pbs_bycamcol, 'qso', target_run, $
    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end



pro bosstarget_pbs::qso_main013

    ; running with just the bug-fixed ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    idlutils_v='-r /home/esheldon/exports/idlutils-work'
    bosstarget_v='v2_0_16'

    queue = 'batch'
    target_run = 'main013'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end



pro bosstarget_pbs::qso_2011_05_15

    ; running with just the bug-fixed ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    idlutils_v='-r /home/esheldon/exports/idlutils-work'
    bosstarget_v='-r ~esheldon/exports/bosstarget-work'

    queue = 'batch'
    target_run = '2011-05-15'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v
end



pro bosstarget_pbs::qso_2011_05_03, dogather=dogather

    ; adding more ukidss data and galex

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~esheldon/exports/bosstilelist-work'
    idlutils_v='-r /home/esheldon/exports/idlutils-work'
    bosstarget_v='-r ~esheldon/exports/bosstarget-work'

    queue = 'batch'
    target_run = '2011-05-03'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        bosstarget_v=bosstarget_v, $
        dogather=dogather
end




pro bosstarget_pbs::qso_main012, dogather=dogather, noverify=noverify

    ;adding more ukidss data
    ; software versions are the same as 011, just new ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'

    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_15a'
    ;bosstarget_v='-r ~/exports/bosstarget-work'

    queue = 'batch'
    target_run = 'main012'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        bosstarget_v=bosstarget_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        noverify=noverify, $ ; we had a bug in v2_0_15 gathering, just want to gather
        dogather=dogather

end



pro bosstarget_pbs::qso_main011_alt, type
    if not in(['suppz','nosuppz'], type) then begin
        message,"type should be 'suppz' or 'nosuppz'"
    endif

    ; re-gather with or without suppz

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'

    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_15a'
    ;bosstarget_v='-r ~/exports/bosstarget-work'

    queue = 'batch'

    target_run = 'main011'

    lohiz= string(sdss_flagval('boss_target1','qso_known_lohiz'), f='(I0)')

    orflagnames=['qso_core_main','qso_bonus_main','qso_known_midz','qso_first_boss']
	orflags = sdss_flagval('boss_target1', orflagnames)

	orflags_str = string(orflags,f='(i0)')
    suppz_flags = sdss_flagval('boss_target1', 'qso_known_suppz')
    suppz_str = string(suppz_flags,f='(i0)')

    output_extra=type
    if type eq 'suppz' then begin
	    ws='((str.boss_target1 and '+suppz_str+') ne 0) and ((str.boss_target1 and '+lohiz+') eq 0) and ((str.boss_target1 and '+orflags_str+') ne 0)'
    endif else begin
	    ws='((str.boss_target1 and '+suppz_str+') eq 0) and ((str.boss_target1 and '+lohiz+') eq 0) and ((str.boss_target1 and '+orflags_str+') ne 0)'
    endelse


    self->create_pbs, 'qso', target_run, $
        where_string=ws, $
        output_extra=output_extra, $
        pars=pars, $
        prepend_setups=extra_setups, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        bosstarget_v=bosstarget_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        /noverify, $ ; we had a bug in v2_0_15 gathering, just want to gather
        /dogather

end



pro bosstarget_pbs::qso_main011, dogather=dogather

    ;adding more ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'

    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'
    idlutils_v='v5_4_24'
    bosstarget_v='v2_0_15a'
    ;bosstarget_v='-r ~/exports/bosstarget-work'

    queue = 'batch'
    target_run = 'main011'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        bosstarget_v=bosstarget_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        /noverify, $ ; we had a bug in v2_0_15 gathering, just want to gather
        dogather=dogather

end



pro bosstarget_pbs::qso_2011_02_18, dogather=dogather

    ;adding more ukidss data

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'
    idlutils_v='-r /home/esheldon/exports/idlutils-work'

    queue = 'batch'
    target_run = '2011-02-18'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        idlutils_v=idlutils_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        dogather=dogather
end



pro bosstarget_pbs::qso_main010

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'

    bosstarget_v='v2_0_14'

    queue = 'batch'
    target_run = 'main010'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        bosstarget_v=bosstarget_v, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep
end



pro bosstarget_pbs::qso_2011_01_18

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'
    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'

    queue = 'batch'
    target_run = '2011-01-18'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep
end




; this version uses the same cache, but loads the new sweeps with
; time epoch information.  Also loose cuts and only in certain
; chunks

pro bosstarget_pbs::qso_2010_12_21

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/2010-12-17/dr8_final'

    pars = {nn_value_thresh: 0.0, add_inchunk: 1}
    ; remember 2^(chunk-1) is the value
	where_string = '(str.resolve_status and 256) ne 0 and str.qsoed_prob_bonus ge 0' + $
                   ' and ( ((str.inchunk_bounds and 2^(2-1)) ne 0)' + $
                   ' or    ((str.inchunk_bounds and 2^(3-1)) ne 0)' + $
                   ' or    ((str.inchunk_bounds and 2^(5-1)) ne 0)' + $
                   ' or    ((str.inchunk_bounds and 2^(6-1)) ne 0) )'
    extra_setups='setup bosstilelist  -r ~/exports/bosstilelist-work'

    queue = 'batch'
    target_run = '2010-12-21'

    self->create_pbs, 'qso', target_run, $
        pars=pars, $
        prepend_setups=extra_setups, $
        where_string=where_string, $
        queue=queue, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep
end



; remake the cache for the combined fluxes
; re-run with /alltypes to use the cache and create full outputs: I split
; it up because some of the other code wasn't ready
pro bosstarget_pbs::qso_2010_12_13, alltypes=alltypes, dogather=dogather

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'

    ; new multi-epoch dr8_final
    photo_sweep='/clusterfs/riemann/raid008/bosswork/groups/boss/target/sweeps/dr8_final'

    if not keyword_set(alltypes) then begin
        pars={types:'like;kde;chi2'}
    endif

    queue = 'batch'
    target_run = '2010-12-13'

    if not keyword_set(dogather) then begin
        self->create_pbs_bycamcol, 'qso', target_run, $
            pars=pars, $
            queue=queue, $
            photo_resolve=photo_resolve, $
            photo_calib=photo_calib, $
            photo_sweep=photo_sweep
    endif else begin
		self->create_pbs, 'qso', target_run, /dogather, $
            queue=queue, $
            photo_resolve=photo_resolve, $
            photo_calib=photo_calib, $
            photo_sweep=photo_sweep
    endelse
end



; remake the cache
pro bosstarget_pbs::qso_2010_12_01

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'
    ;boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'

    pars={types:'like;kde;chi2'}

    queue = 'fast'
    target_run = '2010-12-01'
    walltime='48:00:00'
    self->create_pbs_bycamcol, 'qso', target_run, $
        pars=pars, $
        queue=queue, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        walltime=walltime

end

pro bosstarget_pbs::lrg_main009

    ; the 21.5 ifiber2 cut as gal_ifiber2_faint flag

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'
    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'

    bosstarget_v='v2_0_13'

    queue = 'fast'
    ;queue = 'batch'


	target_run = 'main009'
	nper=10
	self->create_pbs_lrg, target_run, nper=nper, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        boss_target=boss_target, $
        idlutils_v=idlutils_v, $
        bosstarget_v=bosstarget_v, $
        queue=queue
end




pro bosstarget_pbs::lrg_2010_11_17

    ; test the 21.5 ifiber2 cut as gal_ifiber2_faint flag

    ; set explicitly to deal with disk issues
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'
    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'
    idlutils_v='-r /home/esheldon/svn/idlutils'

    ;queue = 'fast'
    queue = 'batch'


	target_run = '2010-11-17'
	nper=10
	self->create_pbs_lrg, target_run, nper=nper, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        boss_target=boss_target, $
        idlutils_v=idlutils_v, $
        queue=queue
end





; loose cuts for adam
pro bosstarget_pbs::qso2010_09_15chunks, nper=nper

	pars = {$
		add_inchunk: 1 $
	}

    ws = $
      '((str.like_ratio_core gt 0) or (str.qsoed_prob_core gt 0)) '+$
        'and (str.inchunk_bounds gt 0)'

    if n_elements(nper) eq 0 then begin
        nper=10
    endif
	target_run = '2010-09-15chunks'
	self->create_pbs, 'qso', target_run, $
        photo_sweep=photo_sweep, $
        photo_resolve=photo_resolve, $
		pars=pars, $
        nper=nper, $
		where_string=ws

end

pro bosstarget_pbs::qso_main008_edfinal
    ; this just gathers the results of bosstarget_util::main008_edcore_kludge
    ; tuned on sgc+ngc
    walltime='48:00:00'
    target_run = 'main008'
    extra_name='edfinal'

    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'
    bosstarget_v='v2_0_12'

    nper=10
    ;photo_resolve='/home/esheldon/resolve/2010-05-23'
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'

    self->create_pbs, 'qso', target_run, walltime=walltime, $
        nper=nper, $
        bosstarget_v=bosstarget_v, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        extra_setups='export BOSS_TARGET='+boss_target, $
        extra_name=extra_name, $
        /dogather

end





pro bosstarget_pbs::qso_main008_edboss
    ; this just gathers the results of bosstarget_util::main008_edcore_kludge
    ; tuned on sgc+ngc
    walltime='48:00:00'
	target_run = 'main008'
    extra_name='edboss'

    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'
    ;photo_resolve='/home/esheldon/resolve/2010-05-23'
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'

    self->create_pbs, 'qso', target_run, walltime=walltime, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        extra_setups='export BOSS_TARGET='+boss_target, $
        extra_name=extra_name, $
        /dogather

end



pro bosstarget_pbs::qso_main008_edblind
    ; this just gathers the results of bosstarget_util::main008_edcore_kludge
    walltime='48:00:00'
	target_run = 'main008'
    extra_name='edblind'

    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'
    ;photo_resolve='/home/esheldon/resolve/2010-05-23'
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'

    self->create_pbs, 'qso', target_run, walltime=walltime, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        extra_setups='export BOSS_TARGET='+boss_target, $
        extra_name=extra_name, $
        /dogather

end




pro bosstarget_pbs::qso_main008_edcore
    ; this just gathers the results of bosstarget_util::main008_edcore_kludge
    walltime='48:00:00'
	target_run = 'main008'
    extra_name='edcore'

    boss_target='/clusterfs/riemann/raid008/bosswork/groups/boss/target'
    ;photo_resolve='/home/esheldon/resolve/2010-05-23'
    photo_resolve='/clusterfs/riemann/raid006/dr8/groups/boss/resolve/2010-05-23'
    photo_calib='/clusterfs/riemann/raid006/dr8/groups/boss/calib/dr8_final'
    photo_sweep='/clusterfs/riemann/raid006/dr8/groups/boss/sweeps/dr8_final'

    self->create_pbs, 'qso', target_run, walltime=walltime, $
        photo_resolve=photo_resolve, $
        photo_calib=photo_calib, $
        photo_sweep=photo_sweep, $
        extra_setups='export BOSS_TARGET='+boss_target, $
        extra_name=extra_name, $
        /dogather

end







pro bosstarget_pbs::std_main008, dogather=dogather

    bosstarget_v = 'v2_0_9'
    walltime='48:00:00'
	target_run = 'main008'
    pars={nocalib:1}

    self->create_pbs, 'std', target_run, walltime=walltime, $
        bosstarget_v=bosstarget_v, pars=pars

end



pro bosstarget_pbs::qso_main008, dogather=dogather

    bosstarget_v = 'v2_0_9'
    walltime='48:00:00'
	target_run = 'main008'


    self->create_pbs, 'qso', target_run, walltime=walltime, $
        bosstarget_v=bosstarget_v

end



pro bosstarget_pbs::lrg_main008

    bosstarget_v = 'v2_0_8'

	target_run = 'main008'
	nper=10
	self->create_pbs_lrg, target_run, nper=nper, $
        bosstarget_v=bosstarget_v

end



;
; The following wrapper methods define the various target runs
; They make calls to the create_pbs and create_pbs_bycamcol methods
; at the bottom of this class file

pro bosstarget_pbs::qso2010_08_20, not_bycamcol=not_bycamcol, dogather=dogather

    walltime='48:00:00'
	target_run = '2010-08-20'


	if not keyword_set(dogather) then begin
        if keyword_set(not_bycamcol) then begin
            self->create_pbs, 'qso', target_run, $
                walltime=walltime
        endif else begin
            self->create_pbs_bycamcol, 'qso', target_run, $
                walltime=walltime
        endelse
	endif else begin
		self->create_pbs, 'qso', target_run, /dogather
	endelse


end



pro bosstarget_pbs::lrg2010_08_19

	target_run = '2010-08-19'
	nper=10
	self->create_pbs_lrg, target_run, nper=nper

end



pro bosstarget_pbs::qso2010_08_19, not_bycamcol=not_bycamcol, dogather=dogather

    walltime='48:00:00'
	target_run = '2010-08-19'


	if not keyword_set(dogather) then begin
        if keyword_set(not_bycamcol) then begin
            self->create_pbs, 'qso', target_run, $
                walltime=walltime
        endif else begin
            self->create_pbs_bycamcol, 'qso', target_run, $
                walltime=walltime
        endelse
	endif else begin
		self->create_pbs, 'qso', target_run, /dogather
	endelse


end



pro bosstarget_pbs::lrg2010_08_03

	target_run = '2010-08-03'
	nper=10
	self->create_pbs_lrg, target_run, nper=nper

end



pro bosstarget_pbs::qso2010_07_30, dogather=dogather

    walltime='48:00:00'
	target_run = '2010-07-30'
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
            pars=pars, $
            walltime=walltime
	endif else begin
		self->create_pbs, 'qso', target_run, /dogather
	endelse


end


; loose cuts for adam
pro bosstarget_pbs::qso2010_06_11chunks, dogather=dogather

	pars = {$
		add_inchunk: 1 $
	}

	; not lohiz
	; yes one of the main selections
	; or qsoed > 0
	; and primary

	; add add that they are in chunks 1-5.  We do this
	; instead of bounds in pars above since  bounds
	; would create a new cache.

    ;photo_sweep='/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2010-01-11'
    ;photo_resolve='/clusterfs/riemann/raid006/bosswork/groups/boss/resolve/2010-01-11'

	ws = '((str.boss_target1 and 8192) eq 0)'+$
		' and ( ' +$
			  '(str.like_ratio_bonus gt 0)'+$
			  ' or (str.like_ratio_core gt 0)'+$
			  ' or (str.qsoed_prob gt 0)'+$
			  ' or (str.nn_xnn gt 0)'+$
			  ' or (str.nn_xnn2 gt 0)'+$
			  ' or (str.kde_prob gt 0)'+$
		     ')'+$
		' and ((str.resolve_status and 256) ne 0)' + $
		' and (str.inchunk_bounds gt 0)'


	target_run = '2010-06-11chunks'
	self->create_pbs, 'qso', target_run, $
        photo_sweep=photo_sweep, $
        photo_resolve=photo_resolve, $
		pars=pars, $
		where_string=ws

end



; everything, old like etc. but with the qsoed stuff
pro bosstarget_pbs::qso2010_05_04chunks, dogather=dogather

	pars = {$
		add_inchunk: 1 $
	}

	; not lohiz
	; yes one of the main selections
	; or qsoed > 0
	; and primary

	; add add that they are in chunks 1-5.  We do this
	; instead of bounds in pars above since  bounds
	; would create a new cache.

	ws = '((str.boss_target1 and 8192) eq 0)'+$
		' and ( ' +$
			  '(str.like_ratio_bonus gt 0)'+$
			  ' or (str.like_ratio_core gt 0)'+$
			  ' or (str.qsoed_prob gt 0)'+$
			  ' or (str.nn_xnn gt 0)'+$
			  ' or (str.nn_xnn2 gt 0)'+$
			  ' or (str.kde_prob gt 0)'+$
		     ')'+$
		' and ((str.resolve_status and 256) ne 0)' + $
		' and (str.inchunk_bounds gt 0)'


	target_run = '2010-05-04chunks'
	self->create_pbs, 'qso', target_run, $
		pars=pars, $
		where_string=ws

end



; everything, old like etc. but with the qsoed stuff
pro bosstarget_pbs::qso2010_05_03, dogather=dogather

	pars = {$
		add_inchunk: 1 $
	}

	; not lohiz
	; yes one of the main selections
	; or qsoed
	; and primary
	ws = '((str.boss_target1 and 8192) eq 0) and (((str.boss_target1 and 3298535149568) ne 0) or (str.qsoed_prob gt 0.05)) and ((str.resolve_status and 256) ne 0)'


	target_run = '2010-05-03'
	self->create_pbs, 'qso', target_run, $
		pars=pars, $
		where_string=ws

end




; small test region in the north 
pro bosstarget_pbs::qso2010_05_01small, dogather=dogather, bycamcol=bycamcol

	walltime='48:00:00'
	pars = {$
		likelihood_version: 'v2', $
		likelihood_thresh_core: 0.0, $
		bounds: 'ngc-small', $
		add_inchunk: 1, $
		types: 'all' $
	}

	; not lohiz
	; yes one of the main selections
	; or qsoed
	; and primary
	ws = '((str.boss_target1 and 8192) eq 0) and (((str.boss_target1 and 3298535149568) ne 0) or (str.qsoed_prob gt 0.05)) and ((str.resolve_status and 256) ne 0)'


	target_run = '2010-05-01small'
	if not keyword_set(dogather) then begin
		if keyword_set(bycamcol) then begin
			self->create_pbs_bycamcol, 'qso', target_run, $
				pars=pars, $
				walltime=walltime
		endif else begin
			self->create_pbs, 'qso', target_run, $
				pars=pars, $
				walltime=walltime, $
				where_string=ws
		endelse

	endif else begin
		self->create_pbs, 'qso', target_run, $
			/dogather, where_string=ws
	endelse

end





; chunks 1-5
pro bosstarget_pbs::qso2010_04_30chunks, dogather=dogather, bycamcol=bycamcol

	walltime='48:00:00'
	pars = {$
		likelihood_version: 'v2', $
		likelihood_thresh_core: 0.0, $
		nn_xnn_thresh: 0.400, $
		kde_prob_thresh: 0.434, $
		bounds: '1;2;3;4;5', $
		add_inchunk: 1, $
		types: 'all' $
	}

	; not lohiz
	; yes one of the main selections
	; or qsoed
	; and primary
	ws = '((str.boss_target1 and 8192) eq 0) and (((str.boss_target1 and 3298535149568) ne 0) or (str.qsoed_prob gt 0.05)) and ((str.resolve_status and 256) ne 0)'

	target_run = '2010-04-30chunks'
	if not keyword_set(dogather) then begin
		if keyword_set(bycamcol) then begin
			self->create_pbs_bycamcol, 'qso', target_run, $
				pars=pars, $
				walltime=walltime
		endif else begin
			self->create_pbs, 'qso', target_run, $
				pars=pars, $
				walltime=walltime, $
				where_string=ws
		endelse

	endif else begin

		self->create_pbs, 'qso', target_run, /dogather, $
			where_string=ws
	endelse

end



pro bosstarget_pbs::qso2010_04_29chunk5, dogather=dogather

	walltime='48:00:00'
	pars = {$
		likelihood_version: 'v2', $
		likelihood_thresh_core: 0.0, $
		bounds: '5', $
		types: 'core' $
	}

	target_run = '2010-04-29chunk5'
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			/dogather
	endelse

end



; small test region in the north for testing like2
pro bosstarget_pbs::qso2010_04_28small, dogather=dogather

	walltime='48:00:00'
	pars = {$
		likelihood_version: 'v2', $
		likelihood_thresh_core: 0.0, $
		bounds: 'ngc-small', $
		types: 'core' $
	}

	target_run = '2010-04-28small'
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			/dogather
	endelse

end


; this is a test of the combined-flux runs.  Currently a small subset
; of all runs
pro bosstarget_pbs::qsoboss2_2010_04_22, dogather=dogather

	walltime='48:00:00'
	idlutils_v='v5_4_13'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/boss2_qsotest2')
	photo_resolve=filepath(root=bossroot,'resolve/boss2_qsotest')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')




	target_run='boss2-2010-04-22'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather, $
			where_string=where_string
	endelse

end







; brigher cut
pro bosstarget_pbs::lrg_main007

	idlutils_v='v5_4_13'
	photoop_v='v1_9_4'
	bosstarget_v = "v2_0_5"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='main007'

	nper=10

	self->create_pbs_lrg, $
		nper=nper, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end


; brighter cut
pro bosstarget_pbs::lrg_2010_04_08

	idlutils_v='v5_4_13'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='2010-04-08'

	nper=10

	self->create_pbs_lrg, $
		nper=nper, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end


; brighter cut
pro bosstarget_pbs::lrg_2010_04_06

	idlutils_v='v5_4_13'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='2010-04-06'

	nper=10

	self->create_pbs_lrg, $
		nper=nper, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end



; brigher cut
pro bosstarget_pbs::lrg_2010_03_31

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='2010-03-31'

	nper=10

	self->create_pbs_lrg, $
		nper=nper, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end




; this one is with the core of likelihood at 20/sq degree (qso_core_main)
; and the nn_value cut to around 60/sq degree, to be trimmed as a 
; function of position.
pro bosstarget_pbs::qsomain006

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "v2_0_4"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='main006'

	self->create_pbs, 'qso', target_run, $
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper

end




; this one is with the core of likelihood at 20/sq degree (qso_core_main)
; and the nn_value cut to around 60/sq degree, to be trimmed as a 
; function of position.
pro bosstarget_pbs::qso2010_03_15

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	target_run='2010-03-15'

	self->create_pbs, 'qso', target_run, $
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper

end





; brigher cut
pro bosstarget_pbs::lrg_2010_03_10b, noknown=noknown

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	pars={rmaglim:[13.4d0,16.0d0,19.5d0]}
	target_run='2010-03-10b'

	nper=10

	self->create_pbs_lrg, $
		nper=nper, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end




; this is a test of the combined-flux runs.  Currently a small subset
; of all runs
pro bosstarget_pbs::create_pbs_qso_2010_02_10t, dogather=dogather

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/boss2_qsotest')
	photo_resolve=filepath(root=bossroot,'resolve/boss2_qsotest')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	pars={$
		use_combined:1, $
		x2star_permissive: 7.0, $
		nocalib:1, $
		use_nn2: 0, $
		nn_xnn_thresh: 0.2, $
		likelihood_thresh: 0.02, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}


	; first establish the very loose selections on nn,like,kde but no 
	; but no selection on qso_bonus_main, qso_core_main
	
	lohiz= strn(sdss_flagval('boss_target1','qso_known_lohiz'))
	primary = strn(sdss_flagval('resolve_status','survey_primary'))

	; now apply stricter cuts to get 80/sq degree
	qso_first = strn( sdss_flagval('boss_target1','qso_first_boss'))
	qso_midz = strn( sdss_flagval('boss_target1','qso_known_midz'))
	qso_nn = strn( sdss_flagval('boss_target1','qso_nn'))
	qso_like = strn( sdss_flagval('boss_target1','qso_like'))
	qso_kde = strn( sdss_flagval('boss_target1','qso_kde'))

	lohiz_logic = '((str.boss_target1 and '+lohiz+') eq 0)'
	primary_logic = '((str.resolve_status and '+primary+') ne 0)'
	first_logic = '((str.boss_target1 and '+qso_first+') ne 0)'
	midz_logic = '((str.boss_target1 and '+qso_midz+') ne 0)'
	kde_logic = '((str.boss_target1 and '+qso_kde+') ne 0 and str.kde_prob gt 0.69)'
	like_logic = '((str.boss_target1 and '+qso_like+') ne 0 and str.like_ratio gt 0.24)'
	nn_logic = '((str.boss_target1 and '+qso_nn+') ne 0 and str.nn_xnn gt 0.45)'

	where_string=$
		lohiz_logic+' and '+primary_logic + $
		' and ( '+first_logic+' or '+midz_logic+' or '+kde_logic+' or '+like_logic+' or '+nn_logic+' )'




	target_run='2010-02-10t'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather, $
			where_string=where_string
	endelse
end


pro bosstarget_pbs::qso2010_03_03d60, all=all

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; tuned to 60 in chunk 5.  Note kde drops by 10 in the big test
	; region.  tuning done in 2010-03-03l
	pars={$
		nn_value_thresh: 0.418, $
		nn_xnn_thresh: 0.400, $
		$
		likelihood_thresh: 0.127, $
		likelihood_mcthresh: 0.0575, $
		$
		kde_prob_thresh: 0.434 $
	}

	target_run='2010-03-03d60'

	if keyword_set(all) then begin

		; just a gather, no boundary cuts
		self->create_pbs, 'qso', target_run, $
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			nper=nper, $
			/dogather, $
			extra_name='all'

	endif else begin

		add_where_string = $
			' and ((str.intest_region gt 0) or (str.inchunk_bounds gt 0))'
		self->create_pbs, 'qso', target_run, $
			add_where_string=add_where_string, $
			pars=pars, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			nper=nper
	end
end




pro bosstarget_pbs::qso2010_03_03l_bootes

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; just set all the thresholds to 0.0 and then gather in the chunk
	; areas to keep the file size down
	pars={$
		nn_value_thresh: 0.0, $
		nn_xnn_thresh: 0.0, $
		$
		likelihood_thresh: 0.0, $
		likelihood_mcthresh: 0.0, $
		$
		kde_prob_thresh: 0.0 $
	}

	target_run='2010-03-03l'

	add_where_string = $
		' and (str.ra gt 216 and str.ra lt 220' + $
			 ' and str.dec gt 32 and str.dec lt 36)'
	self->create_pbs, 'qso', target_run, $
		add_where_string=add_where_string, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper, $
		/dogather, $
		extra_name='bootes'
end




; gather loosely with the new nn_value added.  we'll tune on that.
; we turn off the rank selection and set qso_bonus_main from the nn value

pro bosstarget_pbs::qso2010_03_03l

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; just set all the thresholds to 0.0 and then gather in the chunk
	; areas to keep the file size down
	pars={$
		nn_value_thresh: 0.0, $
		nn_xnn_thresh: 0.0, $
		$
		likelihood_thresh: 0.0, $
		likelihood_mcthresh: 0.0, $
		$
		kde_prob_thresh: 0.0 $
	}

	target_run='2010-03-03l'

	add_where_string = $
		' and (str.inchunk_bounds gt 0)'
	self->create_pbs, 'qso', target_run, $
		add_where_string=add_where_string, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper
end








; this is an *or* of all the methods, each tuned to 60/sq degree.
; note the nn is kind of crazy right now with no u-g cut, so take with
; a grain of salt, we will update that
;
; also qso_like will be set if either the like thresh or the mclike thresh
; is set
;
; The purpose is to use this to tune to 40/20 per sq degree on the 
; ngc-large test area.
;
pro bosstarget_pbs::create_pbs_qso_2010_03_02d60, dogather=dogather

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	pars={$
		x2star_permissive: 7.0, $
		$
		kde_prob_thresh: 0.43, $
		likelihood_thresh: 0.13, $
		likelihood_mcthresh: 0.058, $
		nn_xnn_thresh: 0.64, $
		nn_value_thresh: 0.42, $ 
		$
		nn_znn_thresh: 1.8, $
		nn_umg_min: -9999.0, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}

	target_run='2010-03-02d60'

	add_where_string = $
		' and ((str.intest_region gt 0) or (str.inchunk_bounds gt 0))'
	if not keyword_set(dogather) then begin
		self->create_pbs, 'qso', target_run, $
			where_string=where_string, $
			add_where_string=add_where_string, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			nper=nper
	endif else begin
		; added this just to fix the add_where_string since I forgot
		; to include the inchunk_bounds, so I can verify my initial tuning
		self->create_pbs, 'qso', target_run, $
			where_string=where_string, $
			add_where_string=add_where_string, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			nper=nper, $
			/dogather

	endelse
end




; gather loosely with the new nn_value added.  we'll tune on that.
; we turn off the rank selection and set qso_bonus_main from the nn value

; same as 2010-03-01-lnnv but with pat prob rank in there
pro bosstarget_pbs::create_pbs_qso_2010_03_02_lnnv

	nper=10

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; use original nn, we've added NN sanity checks internally, 
	; x2star_permissive
	pars={$
		nnrank: 1, $ ; turn on Christophe's ranking
		nn_value_thresh: 0.0, $ ; should be loose
		nocalib:1, $
		x2star_permissive: 7.0, $
		nn_xnn_thresh: 0.0, $
		likelihood_thresh: 0.0, $
		nn_umg_min: -9999.0, $
		nn_znn_thresh: 1.8, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}

	target_run='2010-03-02-lnnv'

	add_where_string = $
		' and (str.inchunk_bounds gt 0)'
	self->create_pbs, 'qso', target_run, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper
end




; gather loosely with the new nn_value added.  we'll tune on that.
; we turn off the rank selection and set qso_bonus_main from the nn value
pro bosstarget_pbs::create_pbs_qso_2010_03_01_lnnv

	nper=20

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; use original nn, we've added NN sanity checks internally, 
	; x2star_permissive
	pars={$
		nnrank: 1, $ ; turn on Christophe's ranking
		nn_value_thresh: 0.0, $ ; should be loose
		nocalib:1, $
		x2star_permissive: 7.0, $
		nn_xnn_thresh: 0.0, $
		likelihood_thresh: 0.0, $
		nn_umg_min: -9999.0, $
		nn_znn_thresh: 1.8, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}

	target_run='2010-03-01-lnnv'

	add_where_string = $
		' and (str.inchunk_bounds gt 0)'
	self->create_pbs, 'qso', target_run, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		nper=nper
end







; gather loosely with the new nn_value added.  we'll tune on that.
; we turn off the rank selection and set qso_bonus_main from the nn value
pro bosstarget_pbs::create_pbs_qso_2010_01_12l_lnnv

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; use original nn, we've added NN sanity checks internally, 
	; x2star_permissive
	pars={$
		nnrank: 1, $ ; turn on Christophe's ranking
		nn_value_thresh: 0.0, $ ; should be loose
		nocalib:1, $
		x2star_permissive: 7.0, $
		nn_xnn_thresh: 0.0, $
		likelihood_thresh: 0.0, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}

	target_run='2010-01-12l'

	add_where_string = $
		' and (str.inchunk_bounds gt 0)'
	self->create_pbs, 'qso', target_run, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		/dogather, $
		extra_name='lnnv'
end








; Now this one is the same as below but with the thresholds derived from
; analyzing those results for 40/sq degree in any of the main methods
; no limit on area
pro bosstarget_pbs::create_pbs_qso_2010_01_12l_d40

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	pars={$
		x2star_permissive: 7.0, $
		nocalib:1, $
		use_nn2: 0, $
		nn_xnn_thresh: 0.2, $
		likelihood_thresh: 0.02, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}


	; first establish the very loose selections on nn,like,kde but no 
	; but no selection on qso_bonus_main, qso_core_main
	
	lohiz= strn(sdss_flagval('boss_target1','qso_known_lohiz'))
	primary = strn(sdss_flagval('resolve_status','survey_primary'))

	; now apply stricter cuts to get 80/sq degree
	qso_first = strn( sdss_flagval('boss_target1','qso_first_boss'))
	qso_midz = strn( sdss_flagval('boss_target1','qso_known_midz'))
	qso_nn = strn( sdss_flagval('boss_target1','qso_nn'))
	qso_like = strn( sdss_flagval('boss_target1','qso_like'))
	qso_kde = strn( sdss_flagval('boss_target1','qso_kde'))

	lohiz_logic = '((str.boss_target1 and '+lohiz+') eq 0)'
	primary_logic = '((str.resolve_status and '+primary+') ne 0)'
	first_logic = '((str.boss_target1 and '+qso_first+') ne 0)'
	midz_logic = '((str.boss_target1 and '+qso_midz+') ne 0)'
	kde_logic = '((str.boss_target1 and '+qso_kde+') ne 0 and str.kde_prob gt 0.69)'
	like_logic = '((str.boss_target1 and '+qso_like+') ne 0 and str.like_ratio gt 0.24)'
	nn_logic = '((str.boss_target1 and '+qso_nn+') ne 0 and str.nn_xnn gt 0.45)'

	where_string=$
		lohiz_logic+' and '+primary_logic + $
		' and ( '+first_logic+' or '+midz_logic+' or '+kde_logic+' or '+like_logic+' or '+nn_logic+' )'

	target_run='2010-01-12l'

	self->create_pbs, 'qso', target_run, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		/dogather, $
		where_string=where_string, $
		extra_name='d40'
end






; Now this one is the same as below but with the thresholds derived from
; analyzing those results for 80/sq degree in any of the main methods
; also limit area
pro bosstarget_pbs::create_pbs_qso_2010_01_12l_d80

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; this same as before
	pars={$
		x2star_permissive: 7.0, $
		nocalib:1, $
		use_nn2: 0, $
		nn_xnn_thresh: 0.2, $
		likelihood_thresh: 0.02, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}


	; first establish the very loose selections on nn,like,kde but no 
	; but no selection on qso_bonus_main, qso_core_main
	
	lohiz= strn(sdss_flagval('boss_target1','qso_known_lohiz'))
	primary = strn(sdss_flagval('resolve_status','survey_primary'))

	; now apply stricter cuts to get 80/sq degree
	qso_first = strn( sdss_flagval('boss_target1','qso_first_boss'))
	qso_midz = strn( sdss_flagval('boss_target1','qso_known_midz'))
	qso_nn = strn( sdss_flagval('boss_target1','qso_nn'))
	qso_like = strn( sdss_flagval('boss_target1','qso_like'))
	qso_kde = strn( sdss_flagval('boss_target1','qso_kde'))

	where_string=$
		'((str.boss_target1 and '+lohiz+') eq 0)' + $
		' and ((str.resolve_status and '+primary+') ne 0)'+$
		' and ('+$
		 ' str.ra gt 130 and str.ra lt 190 and str.dec gt 0 and str.dec lt 15'+$
		' )'+$
		' and ('+$
		 '  ( ((str.boss_target1 and '+qso_kde+') ne 0 and str.kde_prob gt 0.10)'+$
		    ' or ((str.boss_target1 and '+qso_like+') ne 0 and str.like_ratio gt 0.07)'+$
		    ' or ((str.boss_target1 and '+qso_nn+') ne 0 and str.nn_xnn gt 0.25)'+$
		    ' or ((str.boss_target1 and '+qso_midz+') ne 0)'+$
		    ' or ((str.boss_target1 and '+qso_first+') ne 0)'+$
		   ')'+$
		')'

	target_run='2010-01-12l'

	self->create_pbs, 'qso', target_run, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		/dogather, $
		where_string=where_string, $
		extra_name='d80'
end




; gather loosely but now with x2star limit of 7 for bonus as well as core.
; we'll use this to test single methods tuned to 40/sq degree.
pro bosstarget_pbs::create_pbs_qso_2010_01_12l_x2star7

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	; use original nn, we've added NN sanity checks internally, 
	; x2star_permissive
	pars={$
		x2star_permissive: 7.0, $
		nocalib:1, $
		use_nn2: 0, $
		nn_xnn_thresh: 0.2, $
		likelihood_thresh: 0.02, $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
	}

	target_run='2010-01-12l'

	self->create_pbs, 'qso', target_run, $
		pars=pars, $
		runs=runs, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
		/dogather, $
		extra_name='x2star7'
end




; gather loosely for tuning to 100/sq degree.
pro bosstarget_pbs::create_pbs_qso_2010_01_12l, dogather=dogather

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={$
		nocalib:1, $
		use_nn2: 1, $
		nn_xnn2_thresh: 0.2, $
		likelihood_thresh: 0.02, $
		;logstardensmax_bright_permissive: 1.0, $
		;logstardensmax_faint_permissive:  1.0, $
		;logqsodensmin_bright_permissive: -1.0, $
		;logqsodensmin_faint_permissive:  -1.0  $
		logstardensmax_bright_permissive: 0.5, $
		logstardensmax_faint_permissive:  0.3, $
		logqsodensmin_bright_permissive: -1.0, $
		logqsodensmin_faint_permissive:  -1.0  $
		}

	target_run='2010-01-12l'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather
	endelse
end






; this version not restricted on runs
pro bosstarget_pbs::create_pbs_qso_main005, dogather=dogather

	;walltime='48:00:00'
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "v2_0_3"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='main005'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather
	endelse
end


pro bosstarget_pbs::create_pbs_std_main005

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = 'v2_0_3'

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='main005'
	self->create_pbs, 'std', target_run, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

end






pro bosstarget_pbs::create_pbs_lrg_main005, noknown=noknown
	; rerun chunk2 with new code
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "v2_0_3"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	pars={nocalib:1}

	target_run='main005'

	self->create_pbs_lrg, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end







; this version not restricted on runs
pro bosstarget_pbs::create_pbs_qso_2010_01_06, dogather=dogather

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='2010-01-06'

	walltime='48:00:00'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather
	endelse
end




pro bosstarget_pbs::create_pbs_qso_2010_01_05h, dogather=dogather

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='2010-01-05h'


	btdir=getenv('BOSSTARGET_DIR')
	runlist_file=filepath($
		root=btdir,subdir='data','2010-01-hennawi-runlist.txt')
	readcol, runlist_file, runs, f='I'

	walltime='48:00:00'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather
	endelse
end



pro bosstarget_pbs::create_pbs_qso_2010_01_04, dogather=dogather

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='2010-01-04'


	btdir=getenv('BOSSTARGET_DIR')
	runlist_file=filepath($
		root=btdir,subdir='data','2010-01-ordered-runlist.txt')
	readcol, runlist_file, runs, f='I'

	walltime='48:00:00'

	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			$
			walltime=walltime

	endif else begin
		self->create_pbs, 'qso', target_run, $
			pars=pars, $
			runs=runs, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
			/dogather
	endelse
end


pro bosstarget_pbs::create_pbs_std_2009_11_16_v2

	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')


	; same run as the qso run on this area
	pars={nocalib:1}

	target_run='2010-01-04'
	self->create_pbs, 'std', target_run, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

end




; tests using PHOTO_SWEEP 2009-11-16.v2
pro bosstarget_pbs::create_pbs_lrg_2009_11_16_v2, noknown=noknown
	; rerun chunk2 with new code
	idlutils_v='v5_4_11'
	photoop_v='v1_9_4'
	bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"

	bossroot=getenv('BOSS_ROOT')
	photo_sweep=filepath(root=bossroot, 'sweeps/2009-11-16.v2')
	photo_resolve=filepath(root=bossroot,'resolve/2009-11-16')
	photo_calib=filepath(root=bossroot,'calib/2009-06-14/calibs/fall09i')

	pars={nocalib:1}

	;btdir=getenv('BOSSTARGET_DIR')
	;runlist_file=filepath($
	;	root=btdir,subdir='data','2010-01-ordered-runlist.txt')
	;readcol, runlist_file, runs, f='I'

	target_run='2010-01-04'

	self->create_pbs_lrg, $
		target_run, noknown=noknown, $
		pars=pars, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib

	return

end

; generic method for lrgs
pro bosstarget_pbs::create_pbs_lrg, $
		run, noknown=noknown, $
		pars=pars, $
		nper=nper, $
        $
        queue=queue, $
		$
		idlutils_v=idlutils_v, $
		photoop_v=photoop_v, $
		bosstarget_v=bosstarget_v, $
		$
		photo_sweep=photo_sweep, $
		photo_resolve=photo_resolve, $
		photo_calib=photo_calib, $
        boss_target=boss_target

	if not keyword_set(noknown) then begin
		self->create_pbs, 'lrg', run, $
			pars=pars, $
			nper=nper, $
            $
            queue=queue, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
            boss_target=boss_target
	endif else begin

		bt=obj_new('bosstarget')
		ws=bt->default_where_string('lrg')
		known=string(sdss_flagval('boss_target1','sdss_gal_known'),f='(i0)')
		ws += ' and ((str.boss_target1 and '+known+') eq 0)'

		self->create_pbs, 'lrg', run, $
			pars=pars, $
			nper=nper, $
            $
            queue=queue, $
			$
			idlutils_v=idlutils_v, $
			photoop_v=photoop_v, $
			bosstarget_v=bosstarget_v, $
			$
			photo_sweep=photo_sweep, $
			photo_resolve=photo_resolve, $
			photo_calib=photo_calib, $
            boss_target=boss_target, $
			$
			/dogather, /reselect, $
			where_string=ws, $
			extra_name='noknown'
	endelse
end




;
; Bug fix in std using nocalib
;

pro bosstarget_pbs::create_pbs_std_main004_nocalib
	photo_sweep=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	idlutils_v="v5_4_11"
	bosstarget_v="-r /home/esheldon/exports/bosstarget-v2_0_2"

	; same run as the qso run on this area
	target_run='main004'
	pars={nocalib:1}
	self->create_pbs, 'std', target_run, $
		pars=pars, $
		photo_sweep=photo_sweep, $
		bosstarget_v=bosstarget_v, $
		idlutils_v=idlutils_v
end



;
; run of chunk2 with new code
;

pro bosstarget_pbs::create_pbs_lrg_main003, noknown=noknown
	; rerun chunk2 with new code
	photo_sweep=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-09-28"
	idlutils_v="v5_4_11"
	bosstarget_v="v2_0_0"

	run='main003'
	if not keyword_set(noknown) then begin
		self->create_pbs, 'lrg', run, $
			pars=pars, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v
	endif else begin

		bt=obj_new('bosstarget')
		ws=bt->default_where_string('lrg')
		known=string(sdss_flagval('boss_target1','sdss_gal_known'),f='(i0)')
		ws += ' and ((str.boss_target1 and '+known+') eq 0)'

		self->create_pbs, 'lrg', run, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v, $
			pars=pars, $
			/dogather, /reselect, $
			where_string=ws, $
			extra_name='noknown'
	endelse
end


pro bosstarget_pbs::create_pbs_qso_main003, dogather=dogather
	; rerun chunk2 with new code
	photo_sweep=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-09-28"
	idlutils_v="v5_4_11"
	bosstarget_v="v2_0_0"

	trun='main003'
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', trun, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v, $
			pars=pars
	endif else begin
		self->create_pbs, 'qso', trun, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v, $
			pars=pars, $
			/dogather
	endelse
end
pro bosstarget_pbs::create_pbs_std_main003
	PHOTO_SWEEP=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-09-28"
	IDLUTILS_V="v5_4_11"
	BOSSTARGET_V="v2_0_0"

	; same run as the qso run on this area
	target_run='main003'
	self->create_pbs, 'std', target_run, $
		photo_sweep=PHOTO_SWEEP, $
		bosstarget_v=BOSSTARGET_V, $
		idlutils_v=IDLUTILS_V
end



;
; mai002, chunks 3-4 *without* non-photometric objects removed
;


pro bosstarget_pbs::create_pbs_lrg_main002_nocalib, noknown=noknown
	photo_sweep=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	idlutils_v="v5_4_11"
	bosstarget_v="v2_0_1"

	run='main002'
	pars={nocalib:1}
	if not keyword_set(noknown) then begin
		self->create_pbs, 'lrg', run, $
			pars=pars, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v
	endif else begin

		bt=obj_new('bosstarget')
		ws=bt->default_where_string('lrg')
		known=string(sdss_flagval('boss_target1','sdss_gal_known'),f='(i0)')
		ws += ' and ((str.boss_target1 and '+known+') eq 0)'

		self->create_pbs, 'lrg', run, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v, $
			pars=pars, $
			/dogather, /reselect, $
			where_string=ws, $
			extra_name='noknown'
	endelse
end

pro bosstarget_pbs::create_pbs_qso_main002_nocalib, dogather=dogather
	photo_sweep=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	idlutils_v="v5_4_11"
	bosstarget_v="v2_0_1"

	trun='main002'

	pars={nocalib:1}
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', trun, $
			pars=pars, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v
	endif else begin
		self->create_pbs, 'qso', trun, $
			pars=pars, $
			photo_sweep=photo_sweep, $
			bosstarget_v=bosstarget_v, $
			idlutils_v=idlutils_v, $
			/dogather
	endelse
end


;
; mai001, chunks 3-4 with non-photometric objects removed
;


pro bosstarget_pbs::create_pbs_lrg_main001, noknown=noknown
	PHOTO_SWEEP=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	IDLUTILS_V="v5_4_11"
	BOSSTARGET_V="v2_0_0"

	run='main001'
	if not keyword_set(noknown) then begin
		self->create_pbs, 'lrg', run, $
			photo_sweep=PHOTO_SWEEP, $
			bosstarget_v=BOSSTARGET_V, $
			idlutils_v=IDLUTILS_V
	endif else begin

		bt=obj_new('bosstarget')
		ws=bt->default_where_string('lrg')
		known=string(sdss_flagval('boss_target1','sdss_gal_known'),f='(i0)')
		ws += ' and ((str.boss_target1 and '+known+') eq 0)'

		self->create_pbs, 'lrg', run, $
			photo_sweep=PHOTO_SWEEP, $
			bosstarget_v=BOSSTARGET_V, $
			idlutils_v=IDLUTILS_V, $
			/dogather, /reselect, $
			where_string=ws, $
			extra_name='noknown'
	endelse
end
pro bosstarget_pbs::create_pbs_qso_main001, dogather=dogather
	PHOTO_SWEEP=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	IDLUTILS_V="v5_4_11"
	BOSSTARGET_V="v2_0_0"

	trun='main001'
	if not keyword_set(dogather) then begin
		self->create_pbs_bycamcol, 'qso', trun, $
			photo_sweep=PHOTO_SWEEP, $
			bosstarget_v=BOSSTARGET_V, $
			idlutils_v=IDLUTILS_V
	endif else begin
		self->create_pbs, 'qso', trun, $
			photo_sweep=PHOTO_SWEEP, $
			bosstarget_v=BOSSTARGET_V, $
			idlutils_v=IDLUTILS_V, $
			/dogather
	endelse
end
pro bosstarget_pbs::create_pbs_std_main001
	PHOTO_SWEEP=$
		"/clusterfs/riemann/raid006/bosswork/groups/boss/sweeps/2009-11-16"
	IDLUTILS_V="v5_4_11"
	BOSSTARGET_V="v2_0_0"

	; same run as the qso run on this area
	target_run='main001'
	self->create_pbs, 'std', target_run, $
		photo_sweep=PHOTO_SWEEP, $
		bosstarget_v=BOSSTARGET_V, $
		idlutils_v=IDLUTILS_V
end



pro bosstarget_pbs::create_pbs_bycamcol, target_type, target_run, $
		bosstarget_v=bosstarget_v, $
		runs=runs, $
        $
        queue=queue, $
        $
		photoop_v=photoop_v, $
		idlutils_v=idlutils_v, $
		photo_calib=photo_calib, $
		photo_resolve=photo_resolve, $
		photo_sweep=photo_sweep, $
        boss_target=boss_target, $
        $
		pars=pars, $
        prepend_setups=prepend_setups, $
        extra_setups=extra_setups, $
        $
		ignore_resolve=ignore_resolve, $
		commissioning=commissioning, $
		comm2=comm2, $ ; this is qso only currently
		walltime=walltime

    sdssidl_v = "-r /home/esheldon/exports/sdssidl-work"

	if n_elements(bosstarget_v) eq 0 then begin
		bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"
	endif
	;if n_elements(photoop_v) eq 0 then photoop_v = "v1_10_2"
	;if n_elements(idlutils_v) eq 0 then idlutils_v = 'v5_4_22'
	if n_elements(photoop_v) eq 0 then photoop_v = ""
	if n_elements(idlutils_v) eq 0 then idlutils_v = ''

	if n_elements(commissioning) eq 0 then commissioning=0
	if n_elements(comm2) eq 0 then comm2=0

	add_arrval,"setup sdssidl "+sdssidl_v, setups 
	add_arrval,"setup tree", setups 
	add_arrval,"setup photoop "+photoop_v, setups
	add_arrval,"setup idlutils "+idlutils_v, setups
	add_arrval,"setup bosstarget "+bosstarget_v, setups


	bossroot=getenv('BOSS_ROOT')
	if n_elements(photo_sweep) eq 0 then begin
		PHOTO_SWEEP=filepath(root=bossroot,'sweeps/dr8_final')
	endif
	if n_elements(photo_resolve) eq 0 then begin
		PHOTO_RESOLVE=filepath(root=bossroot,'resolve/2010-05-23')
	endif
	if n_elements(photo_calib) eq 0 then begin
		PHOTO_CALIB=filepath(root=bossroot,'resolve/dr8_final')
	endif
	if n_elements(boss_target) eq 0 then begin
        BOSS_TARGET=filepath(root=bossroot,'target')
	endif

	add_arrval, 'export PHOTO_SWEEP='+photo_sweep, setups
	add_arrval, 'export PHOTO_RESOLVE='+photo_resolve, setups
	add_arrval, 'export PHOTO_CALIB='+photo_calib, setups
	add_arrval, 'export BOSS_TARGET='+boss_target, setups


    if n_elements(extra_setups) ne 0 then begin
        add_arrval, extra_setups, setups
    endif
    if n_elements(prepend_setups) ne 0 then begin
        setups = [prepend_setups, setups]
    endif




	;setups = strjoin(setups, ' && ')

	sweep_old=getenv('PHOTO_SWEEP')
	resolve_old=getenv('PHOTO_RESOLVE')
	setenv, 'PHOTO_SWEEP='+PHOTO_SWEEP
	setenv, 'PHOTO_RESOLVE='+PHOTO_RESOLVE
	bt=obj_new('bosstarget')
	bt->cache_runlist, /force
	if n_elements(runs) ne 0 then begin
		bt->match_runlist, runs, tmpruns, reruns
	endif else begin
		bt->runlist, runs, reruns
	endelse
	setenv, 'PHOTO_SWEEP='+sweep_old
	setenv, 'PHOTO_RESOLVE='+resolve_old

	print,'Found: ',n_elements(runs),' runs',f='(a,i0,a)'


	pbs_dir=expand_tilde('~/pbs/'+target_type+'/'+target_run)
	file_mkdir, pbs_dir

	qsub_file = path_join(pbs_dir, 'submit-'+target_type+'-bycamcol')
	fbase = target_type

	if keyword_set(commissioning) then begin
		qsub_file+='-comm'
		fbase+='-comm'
	endif else if keyword_set(comm2) then begin
		qsub_file+='-comm2'
		fbase+='-comm2'
	endif

	qsub_file+='.sh'
	openw, qsub_lun, qsub_file, /get_lun


	nrun=n_elements(runs)
	ntot=nrun*6
	ii=0L
	for i=0L, nrun-1 do begin
		run = runs[i]

		rstr = run2string(run)

		for camcol=1,6 do begin
			cstr=string(camcol,f='(i0)')

			job_name = target_type+'-'+rstr+'-'+cstr

			pbs_file = repstr(job_name, target_type, fbase)+'.pbs'
			pbs_file=filepath(root=pbs_dir, pbs_file)

			target_command = $
				string(f='(%"%s, %s, %s, run=%d, camcol=%d")', $
				"    bt->process_runs", $
				"'"+target_type+"'", "'"+target_run+"'", run, camcol)


			;if keyword_set(commissioning) then begin
			;	target_command += ", /commissioning"
			;endif else if keyword_set(comm2) then begin
			;	target_command += ", /comm2"
			;endif
			idl_commands="bt=obj_new('bosstarget'"
			if keyword_set(commissioning) then begin
				idl_commands += ",/commissioning"
			endif else if keyword_set(comm2) then begin
				idl_commands += ",/comm2"
			endif
			if keyword_set(ignore_resolve) then begin
				idl_commands += ",/ignore_resolve"
			endif
			idl_commands += ")"

			if n_elements(pars) ne 0 then begin
				idl_commands = [idl_commands, 'pars='+tostring(pars)]
				target_command += ', pars=pars'
			endif 

			idl_commands=[idl_commands,target_command]

			pbs_riemann_idl, $
				pbs_file, idl_commands, setup=setups, job_name=job_name, $
				walltime=walltime, queue=queue


			printf, qsub_lun, $
				'echo -n "',ii+1,'/',ntot,' ',pbs_file,' "',$
				format='(a,i0,a,i0,a,a,a)'
			printf, qsub_lun, 'qsub '+pbs_file
			ii=ii+1
		endfor
	endfor


	free_lun, qsub_lun

end


pro bosstarget_pbs::create_pbs_byrun, target_type, target_run, $
		bosstarget_v=bosstarget_v, $
		photoop_v=photoop_v, $
		idlutils_v=idlutils_v, $
		photo_calib=photo_calib, $
		photo_resolve=photo_resolve, $
		photo_sweep=photo_sweep, $
        boss_target=boss_target, $
		pars=pars, $
		runs=runs, $
		oldcache=oldcache, $
		ignore_resolve=ignore_resolve, $
		commissioning=commissioning, $
		comm2=comm2, $; this is qso only currently
		where_string=where_string
	

    sdssidl_v = "-r /home/esheldon/exports/sdssidl-work"

	if n_elements(bosstarget_v) eq 0 then begin
		bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"
	endif
	;if n_elements(photoop_v) eq 0 then photoop_v = "v1_10_2"
	;if n_elements(idlutils_v) eq 0 then idlutils_v = 'v5_4_22'
	if n_elements(photoop_v) eq 0 then photoop_v = ""
	if n_elements(idlutils_v) eq 0 then idlutils_v = ''

	if n_elements(commissioning) eq 0 then commissioning=0
	if n_elements(comm2) eq 0 then comm2=0

	add_arrval,"setup sdssidl "+sdssidl_v, setups 
	add_arrval,"setup tree", setups 
	add_arrval,"setup photoop "+photoop_v, setups
	add_arrval,"setup idlutils "+idlutils_v, setups
	add_arrval,"setup bosstarget "+bosstarget_v, setups


	bossroot=getenv('BOSS_ROOT')
	if n_elements(photo_sweep) eq 0 then begin
		PHOTO_SWEEP=filepath(root=bossroot,'sweeps/dr8_final')
	endif
	if n_elements(photo_resolve) eq 0 then begin
		PHOTO_RESOLVE=filepath(root=bossroot,'resolve/2010-05-23')
	endif
	if n_elements(photo_calib) eq 0 then begin
		PHOTO_CALIB=filepath(root=bossroot,'resolve/dr8_final')
	endif
	if n_elements(boss_target) eq 0 then begin
        BOSS_TARGET=filepath(root=bossroot,'target')
	endif

	add_arrval, 'export PHOTO_SWEEP='+photo_sweep, setups
	add_arrval, 'export PHOTO_RESOLVE='+photo_resolve, setups
	add_arrval, 'export PHOTO_CALIB='+photo_calib, setups
	add_arrval, 'export BOSS_TARGET='+boss_target, setups




	;setups = strjoin(setups, ' && ')

	sweep_old=getenv('PHOTO_SWEEP')
	resolve_old=getenv('PHOTO_RESOLVE')
    boss_target_old = getenv('BOSS_TARGET')
	setenv, 'PHOTO_SWEEP='+PHOTO_SWEEP
	setenv, 'PHOTO_RESOLVE='+PHOTO_RESOLVE
	setenv, 'BOSS_TARGET='+BOSS_TARGET
	bt=obj_new('bosstarget')
	bt->cache_runlist, /force
	if n_elements(runs) ne 0 then begin
		; make sure they match
		bt->match_runlist, runs, tmpruns, tmpreruns
		subset=1
	endif else begin
		bt->runlist, runs, reruns
		subset=0
	endelse
	setenv, 'PHOTO_SWEEP='+sweep_old
	setenv, 'PHOTO_RESOLVE='+resolve_old
	setenv, 'BOSS_TARGET='+boss_target_old

	print,'Found: ',n_elements(runs),' runs',f='(a,i0,a)'


	pbs_dir=expand_tilde('~/pbs/'+target_type+'/'+target_run)
	file_mkdir, pbs_dir

	qsub_file = path_join(pbs_dir, 'submit-'+target_type+'-byrun')
	fbase = target_type



	if keyword_set(commissioning) then begin
		qsub_file+='-comm'
		fbase+='-comm'
	endif else if keyword_set(comm2) then begin
		qsub_file+='-comm2'
		fbase+='-comm2'
	endif

	combine_file = path_join(pbs_dir, 'combine-byrun.pbs')
	if n_elements(extra_name) ne 0 then begin
		combine_file = repstr(combine_file, '.pbs', '-'+extra_name+'.pb')
		extra_gather = ', extra_name="'+extra_name+'"'
	endif else begin
		extra_gather = ''
	endelse


	openw, lun, combine_file, /get_lun

	printf, lun, 'idl<<EOF'
	printf, lun, "  setenv,'PHOTO_SWEEP="+photo_sweep+"'"
	printf, lun, "  setenv,'PHOTO_RESOLVE="+photo_resolve+"'"
	printf, lun, "  setenv,'PHOTO_CALIB="+photo_calib+"'"
	printf, lun, "  setenv,'BOSS_TARGET="+BOSS_TARGET+"'"
	printf, lun, '  runs='+tostring(runs)
	printf, lun, '  bt=obj_new("bosstarget")'
	combine_command = string($
		"  bt->gather2file, '",target_type,"','",target_run,"'",+$
		extra_gather, $
		f='(a,a,a,a,a,a)' )
	if subset then begin
		combine_command += ', runs=runs'
	endif
	if n_elements(where_string) ne 0 then begin
		combine_command += ", where_string='"+where_string+"'"
	endif
	printf, lun, combine_command
	printf, lun, 'EOF'

	free_lun, lun

	if keyword_set(onlycombine) then begin
		print,'Just writing combine script'
		return
	endif


	qsub_file+='.sh'
	openw, qsub_lun, qsub_file, /get_lun


	nrun=n_elements(runs)
	ii=0L
	for i=0L, nrun-1 do begin
		run = runs[i]

		rstr = run2string(run)

		job_name = target_type+'-'+rstr

		pbs_file = repstr(job_name, target_type, fbase)+'.pbs'
		pbs_file=filepath(root=pbs_dir, pbs_file)


		idl_commands="bt=obj_new('bosstarget'"
		if keyword_set(commissioning) then begin
			idl_commands += ",/commissioning"
		endif else if keyword_set(comm2) then begin
			idl_commands += ",/comm2"
		endif
		if keyword_set(ignore_resolve) then begin
			idl_commands += ",/ignore_resolve"
		endif
		if keyword_set(oldcache) and target_type eq 'qso' then begin
			idl_commands += ",/oldcache"
		endif
		idl_commands += ")"


		if n_elements(pars) ne 0 then begin
			idl_commands = [idl_commands, 'pars='+tostring(pars)]
		endif 

		for camcol=1,6 do begin

			target_command = $
				string(f='(%"%s, %s, %s, run=%d, camcol=%d")', $
				"    bt->process_runs", $
				"'"+target_type+"'", "'"+target_run+"'", run, camcol)

			if n_elements(pars) ne 0 then begin
				target_command += ', pars=pars'
			endif
			

			idl_commands=[idl_commands,target_command]
		endfor
		pbs_riemann_idl, $
			pbs_file, idl_commands, setup=setups, job_name=job_name


		printf, qsub_lun, $
			'echo -n "',ii+1,'/',nrun,' ',pbs_file,' "',$
			format='(a,i0,a,i0,a,a,a)'
		printf, qsub_lun, 'qsub '+pbs_file
		ii=ii+1
	endfor


	free_lun, qsub_lun

end







pro bosstarget_pbs::create_pbs, target_type, target_run,  $
		bosstarget_v=bosstarget_v, $
		runs=runs, $
        $
        queue=queue, $
        $
		photoop_v=photoop_v, $
		idlutils_v=idlutils_v, $
		photo_calib=photo_calib, $
		photo_resolve=photo_resolve, $
		photo_sweep=photo_sweep, $
        boss_target=boss_target, $
		$
		pars=pars, reselect=reselect, extra_name=extra_name, $
        prepend_setups=prepend_setups, $
        extra_setups=extra_setups, $
		$
		dotarget=dotarget,$
		dogather=dogather,$
		nper=nper, $
		fpobjc=fpobjc, $
		match_method=match_method, $
		commissioning=commissioning, $
		comm2=comm2, $
		noverify=noverify, $
		where_string=where_string, $
		add_where_string=add_where_string, $
		$
		walltime=walltime

	if n_elements(dotarget) eq 0 and n_elements(dogather) eq 0 then begin
		dotarget=1
		dogather=1
	endif
	if n_elements(nper) eq 0 then begin
		nper=2
	endif

	if n_elements(runs) ne 0 then begin
		runstring=tostring(runs)
	endif

	if n_elements(fpobjc) eq 0 then fpobjc=0
	if n_elements(commissioning) eq 0 then commissioning=0
	if n_elements(comm2) eq 0 then comm2=0



	if n_elements(bosstarget_v) eq 0 then begin
		bosstarget_v = "-r /home/esheldon/exports/bosstarget-work"
	endif

    sdssidl_v = "-r /home/esheldon/exports/sdssidl-work"

	;if n_elements(photoop_v) eq 0 then photoop_v = "v1_10_2"
	;if n_elements(idlutils_v) eq 0 then idlutils_v = 'v5_4_22'
	if n_elements(photoop_v) eq 0 then photoop_v = ""
	if n_elements(idlutils_v) eq 0 then idlutils_v = ''


	;if n_elements(pars) ne 0 and n_elements(extra_name) eq 0 then begin
	;	message,'You must send an extra_name= with pars'
	;endif


	add_arrval,"setup sdssidl "+sdssidl_v, setups 
	add_arrval,"setup tree", setups 
	add_arrval,"setup photoop "+photoop_v, setups
    if idlutils_v ne '' then begin
        add_arrval,"setup idlutils "+idlutils_v, setups
    endif
	add_arrval,"setup bosstarget "+bosstarget_v, setups


	bossroot=getenv('BOSS_ROOT')
	if n_elements(photo_sweep) eq 0 then begin
		PHOTO_SWEEP=filepath(root=bossroot,'sweeps/dr8_final')
	endif
	if n_elements(photo_resolve) eq 0 then begin
		PHOTO_RESOLVE=filepath(root=bossroot,'resolve/2010-05-23')
	endif
	if n_elements(photo_calib) eq 0 then begin
		PHOTO_CALIB=filepath(root=bossroot,'resolve/dr8_final')
	endif
	if n_elements(boss_target) eq 0 then begin
        BOSS_TARGET=filepath(root=bossroot,'target')
	endif

	add_arrval, 'export PHOTO_SWEEP='+photo_sweep, setups
	add_arrval, 'export PHOTO_RESOLVE='+photo_resolve, setups
	add_arrval, 'export PHOTO_CALIB='+photo_calib, setups
	add_arrval, 'export BOSS_TARGET='+boss_target, setups


    if n_elements(extra_setups) ne 0 then begin
        add_arrval, extra_setups, setups
    endif
    if n_elements(prepend_setups) ne 0 then begin
        setups = [prepend_setups, setups]
    endif


	;setups = strjoin(setups, ' && ')

	sweep_old=getenv('PHOTO_SWEEP')
	resolve_old=getenv('PHOTO_RESOLVE')
	setenv, 'PHOTO_SWEEP='+PHOTO_SWEEP
	setenv, 'PHOTO_RESOLVE='+PHOTO_RESOLVE

	bt=obj_new('bosstarget')
	bt->split_runlist, runptrs, rerunptrs, nper=nper, /force, $
		runs=runs
	njobs = n_elements(runptrs)
	ptr_free, runptrs, rerunptrs

	setenv, 'PHOTO_SWEEP='+sweep_old
	setenv, 'PHOTO_RESOLVE='+resolve_old


	pbs_dir='~/pbs/'+target_type+'/'+target_run
	pbs_dir=expand_tilde(pbs_dir)
	file_mkdir, pbs_dir

	qsub_file = path_join(pbs_dir, 'submit-'+target_type)
	check_file = path_join(pbs_dir, 'check.sh')
	combine_file = path_join(pbs_dir, 'combine-partial.pbs')
	if n_elements(extra_name) ne 0 then begin
		combine_file = repstr(combine_file, '.pbs', '-'+extra_name+'.pbs')
	endif

	fbase = target_type

	if fpobjc then begin
		qsub_file+='-fpobjc'
		fbase+='-fpobjc'
	endif
	if keyword_set(commissioning) then begin
		qsub_file+='-comm'
		fbase+='-comm'
	endif else if keyword_set(comm2) then begin
		qsub_file+='-comm2'
		fbase+='-comm2'
	endif


	if n_elements(match_method) ne 0 then begin
		qsub_file += '-match-gather'
		fbase += '-match-gather'
	endif else begin
		if keyword_set(dotarget) then begin
			qsub_file += '-target'
			fbase += '-target'
		endif
		if keyword_set(dogather) then begin
			qsub_file += '-gather'
			fbase += '-gather'
		endif
	endelse


	if n_elements(extra_name) ne 0 then begin
		qsub_file += '-'+extra_name
		fbase += '-'+extra_name
		extra_gather = ', extra_name="'+extra_name+'"'
	endif else begin
		extra_gather=''
	endelse

	qsub_file+='.sh'
	print,'writing ',qsub_file
	openw, lun, qsub_file, /get_lun

	numstr = string(njobs-1, format='(I03)')
    printf, lun
    printf, lun, 'for i in `seq -w 0 '+numstr+'`; do' 
    printf, lun, '    file='+fbase+'-${i}.pbs'
    printf, lun, '    echo -n "qsub $file  "'
    printf, lun, '    qsub $file'
    printf, lun, 'done'
	free_lun, lun

	openw, lun, check_file, /get_lun
	printf,lun,'for f in *.pbs; do'
	printf,lun,'    if [ ! -e "$f.log" ]; then'
	printf,lun,'        echo $f'
	printf,lun,'    fi'
	printf,lun,'done'
	free_lun, lun


	comm=string($
		"  bt->gather_partial, '",target_type,"','",target_run,"'",+$
		", photo_sweep=photo_sweep, /combine, nper=",nper,extra_gather, $
		f='(a,a,a,a,a,a,i0,a)')
	if n_elements(runs) ne 0 then begin
		printf, lun, '  runs='+runstring
		mess += ', runs=runs'
	endif

    combine_commands=['bt=obj_new("bosstarget")',comm]

    pbs_riemann_idl, combine_file, combine_commands, $
        setup=setups, job_name='qso-combine', $
        walltime=walltime, $
        queue=queue



	for job=0L, njobs-1 do begin

		jobstr = string(job,format='(I03)')

		jfbase = fbase + '-'+jobstr
		
		pbs_file=filepath(root=pbs_dir, jfbase+'.pbs')

		target_command = $
			string(f='(%"%s, %s, %s, %d, nper=%d")', $
			"    bt->process_partial_runs", $
			"'"+target_type+"'", "'"+target_run+"'", job, nper)

		gather_command = string(f='(%"%s, %s, %s, %d, nper=%d")', $
			"    bt->gather_partial", $
			"'"+target_type+"'", "'"+target_run+"'", job, nper)

		if keyword_set(fpobjc) then begin
			target_command += ", /fpobjc"
			gather_command += ", /fpobjc"
		endif
		if n_elements(match_method) ne 0 then begin
			target_command += ", match_method='"+match_method+"'"
			gather_command += ", match_method='"+match_method+"'"
		endif 

		;if keyword_set(commissioning) then begin
		;	target_command += ", /commissioning"
		;	gather_command += ", /commissioning"
		;endif else if keyword_set(comm2) then begin
		;	target_command += ", /comm2"
		;endif

		if keyword_set(commissioning) then begin
			idl_commands = "bt=obj_new('bosstarget',/commissioning)"
		endif else if keyword_set(comm2) then begin
			idl_commands = "bt=obj_new('bosstarget',/comm2)"
		endif else begin
			idl_commands = "bt=obj_new('bosstarget')"
		endelse


		if n_elements(runs) ne 0 then begin
			idl_commands = [idl_commands, "runs="+runstring]
		endif


		if keyword_set(reselect) then begin
			gather_command += ", /reselect"
		endif
		if keyword_set(noverify) then begin
			gather_command += ", /noverify"
		endif

		if n_elements(where_string) ne 0 then begin
			idl_commands=[idl_commands, "where_string='"+where_string+"'"]
			gather_command += ", where_string=where_string"
		endif
		if n_elements(add_where_string) ne 0 then begin
			idl_commands=[idl_commands, "add_where_string='"+add_where_string+"'"]
			gather_command += ", add_where_string=add_where_string"
		endif


		if n_elements(pars) ne 0 then begin
			idl_commands=[idl_commands, 'pars='+tostring(pars)]
			target_command += ", pars=pars"
			; turn this off for std since was *adding* boss_target1 in
			; really dumb

			; if we are doing target with pars there is not need to
			; also do it in gather.  Can save lots of time
			if not keyword_set(dotarget) then begin
				gather_command += ", pars=pars"
			endif
		endif 
		if n_elements(extra_name) ne 0 then begin
			;gather_command += ", pars=pars, extra_name='"+extra_name+"'"
			gather_command += ", extra_name='"+extra_name+"'"
		endif
			
		if n_elements(runs) ne 0 then begin
			target_command += ', runs=runs'
			gather_command += ', runs=runs'
		endif

		if keyword_set(dotarget) then begin
			idl_commands=[idl_commands,target_command]
		endif
		if keyword_set(dogather) then begin
			idl_commands=[idl_commands,gather_command]
		endif

		job_name = target_type+"-"+jobstr

		pbs_riemann_idl, pbs_file, idl_commands, $
			setup=setups, job_name=job_name, $
			walltime=walltime, $
            queue=queue
	endfor
end







pro bosstarget_pbs__define
	struct = {$
		bosstarget_pbs, $
		dummy_var:0 $
	}
end
