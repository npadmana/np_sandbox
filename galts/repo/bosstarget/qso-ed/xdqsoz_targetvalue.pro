FUNCTION XDQSOZ_TARGETVALUE, in, galex=galex, ukidss=ukidss
;;read quasar value table
readcol, '$BOVYQSOEDDATA/quasarvalue.txt', z,g,v,format='F,F,F'
g= long(10*g)
ndata= n_elements(in.psfflux[0])
flux= sdss_deredden(in.psfflux,in.extinction)
flux_ivar=sdss_deredden_error(in.psfflux_ivar,in.extinction)
;;Read the differential number counts
dataDir= '$BOSSTARGET_DIR/data/qso-ed/numcounts/'
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07'
dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
dndi_qsofile= dndipath(3.5,6.,lumfunc)
dndi_qsolowzfile= dndipath(0.3,2.2,lumfunc)
dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'
read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything
;;calculate total star and quasar probabilities
qsolike= marginalize_colorzprob(0.3,5.5,flux,flux_ivar,galex=galex,ukidss=ukidss,norm=allqsolike)
bossqsonumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)
qsonumber= eval_iprob(flux[3,*],i_qso,dndi_qso)
qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)
qsonumber= bossqsonumber+qsonumber+qsolowznumber
everythinglike= eval_colorprob(flux,flux_ivar,galex=galex,ukidss=ukidss,full=full)
everythingnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)
;;now calculate expected value
out= dblarr(ndata)
FOR ii=0L, ndata-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,ndata,string(13B)
    ;;get redshift pdf
    xdqsoz_zpdf, flux[*,ii], flux_ivar[*,ii], $
      galex=galex, ukidss=ukidss, $
      zmean=zmean, zcovar=zcovar, zamp=zamp
    ;;find relevant line in quasarvalue
    thisg= (sdss_flux2mags(flux[1,ii],0.9))[0]
    vg= long(round(thisg*10.))
    line= where(g EQ vg,cnt)
    if cnt eq 0 then continue
    ;;integrate
    thisz= z[line]
    thisv= v[line]
    nzs= n_elements(thisz)
    FOR zz=0L, nzs-1 DO out[ii]+= eval_xdqsoz_zpdf(thisz[zz],zmean,zcovar,zamp)*thisv[zz]
    out[ii]*= (thisz[1]-thisz[0])
ENDFOR
;;normalize correctly
nonzero= where(out NE 0.)
IF nonzero[0] NE -1 THEN out[nonzero]*= qsolike[nonzero]*qsonumber[nonzero]/(everythinglike[nonzero]*everythingnumber[nonzero]+qsolike[nonzero]*qsonumber[nonzero])
RETURN, out
END
