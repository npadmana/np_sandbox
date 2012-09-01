;+
;
;-
PRO PLOT_PQSO_CONSISTENCY, plotfile, boss11=boss11

IF keyword_set(boss11) THEN BEGIN
    specarea_one= 205.12825
    area_one= specarea_one
    dataone= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
    xdone= mrdfits('chunk11_extreme_deconv_HRH07.fits',1)
ENDIF ELSE BEGIN
    specarea_one= 81.2
    area_one= 219.93
    xdone= mrdfits('chunk1_extreme_deconv_HRH07.fits',1)
    dataone= mrdfits('$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits',1)
ENDELSE

datatwo= mrdfits('$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits',1)
xdtwo= mrdfits('chunk2_extreme_deconv_HRH07.fits',1)
specarea_two= 95.7
area_two= 143.66

threshold= 40

sortindx_one= REVERSE(SORT(xdone.pqso))
sortindx_two= REVERSE(SORT(xdtwo.pqso))

targetindx_one= sortindx_one[0:floor(threshold*area_one)]
targetindx_two= sortindx_two[0:floor(threshold*area_two)]

ptres_one= xdone[targetindx_one[n_elements(targetindx_one)-1]].pqso
ptres_two= xdtwo[targetindx_two[n_elements(targetindx_two)-1]].pqso

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
    indx= where(xdone[targetindx_one].pqso GT pbins[ii] AND $
                xdone[targetindx_one].pqso LE pbins[ii+1])
    frac_one[ii]= double(n_elements(where(dataone[targetindx_one[indx]].zem GE 2.2 AND $
                                          dataone[targetindx_one[indx]].zem LE 3.5)))/$
      n_elements(indx)/specarea_one*area_one
    indx= where(xdtwo[targetindx_two].pqso GT pbins[ii] AND $
                xdtwo[targetindx_two].pqso LE pbins[ii+1])
    frac_two[ii]= double(n_elements(where(datatwo[targetindx_two[indx]].zem GE 2.2 AND $
                                          datatwo[targetindx_two[indx]].zem LE 3.5)))/$
      n_elements(indx)/specarea_two*area_two
ENDFOR


plotpbins= dblarr(bins)
FOR ii=0L, bins-1 DO plotpbins[ii]= (pbins[ii]+pbins[ii+1])/2.
plotpbins[bins-1]= 1.
k_print, filename=plotfile
djs_plot, [0.1,1.], [0.1,1.],xtitle='P(quasar)',ytitle='# quasar/# targets', color='gray'
djs_oplot, plotpbins, frac_one
djs_oplot, plotpbins, frac_two, linestyle=1
legend, ['BOSS area 1', 'BOSS area 2'], $
  linestyle=indgen(2), /right, /bottom, box=0.,charsize=1.1
k_end_print

END
