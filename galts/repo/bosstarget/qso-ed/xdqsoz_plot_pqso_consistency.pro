;+
;
;-
PRO XDQSOZ_PLOT_PQSO_CONSISTENCY, plotfile

specarea_one= 205.12825
area_one= specarea_one
dataone= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
xdqso= mrdfits('chunk11_extreme_deconv_z4.fits',1)
xdqsoz= mrdfits('chunk11_xdqsoz_z4.fits',1)

threshold= 40

sortindx_one= REVERSE(SORT(xdqso.pqso))
sortindx_two= REVERSE(SORT(xdqsoz.pqso))

targetindx_one= sortindx_one[0:floor(threshold*area_one)]
targetindx_two= sortindx_two[0:floor(threshold*area_one)]

ptres_one= xdqso[targetindx_one[n_elements(targetindx_one)-1]].pqso
ptres_two= xdqsoz[targetindx_two[n_elements(targetindx_two)-1]].pqso

ptres= min([ptres_one,ptres_two])

IF ptres EQ ptres_one THEN BEGIN
    targetindx_two= sortindx_two
ENDIF ELSE BEGIN
    targetindx_one= sortindx_one
ENDELSE

bins= 10
pbins= dindgen(bins+1)/bins*(1.-ptres)+ptres
frac_one= dblarr(bins)
frac_two= dblarr(bins)

FOR ii=0L, bins-1 DO BEGIN
    indx= where(xdqso[targetindx_one].pqso GT pbins[ii] AND $
                xdqso[targetindx_one].pqso LE pbins[ii+1])
    frac_one[ii]= double(n_elements(where(dataone[targetindx_one[indx]].zem GE 2.2 AND $
                                          dataone[targetindx_one[indx]].zem LE 4.)))/$
      n_elements(indx)/specarea_one*area_one
    indx= where(xdqsoz[targetindx_two].pqso GT pbins[ii] AND $
                xdqsoz[targetindx_two].pqso LE pbins[ii+1])
    frac_two[ii]= double(n_elements(where(dataone[targetindx_two[indx]].zem GE 2.2 AND $
                                          dataone[targetindx_two[indx]].zem LE 4.)))/$
      n_elements(indx)/specarea_one*area_one
ENDFOR


plotpbins= dblarr(bins)
FOR ii=0L, bins-1 DO plotpbins[ii]= (pbins[ii]+pbins[ii+1])/2.
plotpbins[bins-1]= 1.
k_print, filename=plotfile
djs_plot, [0.1,1.], [0.1,1.],xtitle='P(quasar)',ytitle='# quasar/# targets', color='gray'
djs_oplot, plotpbins, frac_two
djs_oplot, plotpbins, frac_one, linestyle=1
legend, ['XDQSOz', 'XDQSO'], $
  linestyle=indgen(2), /right, /bottom, box=0.,charsize=1.1
k_end_print

END
