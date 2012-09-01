;+
;   NAME:
;      prep_data
;   PURPOSE:
;      Prepare the data for analysis: deredden and convert to
;      magnitudes or colors
;   INPUT:
;      flux - 
;      flux_ivar - inverse error-squared on the flux
;      extinction - extinction along the los (optional)
;   KEYWORDS:
;      colors - if set, return colors and color errors (u-g, g-r, r-i,
;               i-z)
;      nbyncovar - if set, return the uncertainty variance as an n by
;                  n matrix (with correlations set to 0) instead of an
;                  n-array (ONLY FOR MAGS, SINCE THE COLORS ARE
;                  CORRELATED THEY ALWAYS RETURN AN NbyN MATRIX)
;      fluxes - if set, return the fluxes
;      relfluxes - if set, return relative fluxes to i-band
;   OUTPUT:
;      mags - magnitudes (or colors if /colors is set) [nmags,ndata]
;      var_mags - magnitude errors-squared (or color errors if /colors
;                 is set) [nmags,ndata]
;   HISTORY:
;      2010-03-04 - Written based on Hennawi's code snippets - Bovy (NYU)
;      2010-04-17 - Added relfluxes keyword - Bovy
;-
PRO PREP_DATA_OLD, flux, flux_ivar, extinction=extinction, $
               mags=mags, var_mags=var_mags, $
               colors=colors, nbyncovar=nbyncovar, fluxes=fluxes, $
               relfluxes=relfluxes

; softening parameters from EDR paper in units of 1.0e-10
; (Stoughton et al. 2002)
b_u = 1.4
b_g = 0.9
b_r = 1.2
b_i = 1.8
b_z = 7.4

if keyword_set(extinction) THEN BEGIN
    ;sdss_dereddened qso fluxes
    f_u =  sdss_deredden(flux[0,*], extinction[0,*])
    f_g =  sdss_deredden(flux[1,*], extinction[1,*])
    f_r =  sdss_deredden(flux[2,*], extinction[2,*])
    f_i =  sdss_deredden(flux[3,*], extinction[3,*])
    f_z =  sdss_deredden(flux[4,*], extinction[4,*])
    
    ;sdss_dereddened inverse variances
    ivar_u = sdss_deredden_error(flux_ivar[0,*], extinction[0,*])
    ivar_g = sdss_deredden_error(flux_ivar[1,*], extinction[1,*])
    ivar_r = sdss_deredden_error(flux_ivar[2,*], extinction[2,*])
    ivar_i = sdss_deredden_error(flux_ivar[3,*], extinction[3,*])
    ivar_z = sdss_deredden_error(flux_ivar[4,*], extinction[4,*])
ENDIF ELSE BEGIN
    f_u =  flux[0,*]
    f_g =  flux[1,*]
    f_r =  flux[2,*]
    f_i =  flux[3,*]
    f_z =  flux[4,*]
    
    ;sdss_dereddened inverse variances
    ivar_u = flux_ivar[0,*]
    ivar_g = flux_ivar[1,*]
    ivar_r = flux_ivar[2,*]
    ivar_i = flux_ivar[3,*]
    ivar_z = flux_ivar[4,*]
ENDELSE
IF keyword_set(fluxes) THEN BEGIN
    nobjs= n_elements(f_u)
    mags= dblarr(5,nobjs)
    if keyword_set(nbyncovar) THEN var_mags= dblarr(5,5,nobjs) ELSE $
      var_mags= dblarr(5,nobjs)
    mags[0,*]= f_u
    mags[1,*]= f_g
    mags[2,*]= f_r
    mags[3,*]= f_i
    mags[4,*]= f_z
    if keyword_set(nbyncovar) THEN BEGIN
        var_mags[0,0,*]= 1D0/ivar_u
        var_mags[1,1,*]= 1D0/ivar_g
        var_mags[2,2,*]= 1D0/ivar_r
        var_mags[3,3,*]= 1D0/ivar_i
        var_mags[4,4,*]= 1D0/ivar_z
    ENDIF ELSE BEGIN
        var_mags[0,*]= 1D0/ivar_u
        var_mags[1,*]= 1D0/ivar_g 
        var_mags[2,*]= 1D0/ivar_r
        var_mags[3,*]= 1D0/ivar_i
        var_mags[4,*]= 1D0/ivar_z
    ENDELSE
    RETURN
ENDIF


