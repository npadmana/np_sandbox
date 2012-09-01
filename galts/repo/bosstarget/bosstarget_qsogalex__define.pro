function bosstarget_qsogalex::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsogalex::match_byrow, str
    ; DS new files are row matched
    splog,'Matching galex'

    ; get associated files
    flist = self->file(str.run, str.camcol)

    nuniq = n_elements( rem_dup(flist) )
    if nuniq ne 1 then begin
        message,'Found multiple run/camcols in file',/inf
        message,'The new galex files have no id info, so you must enter a list that exactly matches a sweep file'
    endif

    file=flist[0]

    print,'Reading galex matched file:',file
    t=mrdfits(file,1,/silent)
    if n_tags(t) eq 0 then message,'Error reading '+file+', Halting'

    if n_elements(t) ne n_elements(str) then begin
        message,'Input sweep struct has different length than galex matched file',/inf
        message,'  ',n_elements(str),' vs ',n_elements(t),/inf
        message,'halting'
    endif

    newst=create_struct(t[0], {run:0, rerun:'', camcol:0, field:0, id:0L})
    newst = replicate(newst, n_elements(t))
    struct_assign, t, newst, /nozero
    newst.run    = str.run
    newst.rerun  = str.rerun
    newst.camcol = str.camcol
    newst.field  = str.field
    newst.id     = str.id

    return, newst

end



function bosstarget_qsogalex::match_byid, str
    ; obsolete since new files have no id info
    splog,'Matching galex'

    cid = sdss_photoid(str.run, str.rerun, str.camcol)
    uid = rem_dup(cid)
    ucid = cid[uid]
    nu = n_elements(ucid)

    ; get associated files
    flist = self->file(str[uid].run, str[uid].rerun, str[uid].camcol)

    nf=n_elements(flist)
    good = intarr(nf)
    for i=0L, nf-1 do begin
        if file_test(flist[i]) then begin
            good[i] = 1
        endif
    endfor

    wgood=where(good eq 1, ngood)
    if ngood eq 0 then begin
        splog,'No files match input.'
        return, 0
    endif

    splog,'Found ',ngood,' matching files',format='(a,i0,a)'

    flist = flist[wgood]

    if ngood lt 10 then begin
        for i=0L, ngood-1 do print,flist[i]
    endif

    t=mrdfits_multi(flist,/silent)
    if n_tags(t) eq 0 then message,'Error reading flist, Halting'

    sphoto_match, str, t, mstr, mt

    if mt[0] ne -1 then begin
        splog,'    Found ',n_elements(mt),' matching objects',format='(a,i0,a)'
        t = t[mt]
    endif else begin
        splog,'    Found no matching objects'
        t=0
    endelse

    return, t

end

