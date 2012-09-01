;+
;   NAME:
;       calc_qso_dndz
;   PURPOSE:
;      calculate the dndz for all of the relevant imag ranges for
;      various luminosity functions
;   INPUT:
;      lumfunc - 'HRH07', 'R06', or 'J06'
;   OUTPUT:
;      writes files to $BOSSTARGET_DIR/data/qso-ed/zcounts/
;   HISTORY:
;      2010-01-22 - Written based on calc_qso_dndi - Bovy
;-
PRO CALC_QSO_DNDZ, lumfunc=lumfunc
basedir='../../data/qso-ed/zcounts/'
;; Cosmology for luminosity function
omega_M = 0.26D
omega_V = 0.74D
w = -1.0D
LIT_H = 0.70D
IF ~keyword_set(lumfunc) THEN lumfunc = 'HRH07'
;; Create i-band magnitude bins
imin = 17.7D
imax = 22.5D
di = 0.1D
ni = round((imax-imin)/di)
ivec = imin + di*findgen(ni+1L)
;; Create z bins
zmin = 0.3D
zmax = 5.5D
dz = 0.01D
nz = round((zmax-zmin)/dz)
zvec = zmin + dz*findgen(nz+1L)
;; Some preliminaries for number counts
HORIZON = 2.9979246d3
STER2DEGS = (!dpi/180.0d)^2
anow =  1.0d/(1.0d + zvec)
D = dofa(anow, OMEGA_M, OMEGA_V, w)
H = bigH(zvec, OMEGA_M, OMEGA_V, w)
dVdzdOm = (HORIZON/lit_h)^3*D^2/H
for ii= 0L, ni-2 do begin
    outfile= basedir+'dndz_'+lumfunc+'_'+strtrim(string(ivec[ii],format='(F4.1)'),2)+'_i_'+$
      strtrim(string(ivec[ii+2],format='(F4.1)'),2)+'.fits'
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,ni-1,string(13B)
    IF ~file_test(outfile) THEN BEGIN
        dndz = qso_dndz(ivec[ii+2], ivec[ii], zvec, OMEGA_M, OMEGA_V, W, $
                        LIT_H, lumfunc)*dVdzdOm
        out= create_struct('z',zvec,'dndz',dndz)
        mwrfits, out, outfile, /create
    ENDIF
endfor
end
