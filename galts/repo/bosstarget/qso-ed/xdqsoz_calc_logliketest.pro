FUNCTION XDQSOZ_CALC_LOGLIKETEST
;;Get quasars
qso= mrdfits('$BOVYQSOEDDATA/qso_all_extreme_deconv_10.fits',1)
mi= sdss_flux2mags(qso.psfflux[3],1.8)
qso= qso[where(mi GE 17.75 and mi LE 22.45)]
mi= mi[where(mi GE 17.75 and mi LE 22.45)]
nqso= n_elements(qso.ra)
indx=  where(qso.z GE 0.3 and qso.z LE 5.5,cnt)
IF cnt gt 0 then begin
    qso= qso[indx]
    mi= mi[indx]
    nqso= cnt
ENDIF
;;loop through, accumulate
loglike= 0D0
FOR ii=0L, nqso-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,nqso,string(13B)
    ;;get zpdf
    xdqsoz_zpdf, qso[ii].psfflux, qso[ii].psfflux_ivar, $
      zmean=zmean, zcovar=zcovar, zamp=zamp
    loglike+= alog(eval_xdqsoz_zpdf(qso[ii].z,zmean,zcovar,zamp))
ENDFOR
RETURN, loglike
END
