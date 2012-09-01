FUNCTION CALC_OVERLAP, one, two
match, one, two, suba, subb, count=value
RETURN, value
END
PRO ANALYZE_BONUS, plotfile

in= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts-se-nncomb-ADMstripe82.fits.gz',1)
area= 219.93065D
ntargets= 40.
;;Calculate cuts for BONUS
NNsort= reverse(sort(in.nn_value_with_ed))
NNcut= in[NNsort[floor(ntargets*area)-1]].nn_value_with_ed
XDUVNIRsort= reverse(sort(in.qsoed_prob_wgalex_wukidss_bonus))
XDUVNIRcut= in[XDUVNIRsort[floor(ntargets*area)-1]].qsoed_prob_wgalex_wukidss_bonus
XDNIRcut= in[(reverse(sort(in.qsoed_prob_wukidss_bonus)))[floor(ntargets*area)-1]].qsoed_prob_wukidss_bonus
XDsort= reverse(sort(in.QSOED_PROB_JUST_UGRIZ_BONUS))
XDcut= in[XDsort[floor(ntargets*area)-1]].QSOED_PROB_JUST_UGRIZ_BONUS
Likesort= reverse(sort(in.like_ratio_bonus))
Likecut= in[Likesort[floor(ntargets*area)-1]].like_ratio_bonus
KDEsort= reverse(sort(in.kde_prob))
KDEcut= in[KDEsort[floor(ntargets*area)-1]].kde_prob
ugrizNNsort= reverse(sort(in.nn_xnn))
ugrizNNcut= in[[floor(ntargets*area)-1]].nn_xnn

thick=8.
;;Plot NN vs. XD-wGALEX-wUKIDSS
k_print, filename=plotfile+'-NN-XDUVNIR.ps'
;;Calculate overlap
noverlap= calc_overlap(NNsort[0:floor(ntargets*area)-1],$
                       XDUVNIRsort[0:floor(ntargets*area)-1])
legend, ['targets overlap: '+strtrim(string(noverlap/area/ntargets*100.,$
                                            format='(F4.1)'),2)+' percent'], $
  box=0., /top,/left,textcolors=[djs_icolor('red')], charthick=3., charsize=1.2
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_WGALEX_WUKIDSS_BONUS, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='XD-GALEX-UKIDSS'
djs_oplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_WGALEX_WUKIDSS_BONUS, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'),thick=thick
djs_oplot, [0.,1.],[XDUVNIRcut,XDUVNIRcut], color=djs_icolor('red'),thick=thick
k_end_print


;;Plot XD targets not picked up by the Combinator
match, NNsort[0:floor(area*ntargets)-1], XDUVNIRsort[floor(ntargets*area):n_elements(in.ra)-1], suba, subb
match, NNsort[0:floor(area*ntargets)-1], XDUVNIRsort[0:floor(ntargets*area)-1], subaa, subbb
prep_data, in.psfflux, in.psfflux_ivar, extinction=in.extinction, $
  mags=mags, var_mags=var_mags
k_print, filename=plotfile+'-XDonly-i.ps'
hogg_plothist, mags[3,XDUVNIRsort[subbb]], xtitle='i [mag]'
hogg_plothist, mags[3,XDUVNIRsort[subb]], xtitle='i [mag]', /overplot
k_end_print

;;Plot NN vs. XD-wUKIDSS
k_print, filename=plotfile+'-NN-XDNIR.ps'
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_WUKIDSS_BONUS, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='XD-UKIDSS'
djs_oplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_WUKIDSS_BONUS, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'), thick=thick
djs_oplot, [0.,1.],[XDNIRcut,XDNIRcut], color=djs_icolor('red'), thick=thick
k_end_print

;;Plot NN vs. XD
k_print, filename=plotfile+'-NN-XD.ps'
;;Calculate overlap
noverlap= calc_overlap(NNsort[0:floor(ntargets*area)-1],$
                       XDsort[0:floor(ntargets*area)-1])
legend, ['targets overlap: '+strtrim(string(noverlap/area/ntargets*100.,$
                                            format='(F4.1)'),2)+' percent'], $
  box=0., /top,/left,textcolors=[djs_icolor('red')], charthick=3., charsize=1.2
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_JUST_UGRIZ_BONUS, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='XD'
djs_oplot, in.NN_VALUE_WITH_ED, in.QSOED_PROB_JUST_UGRIZ_BONUS, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'),thick=thick
djs_oplot, [0.,1.],[XDcut,XDcut], color=djs_icolor('red'),thick=thick
k_end_print

