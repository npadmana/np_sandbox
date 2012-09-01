
function bosstarget_qso_core::init, pars=pars, _extra=_extra
	return, 1
end


function bosstarget_qso_core::match, objs, qsoed_prob_core=qsoed_prob_core

    common bosstarget_qso_core_final_block, core_final, core_photoid
    if n_elements(core_final) eq 0 then begin
        core_final = self->read(/min)
        core_photoid = sdss_photoid(core_final)
    endif

    boss_target1 = lon64arr(n_elements(objs))

    pid = sdss_photoid(objs)
    match, pid, core_photoid, mobjs, mcore, /sort

    if mobjs[0] ne -1 then begin
	    coreflag = sdss_flagval('boss_target1','qso_core_main')
        boss_target1[mobjs] += coreflag

        qsoed_prob_core = replicate(-9999d, n_elements(objs))
        qsoed_prob_core[mobjs] = core_final[mcore].qsoed_prob_core
    endif

    return, boss_target1

end

pro bosstarget_qso_core::create
    outfile = self->file()
    outfile_min = self->file(/min)

    run = 'main008'
    extra='edfinal'
    ; core+bonus tuned to 40
    ngc_extra = extra+'-maskngc40'
    sgc_extra = extra+'-sgc40'

    bt=obj_new('bosstarget')
    ngc = bt->read_collated('qso',run,extra=ngc_extra, status=ngc_status)
    sgc = bt->read_collated('qso',run,extra=sgc_extra, status=sgc_status)

    combined = struct_concat(ngc, sgc)


	coreflag = sdss_flagval('boss_target1','qso_core_main')
    w=where( (combined.boss_target1 and coreflag) ne 0,ncore)
    print,f='("found: ",i0,"/",i0," were core")',ncore,n_elements(combined)
    combined = combined[w]

    minst = {run:0,rerun:0,camcol:0,field:0,id:0, qsoed_prob_core:0d}
    combined_min = replicate(minst, ncore)
    copy_struct, combined, combined_min
    help,combined_min,/str

    print,'Writing to: ',outfile
    mwrfits, ngc_status, outfile, /create
    mwrfits, combined, outfile

    print,'Writing to: ',outfile_min
    mwrfits, ngc_status, outfile_min, /create
    mwrfits, combined_min, outfile_min

end

function bosstarget_qso_core::read, min=min, status_struct=status_struct
    fname = self->file(min=min)
    splog,'Reading qso core final file: ',fname,format='(a,a)'
    if arg_present(status_struct) then begin
        status_struct = mrdfits(fname, 1)
    endif
    return, mrdfits(fname, 2)
end

function bosstarget_qso_core::file, min=min
    dir = self->dir()
    if keyword_set(min) then begin
        fname='bosstarget-qso-core-final-min.fits'
    endif else begin
        fname='bosstarget-qso-core-final.fits'
    endelse
    fname = filepath(root=dir,fname)
    return, fname
end
function bosstarget_qso_core::dir
    btdir=getenv('BOSS_TARGET')
    if btdir eq '' then begin
        message,'BOSS_TARGET is not set'
    endif
    dir = filepath(root=btdir, 'qso-core-final')
    return, dir
end


pro bosstarget_qso_core__define
	struct = {$
		bosstarget_qso_core, $
        dummy: '' $
	}
end


