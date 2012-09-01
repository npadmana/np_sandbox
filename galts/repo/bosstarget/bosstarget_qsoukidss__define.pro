;
;   to prepare the ukids data:
;   first clear the data in $BOSS_TARGET/ukidss/bycamcol 
;   then run
;
;       ::run_split_bycamcol
;
;   which will process all the ukidss directories and append data
;   to the files by camera column.
;
;   then run 
;       ::remove_dups to get rid of the duplicate entries
;   in the file
; 
function bosstarget_qsoukidss::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end

function bosstarget_qsoukidss::match, str

    splog,'Matching ukidss'

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
;   bosstarget_qsoukidss::split_bycamcol
; Purpose:
;   Split up the chunk files from Richard by run/camcol.  Append
;   existing files.  Don't run this in parallel because of the
;   appending
;
;   Note this requires all of sdssidl to run.
;-

; this one is just for the new sgc run.  Should be
; no dups.  When we get everything sorted out we
; won't have to restrict to sgc
pro bosstarget_qsoukidss::split_sgc_bycamcol
    bdir=self->basedir()
    dirs = 'sgc/20110408/v21/join'
    for i=0, n_elements(dirs)-1 do begin
        d = path_join(bdir, dirs[i])
        self->split_bycamcol, d
    endfor
end

pro bosstarget_qsoukidss::run_split_bycamcol
    bdir=self->basedir()
    ;dirs = ['stripe82_varcat/v1/join/', $
    dirs = ['ngp/20101231/v1/join/', $
            'ngp/20110123/v2/join/', $
            'ngp/20110310/v2/join/', $
            'ngp/20110814/concat/join/v2']
            ;'sgc/20110408/v21/join']
    for i=0, n_elements(dirs)-1 do begin
        d = path_join(bdir, dirs[i])
        self->split_bycamcol, d
    endfor
end

function bosstarget_qsoukidss::get_close_radec, data, ngood
    ; this is to deal with the error where
    ; ukidss data are assigned to the wrong
    ; SDSS association.  the ra,dec of k-band
    ; (or others) does not match the sdss ra
    ; dec

    maxrad = 2d/3600d
    mygcirc, data.ra, data.dec, data.ra_list_k, data.dec_list_k, dis

    wgood = where(dis le maxrad, ngood)

    return, wgood
