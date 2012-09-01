function bosstarget_qsopars::init
	return, 1
end

function bosstarget_qsopars::pars
	return, self.pars
end

pro bosstarget_qsopars::set_default_pars
	pars = bosstarget_qso_default_pars()
	self.pars = pars
end

pro bosstarget_qsopars::copy_extra_pars, pars=pars, _extra=_extra

	if n_tags(_extra) ne 0 then begin
		tmp = self.pars
		struct_assign, _extra, tmp, /nozero
		self.pars = tmp
	endif

	; takes precedence over _extra
	if n_tags(pars) ne 0 then begin
		tmp=self.pars
		struct_assign, pars, tmp, /nozero
		self.pars=tmp
	endif

end

pro bosstarget_qsopars__define

	; Note the numbers in here will not be set, it will just define
	; that sub-structure which we fill in later.

	parstruct = bosstarget_qso_default_pars()
	struct = {$
		bosstarget_qsopars, $
		pars: parstruct $
	}

end


