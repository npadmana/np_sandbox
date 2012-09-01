PRO RUN_STR82_FORNATHALIE, outfile
; softening parameters for S82 from DR7 paper in units of 1.0e-10
b_u = 0.1
b_g = 0.043
b_r = 0.081
b_i = 0.14
b_z = 0.37
;
inStr= {ra:0D, dec:0D, $
        psfflux: dblarr(5), $
        psfflux_ivar: dblarr(5), $
        extinction: dblarr(5), $
        type: 0L}
xdStr= xdqso_calculate_prob(inStr)
out= struct_combine(inStr,xdStr); sets output structure, non-sensical first entry will be dropped at the end
;;read data files
datafiles= ['$BOVYQSOEDDATA/Str82_36_39_ForXD.txt', $
            '$BOVYQSOEDDATA/Str82_39_42_ForXD.txt']
FMT='F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,I'
FOR ii=0L, 1 DO BEGIN
    readcol, datafiles[ii], ra, dec, u, g, r, i, z, Err_u, Err_g, Err_r, Err_i, Err_z, Ext_u,  Ext_g, Ext_r, Ext_i, Ext_z, type, format=FMT, delimiter=' '
    ;;create structure
    in= replicate(inStr,n_elements(u))
    in.ra= ra
    in.dec= dec
    in.psfflux[0]= sdss_mags2flux(u,b_u)
    in.psfflux_ivar[0]= sdss_magerr2ivar(Err_u,u,b_u)
    in.extinction[0]= Ext_u
    in.psfflux[1]= sdss_mags2flux(g,b_g)
    in.psfflux_ivar[1]= sdss_magerr2ivar(Err_g,g,b_g)
    in.extinction[1]= Ext_g
    in.psfflux[2]= sdss_mags2flux(r,b_r)
    in.psfflux_ivar[2]= sdss_magerr2ivar(Err_r,r,b_r)
    in.extinction[2]= Ext_r
    in.psfflux[3]= sdss_mags2flux(i,b_i)
    in.psfflux_ivar[3]= sdss_magerr2ivar(Err_i,i,b_i)
    in.extinction[3]= Ext_i
    in.psfflux[4]= sdss_mags2flux(z,b_z)
    in.psfflux_ivar[4]= sdss_magerr2ivar(Err_z,z,b_z)
    in.extinction[4]= Ext_z
    in.type= type
    ;;run through XDQSO
    xd= xdqso_calculate_prob(in)
    out= [out,struct_combine(in,xd)]
ENDFOR
mwrfits, out[1:n_elements(out)-1], outfile,/create
END