end
pro bosstarget_qsoukidss::split_bycamcol, dir
    outdir=self->dir()
    if not file_test(outdir) then begin
        file_mkdir, outdir
    endif
    pattern = path_join(dir, '*.fits')
    files = file_search(pattern)

    st = {run:0,rerun:0,camcol:0,field:0,id:0L, $
          thing_id: 0L, $
          ra:0d, dec:0d, $
          ra_list_k:0d, $
          dec_list_k:0d, $
          apercsiflux3_y:0.0, $
          apercsiflux3err_y: 0.0, $
          apercsiflux3_j:0.0, $
          apercsiflux3err_j: 0.0, $
          apercsiflux3_h:0.0, $
          apercsiflux3err_h: 0.0, $
          apercsiflux3_k:0.0, $
          apercsiflux3err_k: 0.0}

    for i=0L, n_elements(files)-1 do begin
        print,'Reading: ',files[i]
        t=mrdfits(files[i], 1)
        ntot=n_elements(t)

        notnan=where(t.ra_list_k eq t.ra_list_k $
                     and t.apercsiflux3_k eq t.apercsiflux3_k, n_notnan)

        print,f='("not NaN: ",i0,"/",i0)',n_notnan,ntot
        if n_notnan ne 0 then begin
            t=t[notnan]

            wgood_radec = self->get_close_radec(t, ngood_radec)
            print,f='("good radec: ",i0,"/",i0)',ngood_radec,ntot
            if ngood_radec ne 0 then begin
                t=t[wgood_radec]

                cid = sdss_photoid(t.run, t.rerun, t.camcol)

                ucid = cid[rem_dup(cid)]

                nu = n_elements(ucid)
                for j=0L, nu-1 do begin
                    w=where(cid eq ucid[j], nw)

                    tmp = replicate(st, nw)
                    ;struct_assign, t[w], tmp, /nozero
                    tmp.run    = t[w].run
                    tmp.rerun  = t[w].rerun
                    tmp.camcol = t[w].camcol
                    tmp.field  = t[w].field
                    tmp.id     = t[w].id

                    tmp.thing_id = t[w].thing_id

                    tmp.ra = t[w].ra
                    tmp.dec = t[w].dec

                    tmp.apercsiflux3_y = t[w].apercsiflux3_y 
                    tmp.apercsiflux3err_y = t[w].apercsiflux3err_y 

                    tmp.apercsiflux3_j = t[w].apercsiflux3_j 
                    tmp.apercsiflux3err_j = t[w].apercsiflux3err_j 

                    tmp.apercsiflux3_h = t[w].apercsiflux3_h 
                    tmp.apercsiflux3err_h = t[w].apercsiflux3err_h 

                    tmp.apercsiflux3_k = t[w].apercsiflux3_k 
                    tmp.apercsiflux3err_k = t[w].apercsiflux3err_k 

                    tmp.ra_list_k = t[w].ra_list_k
                    tmp.dec_list_k = t[w].dec_list_k


                    outfile = self->file(tmp[0].run,tmp[0].rerun,tmp[0].camcol,/idlstruct)
                    if file_test(outfile) then begin
                        print,'Appending to: ',outfile
                    endif else begin
                        print,outfile
                    endelse
                    write_idlstruct, tmp, outfile, /append
                endfor
            endif ;good ra/dec
        endif ; not NaN
        print,'-------------------------------------------------'
    endfor

    print,'DONT FORGET TO CHECK FOR DUPS'
    ;print,'DONT FORGET TO VERIFY UNIQUE using verify_bythingid'
    ;print,'DONT FORGET TO CONVERT TO FITS!'
end

pro bosstarget_qsoukidss::remove_dups_bythingid, dryrun=dryrun
    ; DONT use if sgc/varcat is included unless you know youve
    ; dealt with dups
    dir=self->dir()
    pattern = path_join(dir,'*.st')
    flist = file_search(pattern)

    spawn,'mkdir -p '+dir+'/dups'
    for i=0L, n_elements(flist)-1 do begin
        ;print,'Reading ',flist[i]
        t=read_idlstruct(flist[i],/silent)

        ntot=n_elements(t)

        if ntot gt 1 then begin
        
            ; saw strange stuff on old files, unique
            ; in thing_id less than unique in photoid...
            rmd = rem_dup(t.thing_id)
            nuniq = n_elements(rmd)

            pid=sdss_photoid(t)
            rmd_pid = rem_dup(pid)
            nuniq_pid = n_elements(rmd_pid)
            if nuniq ne nuniq_pid then begin
                message,string(f='("NUNIQ FROM THING_ID AND PID DONT MATCH: ",i0,"/",i0)',nuniq,nuniq_pid)
            endif

            if nuniq ne ntot then begin

                message,string(f='("unique is ",i0,"/",i0," from: ",a)',nuniq,ntot,flist[i]),/inf

                t = t[rmd]

                basename=file_basename(flist[i])
                newname = path_join(dir+'/dups', basename)
                command='mv '+flist[i]+' '+newname
                print,command

                if not keyword_set(dryrun) then begin
                    spawn,command

                    write_idlstruct, t, flist[i], append=0
                endif
            endif ; dups found
        endif ;ntot > 1

    endfor
end


pro bosstarget_qsoukidss::tofits
    dir=self->dir()
    pattern = path_join(dir,'*.st')
    flist = file_search(pattern)
    fitslist = repstr(flist, '.st', '.fits')

    idlstruct2fits, flist, fitslist
