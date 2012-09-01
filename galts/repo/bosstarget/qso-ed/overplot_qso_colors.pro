;+
;   NAME:
;      overplot_qso_colors
;   PURPOSE:
;      overplot the quasar color locus etc
;   INPUT:
;      /ugr, /gri, /riz - indicates which color-color diagram we're
;                         talking about
;   OUTPUT:
;   HISTORY:
;      2010-11-17 - Written - Bovy
;-
PRO OVERPLOT_QSO_COLORS, ugr=ugr, gri=gri, riz=riz

;;overplot qso locus
colorzfile = getenv('QSO_DIR') + '/calib/loci/colorz_locus.fits'
colorz_struct = mrdfits(colorzfile, 1)
colorz_set    = mrdfits(colorzfile, 2)
nz = 400L
Z_MIN = 0.5D
Z_MAX = 5.D
z_arr = Z_MIN + (Z_MAX-Z_MIN)*dindgen(nz+1L)/double(nz)
qso_model = qso_colorz(z_arr, colorz_struct, colorz_set $
                       , ug = ug_qso, gr = gr_qso, ri = ri_qso $
                       , iz = iz_qso, gi = gi_qso $
                       , sig_ug = sig_ug_qso, sig_gr = sig_gr_qso $
                       , sig_ri = sig_ri_qso, sig_iz = sig_iz_qso $
                       , sig_gi = sig_gi_qso)
colors = Round(Scale_Vector(Findgen(nz), 0, 255))
loadct, 34

;;overplot known qsos
known= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
zmin= 2.5
known= known[where(known.z GE zmin and known.z LE z_max)]
;;Cut to random sampling
x= lindgen(n_elements(known.ra))
y= randomu(seed,n_elements(known.ra))
z= x[sort(y)]
z= z[0:floor(0.2*n_elements(known.ra))-1]
known= known[z]
nknown= n_elements(known.ra)
prep_data, known.psfflux, known.psfflux_ivar, mags=mags,var_mags=var_mags,/colors

phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
IF keyword_set(ugr) THEN BEGIN
    for ii=0L, nknown-1 do begin
        size= 0.15+(known[ii].z-zmin)/(5.-zmin)*0.35
        usersym, size*cos(phi), size*sin(phi), /fill
        djs_oplot, [mags[0,ii]], [mags[1,ii]], $
          color=floor((known[ii].z-z_min)/(z_max-z_min)*255), psym=8
    endfor
endif ELSE IF keyword_set(gri) THEN BEGIN
    for ii=0L, nknown-1 do begin
        size= 0.15+(known[ii].z-zmin)/(5.-zmin)*0.35
        usersym, size*cos(phi), size*sin(phi), /fill
        djs_oplot, [mags[1,ii]], [mags[2,ii]], $
          color=floor((known[ii].z-z_min)/(z_max-z_min)*255), psym=8
    endfor
ENDIF ELSE BEGIN
    for ii=0L, nknown-1 do begin
        size= 0.15+(known[ii].z-zmin)/(5.-zmin)*0.35
        usersym, size*cos(phi), size*sin(phi), /fill
        djs_oplot, [mags[2,ii]], [mags[3,ii]], $
          color=floor((known[ii].z-z_min)/(z_max-z_min)*255), psym=8
    endfor
ENDELSE


IF keyword_set(ugr) THEN BEGIN
    ug_indx= where(z_arr LE colorz_struct.z_drop_g)
    x= ug_qso[ug_indx]
    y= gr_qso[ug_indx]
    ;Device, Decomposed=0, Get_Decomposed=theState
    FOR j=0,n_elements(ug_indx)-2 DO BEGIN
        IF x[j] GT !X.CRANGE[1] OR x[j+1] GT !X.CRANGE[1] OR x[j] LT !X.CRANGE[0] or x[j+1] LT !X.CRANGE[0] OR y[j] GT !Y.CRANGE[1] OR y[j+1] GT !Y.CRANGE[1] OR y[j] LT !Y.CRANGE[0] or y[j+1] LT !Y.CRANGE[0] THEN CONTINUE
        PlotS, [x[j], x[j+1]], [y[j], y[j+1]], Color=colors[j], Thick=6*!P.CHARTHICK
    ENDFOR
    oplot, ug_qso[ug_indx], gr_qso[ug_indx], linestyle=2, $
      thick= 1.1*!P.CHARTHICK
    ;Device, Decomposed=theState
ENDIF ELSE IF keyword_set(gri) THEN BEGIN
    x= gr_qso
    y= ri_qso
    ;Device, Decomposed=0, Get_Decomposed=theState
    FOR j=0,nz-2 DO BEGIN
        IF x[j] GT !X.CRANGE[1] OR x[j+1] GT !X.CRANGE[1] OR x[j] LT !X.CRANGE[0] or x[j+1] LT !X.CRANGE[0] OR y[j] GT !Y.CRANGE[1] OR y[j+1] GT !Y.CRANGE[1] OR y[j] LT !Y.CRANGE[0] or y[j+1] LT !Y.CRANGE[0] THEN CONTINUE
        PlotS, [x[j], x[j+1]], [y[j], y[j+1]], Color=colors[j], Thick=6*!P.CHARTHICK
    ENDFOR
    oplot, gr_qso, ri_qso, linestyle=2, $
      thick= 1.1*!P.CHARTHICK
    ;Device, Decomposed=theState
ENDIF ELSE BEGIN
    x= ri_qso
    y= iz_qso
    ;Device, Decomposed=0, Get_Decomposed=theState
    FOR j=0,nz-2 DO BEGIN
        IF x[j] GT !X.CRANGE[1] OR x[j+1] GT !X.CRANGE[1] OR x[j] LT !X.CRANGE[0] or x[j+1] LT !X.CRANGE[0] OR y[j] GT !Y.CRANGE[1] OR y[j+1] GT !Y.CRANGE[1] OR y[j] LT !Y.CRANGE[0] or y[j+1] LT !Y.CRANGE[0] THEN CONTINUE
        PlotS, [x[j], x[j+1]], [y[j], y[j+1]], Color=colors[j], Thick=6*!P.CHARTHICK
    ENDFOR
    oplot, ri_qso, iz_qso, linestyle=2, $
      thick= 1.1*!P.CHARTHICK
    ;Device, Decomposed=theState
ENDELSE




loadct, 0
END

