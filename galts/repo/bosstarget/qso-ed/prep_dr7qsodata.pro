;+
;   NAME:
;      prep_dr7qsodata
;   PURPOSE:
;      create a file that has the fluxes, redshifts, and extinctions
;      for all of the QSOs in a useful form
;   INPUT:
;      filename - in-filename
;      savefilename - filename to save the result to
;   OUTPUT:
;      writes to file
;   HISTORY:
;      2010-05-13 - Written - Bovy (NYU)
;-
PRO PREP_DR7QSODATA, filename, savefilename=savefilename
b_u = 1.4
b_g = 0.9
b_r = 1.2
b_i = 1.8
b_z = 7.4

in= mrdfits(filename,1)
ndata= n_elements(in.z)
psfflux= dblarr(5,ndata)
psfflux_ivar= dblarr(5,ndata)
mags= dblarr(5,ndata)
magerr= dblarr(5,ndata)
FOR ii=0L, ndata-1 DO BEGIN
    EBV= in[ii].au/5.155D
    uext= in[ii].au
    gext= 3.793D*EBV
    rext= 2.751D*EBV
    iext= 2.086D*EBV
    zext= 1.479D*EBV

    mags[0,ii]= in[ii].umag-uext
    mags[1,ii]= in[ii].gmag-gext
    mags[2,ii]= in[ii].rmag-rext
    mags[3,ii]= in[ii].imag-iext
    mags[4,ii]= in[ii].zmag-zext

    magerr[0,ii]= in[ii].umagerr
    magerr[1,ii]= in[ii].gmagerr
    magerr[2,ii]= in[ii].rmagerr
    magerr[3,ii]= in[ii].imagerr
    magerr[4,ii]= in[ii].zmagerr

    psfflux[0,ii]= sdss_mags2flux(in[ii].umag-uext,b_u)
    psfflux[1,ii]= sdss_mags2flux(in[ii].gmag-gext,b_g)
    psfflux[2,ii]= sdss_mags2flux(in[ii].rmag-rext,b_r)
    psfflux[3,ii]= sdss_mags2flux(in[ii].imag-iext,b_i)
    psfflux[4,ii]= sdss_mags2flux(in[ii].zmag-zext,b_z)
    
    psfflux_ivar[0,ii]= sdss_magerr2ivar(in[ii].umagerr,mags[0,ii],b_u)
    psfflux_ivar[1,ii]= sdss_magerr2ivar(in[ii].gmagerr,mags[1,ii],b_g)
    psfflux_ivar[2,ii]= sdss_magerr2ivar(in[ii].rmagerr,mags[2,ii],b_r)
    psfflux_ivar[3,ii]= sdss_magerr2ivar(in[ii].imagerr,mags[3,ii],b_i)
    psfflux_ivar[4,ii]= sdss_magerr2ivar(in[ii].zmagerr,mags[4,ii],b_z)
ENDFOR

outStruct= {ra:0D, dec:0D, psfflux:dblarr(5), psfflux_ivar:dblarr(5),$
            z:0D, mags:dblarr(5), magerr:dblarr(5), bestid:'', $
            specoid: '', oname: ''}
out= replicate(outStruct,ndata)
out.ra= in.ra
out.dec= in.dec
out.psfflux= psfflux
out.psfflux_ivar= psfflux_ivar
out.z= in.z
out.bestid= in.bestid
out.specoid= in.specoid
out.oname= in.oname
out.mags= mags
out.magerr= magerr
mwrfits, out, savefilename, /create
END
