;+
;   NAME:
;      compare_xdcore_like
;   PURPOSE:
;      compare the xdcore selection with the Likelihood selection
;   INPUT:
;      plotfile
;   OUTPUT:
;   HISTORY:
;      2010-09-05 - Thrown together - Bovy (NYU)
;-
PRO COMPARE_XDCORE_LIKE, plotfile, boss11=boss11
;;Erin's file
in=mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)
indx= where(in.inchunk EQ 1)
one= in[indx];;chunk1
;;rank targets
sortlike= reverse(sort(one.like_ratio_core))
sorted= reverse(sort(one.qsoed_prob))
;;prep different subsets
ntargets= 4400
match, sortlike[0:ntargets-1],sorted[0:ntargets-1],sublike,subed;;overlap
overlap= one[sortlike[sublike]]
prep_data, overlap.psfflux, overlap.psfflux_ivar, $
  extinction=overlap.extinction,mags=omags,var_mags=var_mags

match, sortlike[0:ntargets-1], sorted[ntargets:n_elements(sorted)-1], $
  sublike, subed
likeonly=one[sortlike[sublike]]
prep_data, likeonly.psfflux, likeonly.psfflux_ivar, $
  extinction=likeonly.extinction,mags=likemags,var_mags=var_mags

match, sortlike[ntargets:n_elements(sortlike)-1], sorted[0:ntargets-1], $
  sublike, subed
exdonly= one[sorted[subed]]
prep_data, exdonly.psfflux, exdonly.psfflux_ivar, $
  extinction=exdonly.extinction,mags=exdmags,var_mags=var_mags

phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .5*cos(phi), .5*sin(phi), /fill

k_print, filename=plotfile+'_ts.ps'
djs_plot, likeonly.like_ratio_core,likeonly.qsoed_prob,$
  psym=2,color=djs_icolor('dark green'),xrange=[0,1],yrange=[0,1],$
  xtitle='Likelihood ratio',ytitle='XDQSO probability', symsize=.5
djs_oplot, exdonly.like_ratio_core,exdonly.qsoed_prob,psym=7,$
  color=djs_icolor('red'),xrange=[0,1],yrange=[0,1] ,symsize=.5
djs_oplot, overlap.like_ratio_core,overlap.qsoed_prob,psym=8,symsize=0.75
legend, ['Likelihood+XDQSO','Likelihood only','XDQSO only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  psym=[8,2,7], $
  box=0.,/bottom,/left, charsize=1.5
k_end_print


;;Efficiency
IF keyword_set(boss11) THEN BEGIN
    specarea= 205.12825
    area= specarea
    data= mrdfits('$BOVYQSOEDDATA/chunk11truthtable4Bovy.fits',1)
ENDIF ELSE BEGIN
    area= 219.93
    specarea= 81.2
    data= mrdfits('$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits',1)
ENDELSE
;;spherematch to in
spherematch, one.ra, one.dec, data.ra, data.dec,2./3600., $
  iindx, dindx
one= one[iindx]
data= data[dindx]
;;NN
bnn= obj_new('bosstarget_qsonn')
bnn->nn_run, data, xnn, znn, xnn2
xnn[where(znn LE 2.)]= -1000.;;Cut on photometric redshift and colors
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction,$
  mags=mags, var_mags=var_mags
xnn[where((mags[0,*]-mags[1,*]) LE 0.4 OR (mags[1,*]-mags[3,*]) GE 2)]= -1000.
;;rank targets
sortlike= reverse(sort(one.like_ratio_core))
sorted= reverse(sort(one.qsoed_prob))
;one.nn_xnn[where((one.boss_target1 and 2LL^14) EQ 0)]= -1000.
;sortnn= reverse(sort(one.nn_xnn))
sortnn= reverse(sort(xnn))
;;
xs= dindgen(1001)/1000*80.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sorted[0:floor(xs[ii]*area)]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
    targetindx= sortlike[0:floor(xs[ii]*area)]
    ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
    targetindx= sortnn[0:floor(xs[ii]*area)]
    ysthree[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))/specarea
ENDFOR

;;Plot
k_print, filename=plotfile+'_efficiency.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='# quasar [deg^{-2}]',linestyle=0
djs_oplot, xs, ystwo, linestyle=1
djs_oplot, xs, ysthree, linestyle=2

;;add 20 and 40 lines
djs_oplot, [20.,20.], [0.,ysone[250]]
djs_oplot, [20.,0.], [ysone[250],ysone[250]]
djs_oplot, [40.,40.], [0.,ysone[500]]
djs_oplot, [40.,0.], [ysone[500],ysone[500]]

print, ysone[250], ystwo[250], ysone[250]-ystwo[250]

