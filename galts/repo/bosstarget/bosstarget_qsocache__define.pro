function bosstarget_qsocache::init, pars=pars, _extra=_extra
	; these are inherited from bosstarget_qsopars
	self->set_default_pars
	self->copy_extra_pars, pars=pars, _extra=_extra
	return, 1
end



;object must have ->pars() and ->cache_generate and ->cache_combine
pro bosstarget_qsocache::match, type, object, objs, mobjs, mcache, cache=cache

	bu=obj_new('bosstarget_util')
	bu->get_unique_run_rerun_camcol, objs.run, objs.rerun, objs.camcol, $
		urun, urerun, ucamcol

	if n_elements(urun) eq 1 then begin
		if not self->exists(type,urun,urerun,ucamcol) then begin
			object->cache_generate, objs
			;print,'Generate the cache: returning cache=-1'
			;cache = -1
			;return
		endif

		cache = self->read(type,urun,urerun,ucamcol)
	endif else begin
		if not self->exists(type,urun,urerun,ucamcol,/combined) then begin
			object->cache_combine
			;print,'Generate the cache. Returning cache=-1'
			;cache = -1
			;return
		endif

		cache = self->read(type,/combined)
	endelse

	oid = sdss_photoid(objs)
	cid = sdss_photoid(cache)

	match, oid, cid, mobjs, mcache, /sort

	obj_destroy, bu
end





pro bosstarget_qsocache::write, type, struct, run, rerun, camcol, $
		combined=combined
	file=self->file(type,run,rerun,camcol,combined=combined)
	n=n_elements(struct)
	splog,'Creating ',n,' to cached ',type,' file: ',file, $
		form='(a,i0,a,a,a,a)'
	mwrfits, struct, file, /create
	;mwrfits2, struct, file, /create,/destroy
end

function bosstarget_qsocache::exists, type, run, rerun, camcol, $
		combined=combined

	file=self->file(type,run,rerun,camcol,combined=combined)
	if not file_test(file) then begin
		return, 0
	endif else begin
		return, 1
	endelse
end

function bosstarget_qsocache::read, type, run, rerun, camcol, $
		combined=combined
	file=self->file(type,run,rerun,camcol,combined=combined)
	if not file_test(file) then begin
		if keyword_set(combined) then begin
			message,"You haven't made the combined "+type+" file: "+file
		endif else begin
			message,'cached file not found: '+file
		endelse
	endif
	splog,'Reading cached '+type+' file: '+file
	return, mrdfits(file,1)
end



function bosstarget_qsocache::file, type, run, rerun, camcol, $
		combined=combined

	front=self->frontname(type)
	if keyword_set(combined) then begin
		file=front+'-combined.fits'
	endif else begin
		file = string(front,'-',run,'-',camcol,'-',rerun,'.fits',$
				      f='(a,a,i06,a,i0,a,i0,a)')
	endelse
	dir=self->dir()
	file=filepath(root=dir,file)
	return, file
end
function bosstarget_qsocache::frontname, type
	if not in(['kde','like','like2','chi2'],type) then begin
		message,'unknown cache type '+type
	endif
	return, 'qso'+type
end
function bosstarget_qsocache::dir
	dir=getenv('BOSS_TARGET')
	if dir eq '' then message,'BOSS_TARGET is not set'

	dir=filepath(root=dir, 'qso-cache')

	photo_sweep=file_basename(getenv('PHOTO_SWEEP'))
	dir = filepath(root=dir, photo_sweep)

	pars = self->pars()
	if pars.nocalib then begin
		dir = dir+'-nocalib'
	endif
	if pars.multi_epoch_available then begin
		dir = dir+'-me'
	endif

	bu = obj_new('bosstarget_util')
	bounds = pars.bounds
	if pars.bounds ne 'boss' then begin
		bounds = strjoin(bu->split_by_semicolon(bounds),'-')
		dir = dir + '-'+bounds
	endif

	if not file_test(dir) then begin
		file_mkdir, dir
	endif
	return,dir
end





pro bosstarget_qsocache__define
	struct = {$
		bosstarget_qsocache, $
		inherits bosstarget_qsopars $
	}
end


