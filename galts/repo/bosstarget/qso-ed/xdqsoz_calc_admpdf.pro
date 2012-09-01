PRO XDQSOZ_CALC_ADMPDF, samples, zmean=zmean, zcovar=zcovar, zamp=zamp, $
                        ngauss=ngauss
IF ~keyword_set(ngauss) THEN ngauss= 4
zsamples= alog(samples)
;;Use XD to fit; init
zamp= dblarr(ngauss)+1D0/ngauss
zmean= dblarr(1,ngauss)+mean(zsamples)+randomn(seed,1,ngauss)*sqrt(variance(zsamples))
zcovar= dblarr(1,1,ngauss)+variance(zsamples)*10.
ydata= reform(zsamples,1,n_elements(zsamples))
ycovar= dblarr(1,n_elements(zsamples))
projected_gauss_mixtures_c, ngauss, ydata, ycovar, zamp, zmean, zcovar, $
  wmin=0.0001
RETURN
END