djs_oplot, [20.,20.], [0.,ystwo[250]], linestyle=1
djs_oplot, [20.,0.], [ystwo[250],ystwo[250]], linestyle=1
djs_oplot, [40.,40.], [0.,ystwo[500]], linestyle=1
djs_oplot, [40.,0.], [ystwo[500],ystwo[500]], linestyle=1

djs_oplot, [20.,20.], [0.,ysthree[250]], linestyle=2
djs_oplot, [20.,0.], [ysthree[250],ysthree[250]], linestyle=2
djs_oplot, [40.,40.], [0.,ysthree[500]], linestyle=2
djs_oplot, [40.,0.], [ysthree[500],ysthree[500]], linestyle=2

;;add legend
legend, ['XDQSO', 'Likelihood','NN'], $
  linestyle=indgen(3), /right, /bottom, box=0.,charsize=1.1
k_end_print


;;Plot
ysone= smooth(deriv(xs,ysone),250/5,/edge_truncate)
ystwo= smooth(deriv(xs,ystwo),250/5,/edge_truncate)
ysthree= smooth(deriv(xs,ysthree),250/5,/edge_truncate)
k_print, filename=plotfile+'_efficiency_deriv.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='d # quasar / d # targets',linestyle=0, yrange=[0.,1.]
djs_oplot, xs, ystwo, linestyle=1
djs_oplot, xs, ysthree, linestyle=2

;;add legend
legend, ['XDQSO', 'Likelihood','NN'], $
  linestyle=indgen(3), /right, /top, box=0.,charsize=1.1
k_end_print





;;Efficiency
;;Cut down
data= data[where(data.ra LT 345. and data.ra GE 180.)]
one= one[where(one.ra LT 345. and one.ra GE 180.)]
area= area/88*(max(one.ra)-min(one.ra))
print, area
;;spherematch to in
spherematch, one.ra, one.dec, data.ra, data.dec,2./3600., $
  iindx, dindx
one= one[iindx]
data= data[dindx]
;;NN
bnn->nn_run, data, xnn, znn, xnn2
xnn[where(znn LT 2.)]= -1000.;;Cut on photometric redshift and color
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction,$
  mags=mags, var_mags=var_mags
xnn[where((mags[0,*]-mags[1,*]) LT 0.4 OR (mags[1,*]-mags[3,*]) GE 2)]= -1000.
;;rank targets
sortlike= reverse(sort(one.like_ratio_core))
sorted= reverse(sort(one.qsoed_prob))
sortnn= reverse(sort(xnn))
;;
xs= dindgen(1001)/1000*80.
nxs= n_elements(xs)
ysone= dblarr(nxs)
ystwo= dblarr(nxs)
ysthree= dblarr(nxs)
FOR ii=0L, nxs-1 DO BEGIN
    targetindx= sorted[0:floor(xs[ii]*area)]
    ysone[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))
    targetindx= sortlike[0:floor(xs[ii]*area)]
    ystwo[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))
    targetindx= sortnn[0:floor(xs[ii]*area)]
    ysthree[ii]= n_elements(where(data[targetindx].zem GE 2.2 and data[targetindx].zem LE 3.5))
ENDFOR

;;Plot
k_print, filename=plotfile+'_efficiency_lowb.ps'
djs_plot, xs, ysone, xtitle='# targets [deg^{-2}]', ytitle='# quasar',linestyle=0, title='low Galactic latitude'
djs_oplot, xs, ystwo, linestyle=1
djs_oplot, xs, ysthree, linestyle=2

;;add 20 and 40 lines
djs_oplot, [20.,20.], [0.,ysone[250]]
djs_oplot, [20.,0.], [ysone[250],ysone[250]]
djs_oplot, [40.,40.], [0.,ysone[500]]
djs_oplot, [40.,0.], [ysone[500],ysone[500]]

djs_oplot, [20.,20.], [0.,ystwo[250]], linestyle=1
djs_oplot, [20.,0.], [ystwo[250],ystwo[250]], linestyle=1
djs_oplot, [40.,40.], [0.,ystwo[500]], linestyle=1
djs_oplot, [40.,0.], [ystwo[500],ystwo[500]], linestyle=1

djs_oplot, [20.,20.], [0.,ysthree[250]], linestyle=2
djs_oplot, [20.,0.], [ysthree[250],ysthree[250]], linestyle=2
djs_oplot, [40.,40.], [0.,ysthree[500]], linestyle=2
djs_oplot, [40.,0.], [ysthree[500],ysthree[500]], linestyle=2

;;add legend
legend, ['XDQSO', 'Likelihood','NN'], $
  linestyle=indgen(3), /right, /bottom, box=0.,charsize=1.1
k_end_print


END
