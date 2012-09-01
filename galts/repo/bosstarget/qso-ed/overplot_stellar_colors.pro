;+
;   NAME:
;      overplot_stellar_colors
;   PURPOSE:
;      overplot the stellar color locus etc
;   INPUT:
;      /ugr, /gri, /riz - indicates which color-color diagram we're
;                         talking about
;   OUTPUT:
;   HISTORY:
;      2010-11-17 - Written - Bovy
;-
FUNCTION GET_SUBCLASS_INDX, plate, subclass, n=n
if ~keyword_set(n) then n=1
return, where(strcmp(plate.subclass,subclass,n))
END
PRO OVERPLOT_STELLAR_COLORS, ugr=ugr, gri=gri, riz=riz

;;overplot actual stars
plate1= mrdfits('/global/data/sdss/spectro/0323/spZbest-0323-51615.fits',1)
phot1= mrdfits('/global/data/sdss/spectro/calibobj/calibPlateP-0323.fits',1)
spherematch, plate1.plug_ra, plate1.plug_dec, phot1.ra, phot1.dec, 2./3600.,plateindx, photindx
plate1= plate1[plateindx]
phot1= phot1[photindx]
plate2= mrdfits('/global/data/sdss/spectro/0324/spZbest-0324-?????.fits',1)
phot2= mrdfits('/global/data/sdss/spectro/calibobj/calibPlateP-0324.fits',1)
spherematch, plate2.plug_ra, plate2.plug_dec, phot2.ra, phot2.dec, 2./3600.,plateindx, photindx
plate2= plate2[plateindx]
phot2= phot2[photindx]
plate= struct_concat(plate1,plate2)
phot= struct_concat(phot1,phot2)
indx= where(strcmp(plate.objtype,'STAR_BHB',8) and strcmp(plate.class,'STAR',4) and plate.zwarning EQ 0,nindx)
plate= plate[indx]
phot= phot[indx]
prep_data, phot.psfflux, phot.psfflux_ivar, extinction=phot.extinction, $
  mags=mags, var_mags=var_mags, /colors
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
IF keyword_set(ugr) THEN BEGIN
    loadct, 34;;31
    ;;A
    indx= get_subclass_indx(plate,'A')
    size= 0.2
    usersym, size*cos(phi), size*sin(phi), /fill
    if indx[0] ne -1 then djs_oplot, mags[0,indx], mags[1,indx], psym=8, color='dark blue' else print, "no A"
    ;;F
    indx= get_subclass_indx(plate,'F')
    if indx[0] ne -1 then djs_oplot, mags[0,indx], mags[1,indx], psym=8, color='cyan' else print, "no F"
    ;;G
    indx= get_subclass_indx(plate,'G')
    if indx[0] ne -1 then djs_oplot, mags[0,indx], mags[1,indx], psym=8, color='green' else print, "no G"
    ;;K
    indx= get_subclass_indx(plate,'K')
    if indx[0] ne -1 then djs_oplot, mags[0,indx], mags[1,indx], psym=8, color='orange' else print, "no K"
    ;;M
    indx= get_subclass_indx(plate,'M')
    if indx[0] ne -1 then djs_oplot, mags[0,indx], mags[1,indx], psym=8, color='red' else print, "no M"
    ;;Add legend
    legend, ['A','F','G','K','M'],textcolors=[djs_icolor('dark blue'),djs_icolor('cyan'),djs_icolor('green'),djs_icolor('orange'),djs_icolor('red')],/top,/right,/horizontal, box=0., charsize=2.,charthick=2.
ENDIF ELSE IF keyword_set(gri) THEN BEGIN
    ;;A
    indx= get_subclass_indx(plate,'A')
    size= 0.2
    usersym, size*cos(phi), size*sin(phi), /fill
    if indx[0] ne -1 then djs_oplot, mags[1,indx], mags[2,indx], psym=8, color='dark blue' else print, "no A"
    ;;F
    indx= get_subclass_indx(plate,'F')
    if indx[0] ne -1 then djs_oplot, mags[1,indx], mags[2,indx], psym=8, color='cyan' else print, "no F"
    ;;G
    indx= get_subclass_indx(plate,'G')
    if indx[0] ne -1 then djs_oplot, mags[1,indx], mags[2,indx], psym=8, color='green' else print, "no G"
    ;;K
    indx= get_subclass_indx(plate,'K')
    if indx[0] ne -1 then djs_oplot, mags[1,indx], mags[2,indx], psym=8, color='orange' else print, "no K"
    ;;M
    indx= get_subclass_indx(plate,'M')
    if indx[0] ne -1 then djs_oplot, mags[1,indx], mags[2,indx], psym=8, color='red' else print, "no M"
ENDIF ELSE BEGIN
    ;;A
    indx= get_subclass_indx(plate,'A')
    size= 0.2
    usersym, size*cos(phi), size*sin(phi), /fill
    if indx[0] ne -1 then djs_oplot, mags[2,indx], mags[3,indx], psym=8, color='dark blue' else print, "no A"
    ;;F
    indx= get_subclass_indx(plate,'F')
    if indx[0] ne -1 then djs_oplot, mags[2,indx], mags[3,indx], psym=8, color='cyan' else print, "no F"
    ;;G
    indx= get_subclass_indx(plate,'G')
    if indx[0] ne -1 then djs_oplot, mags[2,indx], mags[3,indx], psym=8, color='green' else print, "no G"
    ;;K
    indx= get_subclass_indx(plate,'K')
    if indx[0] ne -1 then djs_oplot, mags[2,indx], mags[3,indx], psym=8, color='orange' else print, "no K"
    ;;M
    indx= get_subclass_indx(plate,'M')
    if indx[0] ne -1 then djs_oplot, mags[2,indx], mags[3,indx], psym=8, color='red' else print, "no M"
ENDELSE
loadct, 0

;;overplot stellar locus
locusfile = getenv('QSO_DIR') + '/calib/loci/stellar_locus.fits'
locus_struct = mrdfits(locusfile, 1)
locus_set    = mrdfits(locusfile, 2)
n_model = 300
star_model = stellar_locus(locus_struct, locus_set, n_model $
                           , ug = ug_star, gr = gr_star, ri = ri_star $
                           , iz = iz_star, gi = gi_star)


IF keyword_set(ugr) THEN BEGIN
    oplot, ug_star, gr_star, linestyle=0, $
      thick= 3.*!P.CHARTHICK, color=djs_icolor('blue')
ENDIF ELSE IF keyword_set(gri) THEN BEGIN
    oplot, gr_star, ri_star, linestyle=0, $
      thick= 3.*!P.CHARTHICK, color=djs_icolor('blue')
ENDIF ELSE BEGIN
    oplot, ri_star, iz_star, linestyle=0, $
      thick= 3.*!P.CHARTHICK, color=djs_icolor('blue')
ENDELSE

END

