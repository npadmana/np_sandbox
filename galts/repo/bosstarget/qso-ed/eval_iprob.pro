;+
;   NAME:
;      eval_iprob
;   PURPOSE:
;      evaluate the probability of finding a given i-band flux
;   INPUT:
;      fi - i-band flux (extinction corrected) (can be an array)
;      i - array of i-band magnitudes that serve as abcissae for
;      dndi - differential number counts
;   OUTPUT:
;      n(fi) - in objects /square degree (or array of this)
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;-
FUNCTION EVAL_IPROB, fi, i, dndi
b= 1.8
nfi= n_elements(fi)
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(fi,b)
out= INTERPOL(dndi,i,mi,/spline)
IF scalarOut THEN RETURN, out[0] ELSE RETURN, out
END