;;Plot NN vs. Likelihood
k_print, filename=plotfile+'-NN-Like.ps'
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.LIKE_RATIO_BONUS, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='Likelihood'
;;Calculate overlap
noverlap= calc_overlap(NNsort[0:floor(ntargets*area)-1],$
                       Likesort[0:floor(ntargets*area)-1])
legend, ['targets overlap: '+strtrim(string(noverlap/area/ntargets*100.,$
                                            format='(F4.1)'),2)+' percent'], $
  box=0., /top,/left,textcolors=[djs_icolor('red')], charthick=3., charsize=1.2
djs_oplot, in.NN_VALUE_WITH_ED, in.LIKE_RATIO_BONUS, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'), thick=thick
djs_oplot, [0.,1.],[Likecut,Likecut], color=djs_icolor('red'), thick=thick
k_end_print

;;Plot NN vs. KDE
k_print, filename=plotfile+'-NN-KDE.ps'
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.KDE_PROB, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='KDE'
;;Calculate overlap
noverlap= calc_overlap(NNsort[0:floor(ntargets*area)-1],$
                       KDEsort[0:floor(ntargets*area)-1])
legend, ['targets overlap: '+strtrim(string(noverlap/area/ntargets*100.,$
                                            format='(F4.1)'),2)+' percent'], $
  box=0., /top,/left,textcolors=[djs_icolor('red')], charthick=3., charsize=1.2
djs_oplot, in.NN_VALUE_WITH_ED, in.KDE_PROB, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'), thick=thick
djs_oplot, [0.,1.],[KDEcut,KDEcut], color=djs_icolor('red'), thick=thick
k_end_print

;;Plot NN vs. NN
k_print, filename=plotfile+'-NN-NN.ps'
hogg_scatterplot, in.NN_VALUE_WITH_ED, in.NN_XNN, $
  /conditional, xnpix=51, ynpix=51, /nogreyscale,$
  xrange=[0.,1.],yrange=[0.,1.], xtitle='NN Combinator w/ XD', $
  ytitle='ugriz NN (xnn)'
;;Calculate overlap
noverlap= calc_overlap(NNsort[0:floor(ntargets*area)-1],$
                       ugrizNNsort[0:floor(ntargets*area)-1])
legend, ['targets overlap: '+strtrim(string(noverlap/area/ntargets*100.,$
                                            format='(F4.1)'),2)+' percent'], $
  box=0., /top,/left,textcolors=[djs_icolor('red')], charthick=3., charsize=1.2
djs_oplot, in.NN_VALUE_WITH_ED, in.NN_XNN, $
  psym=3
;;overplot 40 cuts
djs_oplot, [NNcut,NNcut],[0.,1.],color=djs_icolor('red'), thick=thick
djs_oplot, [0.,1.],[ugrizNNcut,ugrizNNcut], color=djs_icolor('red'), thick=thick
k_end_print



;;Calculate overlap as a function of g
prep_data, in.psfflux, in.psfflux_ivar, extinction=in.extinction, $
  mags=mags, var_mags=var_mags
gminmax= minmax(mags[1,NNsort[0:floor(ntargets*area)-1]])
if gminmax[1] GT 22. THEN gminmax[1]= 22.
nbins= 21
gstep= (gminmax[1]-gminmax[0])/nbins
gs= (dindgen(nbins)+0.5)*gstep+gminmax[0]
outXD= dblarr(nbins)
outXDugriz= dblarr(nbins)
outLike= dblarr(nbins)
outKDE= dblarr(nbins)
outNN= dblarr(nbins)
;;Prepare
NNsort= NNsort[0:floor(area*ntargets)-1]
XDUVNIRsort= XDUVNIRsort[0:floor(area*ntargets)-1]
XDsort= XDsort[0:floor(area*ntargets)-1]
Likesort= Likesort[0:floor(area*ntargets)-1]
KDEsort= KDEsort[0:floor(area*ntargets)-1]
ugrizNNsort= ugrizNNsort[0:floor(area*ntargets)-1]
FOR ii=0L, nbins-1 DO BEGIN
    thisindx= where(mags[1,*] GE (gs[ii]-0.5*gstep) and $
                    mags[1,*] LT (gs[ii]+0.5*gstep))
    match, thisindx, NNsort, $
      suba, subb, count=ntargetsbin
    noverlapXD= calc_overlap(NNsort[subb],XDUVNIRsort)
    noverlapXDugriz= calc_overlap(NNsort[subb],XDsort)
    noverlapLike= calc_overlap(NNsort[subb],Likesort)
    noverlapKDE= calc_overlap(NNsort[subb],KDEsort)
    noverlapNN= calc_overlap(NNsort[subb],ugrizNNsort)
    ;;percentages
    outXD[ii]= 100.*noverlapXD/ntargetsbin
    outXDugriz[ii]= 100.*noverlapXDugriz/ntargetsbin
    outLike[ii]= 100.*noverlapLike/ntargetsbin
    outKDE[ii]= 100.*noverlapKDE/ntargetsbin
    outNN[ii]= 100.*noverlapNN/ntargetsbin