IF keyword_set(relfluxes) THEN BEGIN
    nobjs= n_elements(f_u)
    mags= dblarr(4,nobjs)
    var_mags= dblarr(4,4,nobjs)
    mags[0,*]= f_u/f_i
    mags[1,*]= f_g/f_i
    mags[2,*]= f_r/f_i
    mags[3,*]= f_z/f_i

    var_mags[0,0,*]= 1D0/ivar_u/f_i^2D0+f_u^2D0/ivar_i/f_i^4D0
    var_mags[1,1,*]= 1D0/ivar_g/f_i^2D0+f_g^2D0/ivar_i/f_i^4D0
    var_mags[2,2,*]= 1D0/ivar_r/f_i^2D0+f_r^2D0/ivar_i/f_i^4D0
    var_mags[3,3,*]= 1D0/ivar_z/f_i^2D0+f_z^2D0/ivar_i/f_i^4D0

    ;;Off-diagonal elements
    var_mags[0,1,*]= f_u*f_g/f_i^4D0/ivar_i
    var_mags[1,0,*]= var_mags[0,1,*]
    var_mags[0,2,*]= f_u*f_r/f_i^4D0/ivar_i
    var_mags[2,0,*]= var_mags[0,2,*]
    var_mags[0,3,*]= f_u*f_z/f_i^4D0/ivar_i
    var_mags[3,0,*]= var_mags[0,3,*]
    var_mags[1,2,*]= f_g*f_r/f_i^4D0/ivar_i
    var_mags[2,1,*]= var_mags[1,2,*]
    var_mags[1,3,*]= f_g*f_z/f_i^4D0/ivar_i
    var_mags[3,1,*]= var_mags[1,3,*]
    var_mags[2,3,*]= f_r*f_z/f_i^4D0/ivar_i
    var_mags[3,2,*]= var_mags[2,3,*]
    RETURN
ENDIF

; calculate magnitudes
u = sdss_flux2mags(f_u, b_u)
g = sdss_flux2mags(f_g, b_g)
r = sdss_flux2mags(f_r, b_r)
i = sdss_flux2mags(f_i, b_i)
z = sdss_flux2mags(f_z, b_z)
; calculate magnitude errors
sig_u = sdss_ivar2magerr(ivar_u, f_u, b_u)
sig_g = sdss_ivar2magerr(ivar_g, f_g, b_g)
sig_r = sdss_ivar2magerr(ivar_r, f_r, b_r)
sig_i = sdss_ivar2magerr(ivar_i, f_i, b_i)
sig_z = sdss_ivar2magerr(ivar_z, f_z, b_z)

nobjs= n_elements(u)
IF ~keyword_set(colors) THEN BEGIN
    mags= dblarr(5,nobjs)
    if keyword_set(nbyncovar) THEN var_mags= dblarr(5,5,nobjs) ELSE $
      var_mags= dblarr(5,nobjs)
    mags[0,*]= u
    mags[1,*]= g
    mags[2,*]= r
    mags[3,*]= i
    mags[4,*]= z
    if keyword_set(nbyncovar) THEN BEGIN
        var_mags[0,0,*]= sig_u^2.
        var_mags[1,1,*]= sig_g^2.
        var_mags[2,2,*]= sig_r^2.
        var_mags[3,3,*]= sig_i^2.
        var_mags[4,4,*]= sig_z^2.
    ENDIF ELSE BEGIN
        var_mags[0,*]= sig_u^2.
        var_mags[1,*]= sig_g^2.
        var_mags[2,*]= sig_r^2.
        var_mags[3,*]= sig_i^2.
        var_mags[4,*]= sig_z^2.
    ENDELSE
ENDIF ELSE BEGIN
   ; quasar colors
    ug = u - g
    gr = g - r
    ri = r - i
    iz = i - z
    gi = g - i
    
   ; qso color errors
    sig_ug2 = sig_u^2 + sig_g^2
    sig_gr2 = sig_g^2 + sig_r^2
    sig_ri2 = sig_r^2 + sig_i^2
    sig_iz2 = sig_i^2 + sig_z^2
    ;sig_gi2 = sig_g^2 + sig_i^2

    mags= dblarr(4,nobjs)
    var_mags=dblarr(4,4,nobjs)
    mags[0,*]= ug
    mags[1,*]= gr
    mags[2,*]= ri
    mags[3,*]= iz

    ;;covariance matrix
    var_mags[0,0,*]= sig_ug2
    var_mags[1,1,*]= sig_gr2
    var_mags[2,2,*]= sig_ri2
    var_mags[3,3,*]= sig_iz2

    var_mags[0,1,*]= -sig_g^2
    var_mags[1,0,*]= var_mags[0,1,*]
    var_mags[1,2,*]= -sig_r^2
    var_mags[2,1,*]= var_mags[1,2,*]
    var_mags[2,3,*]= -sig_i^2
    var_mags[3,2,*]= var_mags[2,3,*]
ENDELSE
END
