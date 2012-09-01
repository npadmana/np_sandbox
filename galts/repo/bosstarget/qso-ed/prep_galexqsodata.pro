;+
;   NAME:
;      prep_galexqsodata
;   PURPOSE:
;      basically, extinction correct the galex QSO fluxes
;   INPUT:
;      galexfilename - file that has the galex QSO data
;   OUTPUT:
;      savefilename - fits file with galex fluxes, extinction corrected
;   HISTORY:
;      2010-05-27 - Written - Bovy (NYU)
;-
PRO PREP_GALEXQSODATA, galexfilename=galexfilename, $
                       savefilename=savefilename
IF ~keyword_set(galexfilename) THEN galexfilename= '$BOVYQSOEDDATA/sdss_qsos_sdss_galex.fits'
galexdata= mrdfits(galexfilename,1)

;;Match
nout= n_elements(galexdata.ra)

outStruct= {ra: 0D, dec: 0D, status:0L, fuv_flux: 0D, $
            fuv_formal_fluxerr:0D, fuv_fluxerr: 0D, $
            nuv_flux: 0D, nuv_formal_fluxerr:0D, $
            nuv_fluxerr: 0D, psfflux:dblarr(5), $
            psfflux_ivar: dblarr(5)}
out= replicate(outStruct,nout)
out.ra= galexdata.ra
out.dec= galexdata.dec
out.status= galexdata.status
out.psfflux= galexdata.psfflux
out.psfflux_ivar= galexdata.psfflux_ivar

;;Extinction correct
glactc, out.ra, out.dec, 2000.0, gl, gb, 1, /degree
ebv= dust_getval(gl, gb,/interp)
out.nuv_flux= sdss_deredden(galexdata.nuv_flux,ebv*8.18D)
out.fuv_flux= sdss_deredden(galexdata.fuv_flux,ebv*8.29D)
nonzero= where(galexdata.nuv_formal_fluxerr NE 0.)
out[nonzero].nuv_formal_fluxerr= (sdss_deredden_error(1./galexdata[nonzero].nuv_formal_fluxerr^2D0,ebv*8.18D))^(-0.5D)
nonzero= where(galexdata.nuv_fluxerr NE 0.)
out[nonzero].nuv_fluxerr= (sdss_deredden_error(1./galexdata[nonzero].nuv_fluxerr^2D0,ebv*8.18D))^(-0.5D)
nonzero= where(galexdata.fuv_formal_fluxerr NE 0.)
out[nonzero].fuv_formal_fluxerr= (sdss_deredden_error(1./galexdata[nonzero].fuv_formal_fluxerr^2D0,ebv*8.29D))^(-0.5D)
nonzero= where(galexdata.fuv_fluxerr NE 0.)
out[nonzero].fuv_fluxerr= (sdss_deredden_error(1./galexdata[nonzero].fuv_fluxerr^2D0,ebv*8.29D))^(-0.5D)


mwrfits, out, savefilename, /create
END
