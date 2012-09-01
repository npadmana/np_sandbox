;+
;   NAME:
;       calc_qso_dndi
;   PURPOSE:
;      calculate the dndi for all of the relevant redshift ranges for
;      various luminosity functions
;   INPUT:
;      lumfunc - 'HRH07', 'R06', or 'J06'
;   OUTPUT:
;      writes files to $BOVYQSOEDDATA
;   HISTORY:
;      2010-05-06 - Written based on J. Hennawi's
;                   'qso_dndi_script.pro' - Bovy
;-
PRO CALC_QSO_DNDI, lumfunc=lumfunc
;; Cosmology for luminosity function
omega_M = 0.26D
omega_V = 0.74D
w = -1.0D
LIT_H = 0.70D
IF ~keyword_set(lumfunc) THEN lumfunc = 'HRH07'
;; Create i-band magnitude bins
imin = 14.0D
imax = 24.0D
di = 0.05D
ni = round((imax-imin)/di)
ivec = imin + di*findgen(ni+1L)
Z_MIN = 2.20D
Z_MAX = 3.50D
format = '(F14.6,F14.6)'
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_hiz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_hiz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE

Z_MIN = 0.30D
Z_MAX = 2.15D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_lowz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_lowz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE

Z_MIN = 2.15D
Z_MAX = 6.00D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_hiz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_hiz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE

Z_MIN = 0.30D
Z_MAX = 2.20D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_lowz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_lowz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE

Z_MIN = 3.50D
Z_MAX = 6.00D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_hiz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_hiz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE


Z_MIN = 4D
Z_MAX = 6.00D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_hiz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_hiz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE


Z_MIN = 2.2D
Z_MAX = 4D
outfile= dndipath(Z_MIN,Z_MAX,lumfunc)
IF ~file_test(outfile) THEN BEGIN
    dndi_hiz = qso_dndi(ivec, Z_MIN, Z_MAX, OMEGA_M, OMEGA_V, W, LIT_H, lumfunc)
    forprint, ivec, dndi_hiz, textout = outfile, format = format
ENDIF ELSE BEGIN
    print, outfile+" exists ..."
    print, "Delete this file to re-run ..."
ENDELSE

END
