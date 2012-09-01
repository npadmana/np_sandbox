;+
;   NAME:
;      eval_izprob
;   PURPOSE:
;      evaluate the probability of finding a given i-band flux and redshift
;   INPUT:
;      z - redshift
;      fi - i-band flux (extinction corrected) (can be an array)
;   OUTPUT:
;      n(fi,z) - in objects /square degree (or array of this)
;   HISTORY:
;      2010-04-23 - Written - Bovy (NYU)
;      2011-01-17 - Adapted for dN/di/dz - Bovy (from Hennawi's code)
;-
FUNCTION QSO_DNDI_INTEGRAND, Z, PRIVATE

common kcorr, z_in, Kz_in
;; calculate K-correction and distance modulus
IF NOT KEYWORD_SET(Kz_in) THEN BEGIN
   kfile = getenv('QSO_DIR') + '/misc/templates/kcorr_Miz2_richards.dat'
   rdfloat, kfile, z_in, Kz_in, skip = 22
ENDIF

HORIZON = 2.9979246d3
i  = PRIVATE.I
omega_M  = PRIVATE.OMEGA_M
omega_V  = PRIVATE.OMEGA_V
w        = PRIVATE.W
lit_h    = private.LIT_H
LUMFUNC  = private.LUMFUNC

anow =  1.0d/(1.0d + z)
;; The luminosity functions are compiled using the 0.30,0.70,0.70
;; cosmology, and so k-corrections are done using that cosmology
Kz = interpol(Kz_in, z_in, z)
DM = distance_modulus(anow, lit_h, 0.3D, 0.7D, -1.0D)
;; absolute magnitude limits for the range of apparent magnitudes at
;; this
;; redshift. Note these are M_i(z=2) absolute magnitudes.
M = i - DM - Kz
;; Volume element in desired cosmology
D = dofa(anow, OMEGA_M, OMEGA_V, w)
H = bigH(z, OMEGA_M, OMEGA_V, w)
dVdzdOm = (HORIZON/lit_h)^3*D^2/H
;; Volume element in reference cosmology
HORIZON = 2.9979246d3
D_ref = dofa(anow, 0.3D, 0.7D, -1.0D)
H_ref = bigH(z, 0.3D, 0.7D, -1.0D)
dVdzdOm_ref = (HORIZON/0.7D)^3*D_ref^2/H_ref
;; Re-scale volume to cosmology of interest
rescale =  (dVdzdOm/dVdzdOm_ref)
phi_z = qso_lf_shen(M, Z, LUMFUNC)
;; integrand = dVdzdOm*phi(M)
answer = dVdzdOm*rescale*phi_z
RETURN, answer
END
FUNCTION EVAL_IZPROB, z, fi, lumfunc=lumfunc
b= 1.8
STER2DEGS = (!dpi/180.0d)^2d0
nfi= n_elements(fi)
nz= n_elements(z)
;;Check inputs
if nfi GE 1 and nz EQ 1 then begin
    thisz= replicate(z,nfi)
    thisfi= fi
endif else if nz gt 1 and nfi eq 1 then begin
    thisz= z
    thisfi= replicate(fi,nz)
    nfi= n_elements(thisfi)
endif else begin
    print, "Warning: inputs to eval_izprob are wrong"
    return , -1.
endelse
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(thisfi,b)
out= dblarr(nfi)

;; Cosmology for luminosity function
omega_M = 0.26D
omega_V = 0.74D
w = -1.0D
LIT_H = 0.70D
IF ~keyword_set(lumfunc) THEN lumfunc = 'HRH07'
for ii=0L, nfi-1 do begin
    private = create_struct('I', mi[ii], $
                            'OMEGA_M', omega_m, $
                            'OMEGA_V', omega_v, 'W', w, $
                            'LIT_H', lit_h, 'LUMFUNC', lumfunc)
    out[ii]= QSO_DNDI_INTEGRAND(thisz[ii],private)*ster2degs
endfor
IF scalarOut THEN RETURN, out[0] ELSE RETURN, out
END