;+
; Name:
;   split_galex_bycamcol
; Purpose:
;   Split up the chunk files from Adam/David Schiminovich by 
;   run/camcol. Append existing files.  Don't run this in 
;   parallel because of the appending
;
;   Note this requires all of sdssidl to run.
;-
pro bosstarget_qsogalex::split_bycamcol

    outdir=self->dir()
    if not file_test(outdir) then begin
        print,'making output dir: ',outdir
        file_mkdir, outdir
    endif
    self->orig_files, calibobj_files, match_files
    for fi=0L, n_elements(calibobj_files)-1 do begin
        calibobj_file=calibobj_files[fi]
        match_file=match_files[fi]

        print,'reading: ',calibobj_file
        calib=mrdfits(calibobj_file, 1)
        print,'reading: ',match_file
        matches=mrdfits(match_file,1)

        st = {run:              0,   $
              rerun:            0,   $
              camcol:           0,   $
              field:            0,   $
              id:               0L,  $
              thing_id:         0L,  $
              ra:               0d,  $
              dec:              0d,  $
              fuv:              0.0, $
              fuv_ivar:         0.0, $
              fuv_formal_ivar:  0.0, $
              nuv:              0.0, $
              nuv_ivar:         0.0, $
              nuv_formal_ivar:  0.0}


        cid = sdss_photoid(calib.run, calib.rerun, calib.camcol)

        ucid = cid[rem_dup(cid)]

        nu = n_elements(ucid)
        for j=0L, nu-1 do begin
            w=where(cid eq ucid[j], nw)

            tmp = replicate(st, nw)
            ; this will assign the ids, ra,dec
            struct_assign, calib[w], tmp, /nozero
            ; the galex info
            if tag_exist(matches, 'fuv_formal_invar') then begin
                tmp.fuv = matches[w].fuv_flux
                tmp.fuv_ivar = matches[w].fuv_invar
                tmp.fuv_formal_ivar = matches[w].fuv_formal_invar

                tmp.nuv = matches[w].nuv_flux
                tmp.nuv_ivar = matches[w].nuv_invar
                tmp.nuv_formal_ivar = matches[w].nuv_formal_invar
            endif else if tag_exist(matches, 'nuv_formal_ivar') then begin
                struct_assign, matches[w], tmp, /nozero
            endif else begin
                message,'need either old or new style tags'
            endelse

            outfile = self->file(tmp[0].run,tmp[0].rerun,tmp[0].camcol,/idlstruct)
            if file_test(outfile) then begin
                print,'Appending to: ',outfile
            endif else begin
                print,outfile
            endelse
            write_idlstruct, tmp, outfile, /append
        endfor
    endfor

end

pro bosstarget_qsogalex::remove_dups
    dir=self->dir()
    pattern = path_join(dir,'*.st')
    flist = file_search(pattern)

    for i=0L, n_elements(flist)-1 do begin
        t=read_idlstruct(flist[i],/silent)
        id=sdss_photoid(t)
        rmd=rem_dup(id)
        nrmd = n_elements(rmd) 
        nt=n_elements(t)
        if nrmd ne nt  then begin
            ndup = n_elements(t)-n_elements(rmd)
            print,f='("removing dups from: ",a)',flist[i]
            print,ndup,nt
            command='mv '+flist[i]+' '+flist[i]+'.bak'
            print,command
            spawn,command
            t = t[rmd]
            write_idlstruct, t, flist[i], append=0
        endif
    endfor
end


pro bosstarget_qsogalex::tofits
    dir=self->dir()
    pattern = path_join(dir,'*.st')
    flist = file_search(pattern)
    fitslist = repstr(flist, '.st', '.fits')

    idlstruct2fits, flist, fitslist
end

function bosstarget_qsogalex::read, run, rerun, camcol
    file=self->file(run,rerun,camcol)
    print,'Reading galex camcol file: ',file
    return,mrdfits(file,1,/silent)
end

function bosstarget_qsogalex::file, run, camcol

    dir=self->dir()
    file = 'aper_calibObj-'+string(run,f='(i06)')+'-'+string(camcol,f='(i0)')+'-star.fits.gz'
    file = filepath(root=dir, file)
    return, file
end

function bosstarget_qsogalex::dir
    dir = getenv('BOSS_TARGET')
    if dir eq '' then message,'BOSS_TARGET is not set'
    dir = path_join(dir,'galex/bycamcol')
    return, dir
end

pro bosstarget_qsogalex::orig_files, calibobj_files, match_files
    dir=self->orig_dir()
    calibobj_files = ['calibObj-all-star-ra-90to270-dec-6to10-trim4ir.fits.gz',$
                      'calibObj-star-june2october-2011-trim4uv.fits']
    match_files    = ['match_out_star_aper.fits', $
                      'match_out_jun2october_2011_star_aper.fits']
    calibobj_files = filepath(root=dir, calibobj_files)
    match_files = filepath(root=dir, match_files)
end


function bosstarget_qsogalex::orig_dir
    dir = getenv('BOSS_TARGET')
    if dir eq '' then message,'BOSS_TARGET is not set'
    dir = path_join(dir,'galex/matches')
    return, dir
end



pro bosstarget_qsogalex__define
	struct = {$
		bosstarget_qsogalex, $
		inherits bosstarget_qsopars $
	}
end


