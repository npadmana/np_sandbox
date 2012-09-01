PRO XDQSOZ_PLOT_TESTLOGLIKE, plotfile
in= mrdfits('xdqsoz_testloglike.fits',1)
yrange= [0.9*min(in.loglike),1.1*max(in.loglike)]
k_print, filename=plotfile
djs_plot, dindgen(10)*10.+10., in.loglike, xrange=[0.,110.], xtitle='# Gaussians', charsize=1.2, yrange=yrange
djs_oplot, [60.,60.], yrange, color='gray',thick=3.
xyouts, -30., 6000., 'log p(spectroscopic redshift)', orientation=90., charsize=1.8
xyouts, -23., 6500., 'of 10% test sample', orientation=90., charsize=1.8
k_end_print
END
