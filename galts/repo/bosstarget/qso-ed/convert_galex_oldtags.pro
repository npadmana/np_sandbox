PRO CONVERT_GALEX_OLDTAGS, galexfile, outfile
galex= mrdfits(galexfile,1)
new= {fuv_flux:0D,nuv_flux:0D,$
      fuv_invar:0D,nuv_invar:0D,$
      fuv_formal_invar:0D,$
      nuv_formal_invar:0D}
new= replicate(new,n_elements(galex.fuv))
new.fuv_flux= galex.fuv
new.nuv_flux= galex.nuv
new.fuv_invar= galex.fuv_ivar
new.nuv_invar= galex.nuv_ivar
new.fuv_formal_invar= galex.fuv_formal_ivar
new.nuv_formal_invar= galex.nuv_formal_ivar
mwrfits, new, outfile, /create
END
