;+
;   NAME:
;      wp_figures
;   PURPOSE:
;      make some figures for the white paper
;   INPUT:
;   OUTPUT:
;   HISTORY:
;      2010-06-15 - Written - Bovy (NYU)
;-
PRO WP_FIGURES

in=mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2010-06-11chunks-collate.fits',2)

indx= where(in.inchunk EQ 1)
one= in[indx];;chunk1

sortlike= reverse(sort(one.like_ratio_core))
sorted= reverse(sort(one.qsoed_prob))

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


k_print, filename='like_exd_imag.ps'
hogg_plothist, omags[3,*],xrange=[17,22.2],xtitle='i [mag]'
hogg_plothist, exdmags[3,*],xrange=[17,22.2],xtitle='i [mag]',$
  /overplot,color=djs_icolor('red'),linestyle=2, thick=10
hogg_plothist, likemags[3,*],xrange=[17,22.2],xtitle='i [mag]',$
  /overplot,color=djs_icolor('dark green'), linestyle=3, thick=10
legend, ['Likelihood+ExD','Likelihood only','ExD only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  linestyle=[0,2,3], $
  box=0.,/top,/left
k_end_print

phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .5*cos(phi), .5*sin(phi), /fill

k_print, filename='like_exd_gr_ug.ps'
djs_plot, likemags[0,*]-likemags[1,*],likemags[1,*]-likemags[2,*],psym=2,$
  color=djs_icolor('dark green'),xtitle='u-g',ytitle='g-r',xrange=[-1,5],$
  yrange=[-1,4]
djs_oplot, exdmags[0,*]-exdmags[1,*],exdmags[1,*]-exdmags[2,*],psym=7,$
  color=djs_icolor('red')
djs_oplot, omags[0,*]-omags[1,*],omags[1,*]-omags[2,*],psym=8,symsize=.75
legend, ['Likelihood+ExD','Likelihood only','ExD only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  psym=[8,2,7], $
  box=0.,/top,/left
k_end_print

k_print, filename='like_exd_ri_gr.ps'
djs_plot, likemags[1,*]-likemags[2,*],likemags[2,*]-likemags[3,*], psym=2,$
  xtitle='g-r',ytitle='r-i',yrange=[-0.5,2.5],xrange=[-1,4],$
  color=djs_icolor('dark green')
djs_oplot, exdmags[1,*]-exdmags[2,*],exdmags[2,*]-exdmags[3,*], psym=7,$
  color=djs_icolor('red')
djs_oplot, omags[1,*]-omags[2,*],omags[2,*]-omags[3,*], psym=8,symsize=.75
legend, ['Likelihood+ExD','Likelihood only','ExD only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  psym=[8,2,7], $
  box=0.,/top,/left
k_end_print

k_print, filename='like_exd_iz_ri.ps'
djs_plot, likemags[2,*]-likemags[3,*], likemags[3,*]-likemags[4,*],psym=2,$
  xtitle='r-i',ytitle='i-z',xrange=[-0.5,2.5],yrange=[-0.5,1.5],$
  color=djs_icolor('dark green')
djs_oplot, exdmags[2,*]-exdmags[3,*], exdmags[3,*]-exdmags[4,*],psym=7,$
  color=djs_icolor('red')
djs_oplot, omags[2,*]-omags[3,*], omags[3,*]-omags[4,*],psym=8,symsize=.75
legend, ['Likelihood+ExD','Likelihood only','ExD only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  psym=[8,2,7], $
  box=0.,/top,/left
k_end_print

k_print, filename='like_exd_ts.ps'
djs_plot, likeonly.like_ratio_core,likeonly.qsoed_prob,$
  psym=2,color=djs_icolor('dark green'),xrange=[0,1],yrange=[0,1],$
  xtitle='Likelihood ratio',ytitle='ExD probability', symsize=.5
djs_oplot, exdonly.like_ratio_core,exdonly.qsoed_prob,psym=7,$
  color=djs_icolor('red'),xrange=[0,1],yrange=[0,1] ,symsize=.5
djs_oplot, overlap.like_ratio_core,overlap.qsoed_prob,psym=8,symsize=0.75
legend, ['Likelihood+ExD','Likelihood only','ExD only'],$
  textcolors=[djs_icolor('black'),djs_icolor('dark green'),djs_icolor('red')],$
  psym=[8,2,7], $
  box=0.,/bottom,/left
k_end_print

END
