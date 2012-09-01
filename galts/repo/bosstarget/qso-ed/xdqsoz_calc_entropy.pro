;+
;   NAME:
;      xdqsoz_calc_entropy
;   PURPOSE:
;      calculate KL divergences 
;   INPUT:
;      flux - dereddened flux
;      flux_ivar - dereddened flux_ivar
;   KEYWORDS:
;      galex - use GALEX
;      ukidss - use UKIDSS
;      cross - if set, calculate KL between AUX+SDSS vs. SDSS-only
;      uniform - compare to uniform
;   OUTPUT:
;      return KL divergence
;   HISTORY:
;      2011-01-18 - Written - Bovy (NYU)
;-
FUNCTION ENTROPY_INTEGRAND, z, private
p= eval_xdqsoz_zpdf(z,private.zmean,private.zcovar,$
                    private.zamp)
IF private.uniform THEN q= 1. else q= eval_xdqsoz_zpdf(z,private.priorzmean,private.priorzcovar,$
                    private.priorzamp)
RETURN, p*alog(p/q)
END
FUNCTION XDQSOZ_CALC_ENTROPY, flux, flux_ivar, $
                              galex=galex, ukidss=ukidss, cross=cross, $
                              uniform=uniform
;;get redshift pdf
xdqsoz_zpdf, flux,$
  flux_ivar,$
  galex=galex,ukidss=ukidss, $
  zmean=zmean,zcovar=zcovar,$
  zamp=zamp
if keyword_set(cross) then $ ;;ugriz only
  xdqsoz_zpdf, flux[0:4],$
  flux_ivar[0:4],$
  zmean=priorzmean,zcovar=priorzcovar,$
  zamp=priorzamp else $ ;;prior
  xdqsoz_zpdf, flux[0:4],$
  dblarr(5)+1./1d5,$
  zmean=priorzmean,zcovar=priorzcovar,$
  zamp=priorzamp 
;;integrate
EPSABS = 0.0
EPSREL = 1.0d-4
private = create_struct('zmean',zmean,'zcovar',zcovar,$
                        'zamp',zamp, 'priorzmean',priorzmean,$
                        'priorzcovar',priorzcovar,'priorzamp',priorzamp,$
                       'uniform',keyword_set(uniform))
RETURN, qpint1d('ENTROPY_INTEGRAND', 0.3, 5.5, PRIVATE $
                , EPSABS = float(EPSABS), EPSREL = float(EPSREL) $
                , STATUS = STATUS)
END