ENDFOR

k_print, filename=plotfile+'-overlapg.ps'
djs_plot, gs, outXD, xtitle='g [mag]', ytitle='overlap with NN Combinator [percent]', $
  xrange=gminmax, yrange=[0.,100.], linestyle=0, color='black'
djs_oplot, gs, outLike, linestyle=1, color='red', thick=3.
djs_oplot, gs, outKDE, linestyle=2, color='dark blue', thick=3.
djs_oplot, gs, outNN, linestyle=3, color='dark green', thick=3
djs_oplot, gs, outXDugriz, linestyle=4, color='dark cyan', thick=3
legend, ['XD-GALEX-UKIDSS','Likelihood','KDE','ugriz NN (XNN)',$
         'ugriz XD'], $
  box=0., $
  textcolors=[djs_icolor('black'), djs_icolor('red'), $
              djs_icolor('dark blue'), $
              djs_icolor('dark green'), $
              djs_icolor('dark cyan')], $
  linestyle=lindgen(5), charsize=1.2, charthick=2., /top, /right
k_end_print








;;Calculate overlap as a function of i
prep_data, in.psfflux, in.psfflux_ivar, extinction=in.extinction, $
  mags=mags, var_mags=var_mags
gminmax= minmax(mags[3,NNsort[0:floor(ntargets*area)-1]])
;if gminmax[1] GT 22. THEN gminmax[1]= 22.
nbins= 21
gstep= (gminmax[1]-gminmax[0])/nbins
gs= (dindgen(nbins)+0.5)*gstep+gminmax[0]
outXD= dblarr(nbins)
outXDugriz= dblarr(nbins)
outLike= dblarr(nbins)
outKDE= dblarr(nbins)
outNN= dblarr(nbins)
;;Prepare
NNsort= NNsort[0:floor(area*ntargets)-1]
XDUVNIRsort= XDUVNIRsort[0:floor(area*ntargets)-1]
XDsort= XDsort[0:floor(area*ntargets)-1]
Likesort= Likesort[0:floor(area*ntargets)-1]
KDEsort= KDEsort[0:floor(area*ntargets)-1]
ugrizNNsort= ugrizNNsort[0:floor(area*ntargets)-1]
FOR ii=0L, nbins-1 DO BEGIN
    thisindx= where(mags[3,*] GE (gs[ii]-0.5*gstep) and $
                    mags[3,*] LT (gs[ii]+0.5*gstep))
    match, thisindx, NNsort, $
      suba, subb, count=ntargetsbin
    noverlapXD= calc_overlap(NNsort[subb],XDUVNIRsort)
    noverlapXDugriz= calc_overlap(NNsort[subb],XDsort)
    noverlapLike= calc_overlap(NNsort[subb],Likesort)
    noverlapKDE= calc_overlap(NNsort[subb],KDEsort)
    noverlapNN= calc_overlap(NNsort[subb],ugrizNNsort)
    ;;percentages
    outXD[ii]= 100.*noverlapXD/ntargetsbin
    outXDugriz[ii]= 100.*noverlapXDugriz/ntargetsbin
    outLike[ii]= 100.*noverlapLike/ntargetsbin
    outKDE[ii]= 100.*noverlapKDE/ntargetsbin
    outNN[ii]= 100.*noverlapNN/ntargetsbin
ENDFOR

k_print, filename=plotfile+'-overlapi.ps'
djs_plot, gs, outXD, xtitle='i [mag]', ytitle='overlap with NN Combinator [percent]', $
  xrange=gminmax, yrange=[0.,100.], linestyle=0, color='black'
djs_oplot, gs, outLike, linestyle=1, color='red', thick=3.
djs_oplot, gs, outKDE, linestyle=2, color='dark blue', thick=3.
djs_oplot, gs, outNN, linestyle=3, color='dark green', thick=3
djs_oplot, gs, outXDugriz, linestyle=4, color='dark cyan', thick=3
legend, ['XD-GALEX-UKIDSS','Likelihood','KDE','ugriz NN (XNN)',$
         'ugriz XD'], $
  box=0., $
  textcolors=[djs_icolor('black'), djs_icolor('red'), $
              djs_icolor('dark blue'), $
              djs_icolor('dark green'), $
              djs_icolor('dark cyan')], $
  linestyle=lindgen(5), charsize=1.2, charthick=2., /top, /right
k_end_print
END
