PRO XDQSOZ_PLOT_REDSHIFTPRIOR, plotfile
thick= 3.
colors= ['brown','purple','dark blue','cyan','dark green','cyan green',$
         'magenta','dark yellow','orange','magenta red']
linestyles= lonarr(10)+0
basedir='$BOSSTARGET_DIR/data/qso-ed/zcounts/'
k_print, filename=plotfile
in= mrdfits(basedir+'dndz_HRH07_17.7_i_17.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_plot, in.z, in.dndz, color=colors[0],linestyle=linestyles[0], $
  xrange=[0.,5.5],xtitle='redshift',ytitle='redshift prior', thick=thick, $
  yrange=[0.,0.7]
in= mrdfits(basedir+'dndz_HRH07_18.2_i_18.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[1],linestyle=linestyles[1], thick=thick
in= mrdfits(basedir+'dndz_HRH07_18.7_i_18.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[2],linestyle=linestyles[2], thick=thick
in= mrdfits(basedir+'dndz_HRH07_19.2_i_19.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[3],linestyle=linestyles[3], thick=thick
in= mrdfits(basedir+'dndz_HRH07_19.7_i_19.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[4],linestyle=linestyles[4], thick=thick
in= mrdfits(basedir+'dndz_HRH07_20.2_i_20.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[5],linestyle=linestyles[5], thick=thick
in= mrdfits(basedir+'dndz_HRH07_20.7_i_20.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[6],linestyle=linestyles[6], thick=thick
in= mrdfits(basedir+'dndz_HRH07_21.2_i_21.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[7],linestyle=linestyles[7], thick=thick
in= mrdfits(basedir+'dndz_HRH07_21.7_i_21.9.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[8],linestyle=linestyles[8], thick=thick
in= mrdfits(basedir+'dndz_HRH07_22.2_i_22.4.fits',1)
in.dndz/= total(in.dndz)*(in.z[1]-in.z[0])
djs_oplot, in.z, in.dndz, color=colors[9],linestyle=linestyles[9], thick=thick
legend, ['17.7 !9l!x i < 17.9', $
         '18.2 !9l!x i < 18.4', $
         '18.7 !9l!x i < 18.9', $
         '19.2 !9l!x i < 19.4', $
         '19.7 !9l!x i < 19.9', $
         '20.2 !9l!x i < 20.4', $
         '20.7 !9l!x i < 20.9', $
         '21.2 !9l!x i < 21.4', $
         '21.7 !9l!x i < 21.9', $
         '22.2 !9l!x i < 22.4'], $
  box= 0., textcolors=djs_icolor(colors), $ ;linestyle=linestyles
  /top,/right, charsize=1.4
;;also plot the histogram of i < 19.1 SDSS quasars
qso= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
mi= sdss_flux2mags(qso.psfflux[3],1.8)
qso= qso[where(mi LT 19.1)]
mi= mi[where(mi LT 19.1)]
nqso= n_elements(qso.ra) & print, nqso
hogg_plothist, qso.z, xrange=[0.3,5.5], /dontplot, xvec=xvec, hist=hist
hist/= total(hist)*(xvec[1]-xvec[0])
djs_oplot, xvec,hist,psym=10
indx= where(xvec GE 2.6 and xvec LE 2.7)
plots, [xvec[indx[0]],3.5],[hist[indx[0]],0.15]
legend, ['SDSS i < 19.1'], /data, box=0.,pos=[3.4,0.18],charsize=1.4
k_end_print
END