end
function bosstarget_qsoukidss::read, run, rerun, camcol
    file=self->file(run,rerun,camcol)
    print,'Reading ukidss camcol file: ',file
    return,mrdfits(file,1,/silent)
end

function bosstarget_qsoukidss::file, run, rerun, camcol, idlstruct=idlstruct

    dir=self->dir()
    if keyword_set(idlstruct) then ext='.st' else ext='.fits'
    file = 'ukidss-'+string(run,f='(i06)')+'-'+string(rerun,f='(i0)')+'-'+string(camcol,f='(i0)')+ext
    file = filepath(root=dir, file)
    return, file
end

function bosstarget_qsoukidss::dir
    dir=self->basedir()
    dir = path_join(dir,'bycamcol')
    return, dir
end
function bosstarget_qsoukidss::basedir
    dir = getenv('BOSS_TARGET')
    if dir eq '' then message,'BOSS_TARGET is not set'
    dir = path_join(dir,'ukidss')
    return, dir
end


function bosstarget_qsoukidss::match_old, objs, pars=pars, _extra=_extra, ukidss_id=ukidss_id

	if n_elements(objs) eq 0 then begin
		on_error, 2
		splog,'Usage: boss_target1=bukidss->ukidss_match(objs,ukidss_id=, pars=, _extra=)'
		message,'Halting'
	endif

	self->copy_extra_pars, pars=pars, _extra=_extra

	common ukidss_catalog_block, ukidss
	self->cache

	nobjs=n_elements(objs)
	boss_target1=lon64arr(nobjs)
	ukidss_id=replicate(-9999L, nobjs)
	flagval=sdss_flagval('boss_target1','qso_ukidss')

	; the initial ukidss match was 0.7", let's do 1"
	matchrad = 1d/3600d ; degrees

	spherematch, $
		objs.ra, objs.dec, $
		ukidss.ra, ukidss.dec, matchrad, $
		objs_match, ukidss_match, distances,$
		maxmatch=1

	nmatch=0
	if objs_match[0] ne -1 then begin
		nmatch=n_elements(objs_match)
		ukidss_id[objs_match] = ukidss_match
		boss_target1[objs_match] += flagval
	endif


	print
	splog,'Found ',nmatch,' UKIDSS matches',format='(a,i0,a)'
	print
	

	return, boss_target1


end


function bosstarget_qsoukidss::read_old, reload=reload
	common ukidss_catalog_block, ukidss
	self->cache, reload=reload
	return, ukidss
end

pro bosstarget_qsoukidss::cache_old, reload=reload
	common ukidss_catalog_block, ukidss

	if n_elements(ukidss) eq 0 or keyword_set(reload) then begin
		f=self->file()
		splog,'Reading: ',f,form='(a,a)'
		ukidss=mrdfits(f,1,status=status)
		if status ne 0 then message,'could not read ukidss file'

		;exclude objects with u-g<0.4
		;(ii) exclude K > 17.0 [ish]
		;(ii) exclude psfmag_i < 17.0
		;(iv) exclude known redshifts; z<2.0

		umg=ukidss.psfmag_u - ukidss.psfmag_g

		keep=where( $
			(umg gt 0.4) $
			and (ukidss.kapermag3 lt 17) $
			and (ukidss.psfmag_i gt 17), nkeep)

		ukidss = ukidss[keep]
		splog,'Cutting ukidss cat to: ',n_elements(ukidss),' objects',$
			form='(a,i0,a)'


	endif
end

function bosstarget_qsoukidss::file_old
	dir=getenv('BOSSTARGET_DIR')
	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	dir = filepath(root=dir, 'data')

	;filename='ukidss_dr5_stripe82_klt18_kstars.fits.gz'
	filename='giKcut_s82_14-18_ukidsscuts_stellarcut.fits'
	filename=filepath(root=dir, filename)
	return, filename
end





pro bosstarget_qsoukidss__define
	struct = {$
		bosstarget_qsoukidss, $
		inherits bosstarget_qsopars $
	}
end


