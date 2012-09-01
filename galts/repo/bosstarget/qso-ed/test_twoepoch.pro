PRO TEST_TWOEPOCH, plotfile, xdsave=xdsave, varsave=varsave, gri=gri, justgalex=justgalex
;;first calculate XD
if ~file_test(xdsave) then begin
    print, "Running XDQSO on all objects ..."
    data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
    in= mrdfits('$BOVYQSOEDDATA/two-epoch-cat.fits.gz',1)
    spherematch, data.ra, data.dec, in.ra, in.dec, 2./3600., $
      dindx, iindx
    data= data[dindx]
    in= in[iindx]
    xtras= {extinction:dblarr(5),$
           psfflux:dblarr(5),$
           psfflux_ivar:dblarr(5)}
    xtra= replicate(xtras,n_elements(in.modelflux1[0]))
    ;;co-add the fluxes
    ;xtra.psfflux_ivar= data.psfflux_ivar
    ;xtra.psfflux= data.psfflux
    xtra.psfflux_ivar= in.modelflux_ivar1+in.modelflux_ivar2
    xtra.psfflux= in.modelflux1*in.modelflux_ivar1+in.modelflux2*in.modelflux_ivar2
    xtra.psfflux/= xtra.psfflux_ivar
    xtra.extinction= data.extinction
    in= struct_combine(in,xtra)
    xd= qsoed_calculate_prob(in,/nocuts,/multi,/zfour)
    if keyword_set(xdsave) then mwrfits, xd, xdsave, /create
endif else begin
    xd= mrdfits(xdsave,1)
endelse
;;then get the variability likelihood
if ~file_test(varsave) then begin
    print, "Running variability on all objects ..."
    data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
    in= mrdfits('$BOVYQSOEDDATA/two-epoch-cat.fits.gz',1)
    spherematch, data.ra, data.dec, in.ra, in.dec, 2./3600., $
      dindx, iindx
    data= data[dindx]
    in= in[iindx]
    xtras= {extinction:dblarr(5),$
           psfflux:dblarr(5),$
           psfflux_ivar:dblarr(5)}
    xtra= replicate(xtras,n_elements(in.modelflux1[0]))
    ;;co-add the fluxes
    xtra.psfflux_ivar= in.modelflux_ivar1+in.modelflux_ivar2
    xtra.psfflux= in.modelflux1*in.modelflux_ivar1+in.modelflux2*in.modelflux_ivar2
    xtra.psfflux/= xtra.psfflux_ivar
    xtra.extinction= data.extinction
    in= struct_combine(in,xtra)
    var= twoepoch_varlike(in,gri=gri)
    if keyword_set(varsave) then mwrfits, var, varsave, /create
endif else begin
    var= mrdfits(varsave,1)
endelse

;;put likelihoods together
;;Calculate the probability that a target is a high-redshift QSO
pqso= (xd.bossqsolike*xd.bossqsonumber*exp(var.qsologlike-var.starloglike))
nonzero= where(pqso NE 0.,cnt)
IF cnt GT 1 THEN pqso[nonzero]= pqso[nonzero]/(xd[nonzero].qsolike*xd[nonzero].qsonumber*exp(var[nonzero].qsologlike-var[nonzero].starloglike)+$
                                               xd[nonzero].qsolowzlike*xd[nonzero].qsolowznumber*exp(var[nonzero].qsologlike-var[nonzero].starloglike)+$
                                               xd[nonzero].everythinglike*xd[nonzero].everythingnumber+$
                                               pqso[nonzero])

;;plot as a function of target density
data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
in= mrdfits('$BOVYQSOEDDATA/two-epoch-cat.fits.gz',1)
spherematch, data.ra, data.dec, in.ra, in.dec, 2./3600., $
  dindx, iindx
data= data[dindx]
in= in[iindx]
;also get ukidss+galex
if keyword_set(justgalex) then aux= mrdfits('chunk11_extreme_deconv_galex_ugriz.fits',1) $
  else aux= mrdfits('chunk11_extreme_deconv_galex_ukidss_ugriz.fits',1)
aux= aux[dindx]
auxpqso= (aux.bossqsolike*aux.bossqsonumber*exp(var.qsologlike-var.starloglike))
nonzero= where(auxpqso NE 0.,cnt)
IF cnt GT 1 THEN auxpqso[nonzero]= auxpqso[nonzero]/(aux[nonzero].qsolike*aux[nonzero].qsonumber*exp(var[nonzero].qsologlike-var[nonzero].starloglike)+$
                                                     aux[nonzero].qsolowzlike*aux[nonzero].qsolowznumber*exp(var[nonzero].qsologlike-var[nonzero].starloglike)+$
                                                     aux[nonzero].everythinglike*aux[nonzero].everythingnumber+$
                                                     auxpqso[nonzero])
;data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
;in= mrdfits('$BOVYQSOEDDATA/two-epoch-cat.fits.gz',1)
;spherematch, data.ra, data.dec, in.ra, in.dec, 2./3600., $
;  dindx, iindx
;print, n_elements(in.ra), n_elements(iindx)
;data= data[dindx]
;xd= xd[iindx]
;pqso= pqso[iindx]
specarea_one= 148.75
area_one= specarea_one
xdsort= reverse(sort(xd.pqso))
varsort= reverse(sort(pqso))
auxsort= reverse(sort(aux.pqso))
auxvarsort= reverse(sort(auxpqso))
xs= dindgen(1001)/1000.*40.
nxs= n_elements(xs)
ysxd= dblarr(nxs)
ysvar= dblarr(nxs)
ysaux= dblarr(nxs)
ysauxvar= dblarr(nxs)
for ii=0L, nxs -1 do begin
    targetindx= xdsort[0:floor(xs[ii]*area_one)]
    ysxd[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
    targetindx= varsort[0:floor(xs[ii]*area_one)]
    ysvar[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
    targetindx= auxsort[0:floor(xs[ii]*area_one)]
    ysaux[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
    targetindx= auxvarsort[0:floor(xs[ii]*area_one)]
    ysauxvar[ii]= n_elements(where(data[targetindx].zem GE 2.2))/specarea_one
endfor
if keyword_set(justgalex) then begin
    title= 'red: +variability; dashed: ugriz; solid:+GALEX'
endif else begin
    title= 'red: +variability; dashed: ugriz; solid:+UKIDSS+GALEX'
endelse
k_print, filename=plotfile
djs_plot, xs, ysauxvar, xtitle='# targets [deg^{-2}]', $
  ytitle='# z > 2.2 quasars [deg^{-2}]', color='red', $
  yrange=[0.,max([ysauxvar,ysaux,ysxd,ysvar])*1.1], $
  title=title
djs_oplot, xs, ysaux, linestyle=0, color='blue'
djs_oplot, xs, ysxd, linestyle=2, color='blue'
djs_oplot, xs, ysvar, linestyle=2, color='red'
k_end_print
END
