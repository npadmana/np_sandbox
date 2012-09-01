PRO CUT_XDCORE_PRIMARY, xdcoredir=xdcoredir,outdir=outdir
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core/301/'
IF ~keyword_set(outdir) THEN outdir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'

;;Out structure
outstruct= {objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
            RA:0D, DEC:0D, qsolowzlike:0D, qsohizlike:0D, qsomidzlike: 0D, $
            starlike:0D, qsolowznumber:0D, qsohiznumber:0D,qsomidznumber:0D, $
            starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
            pqso: 0D, bitmask:0LL,good:0,photometric:0,$
            psfmag:dblarr(5),psfmagerr:dblarr(5),extinction_u:0D}


;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
FOR ii=0L, n_elements(runs)-1 DO BEGIN
    run= runs[ii]
    inname= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    outname= outdir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    xd= mrdfits(inname,1)
    ;;Cut to primary
    prim= where(xd.primary EQ 1, nprim)
    IF nprim GT 0 THEN BEGIN
        xd= xd[prim]
        out= replicate(outstruct,nprim)
        out.objId= xd.objId
        out.run= xd.run
        out.rerun= xd.rerun
        out.camcol= xd.camcol
        out.field= xd.field
        out.ID= xd.ID
        out.RA= xd.RA
        out.DEC= xd.DEC
        out.qsolowzlike= xd.qsolowzlike
        out.qsohizlike= xd.qsohizlike
        out.qsomidzlike= xd.qsomidzlike
        out.starlike= xd.starlike
        out.qsolowznumber= xd.qsolowznumber
        out.qsohiznumber= xd.qsohiznumber
        out.qsomidznumber= xd.qsomidznumber
        out.starnumber= xd.starnumber
        out.pstar= xd.pstar
        out.pqsolowz= xd.pqsolowz
        out.pqsomidz= xd.pqsomidz
        out.pqsohiz= xd.pqsohiz
        out.pqso= xd.pqso
        out.bitmask= xd.bitmask
        out.good= xd.good
        out.photometric= xd.photometric
        ;;match to sweeps
        calibobj= read_calibobj(run)
        oid= sdss_photoid(out)
        cid= sdss_photoid(calibobj)
        match, oid, cid, oindx, cindx, /sort
        prep_data, calibobj[cindx].psfflux, calibobj[cindx].psfflux_ivar, $
          extinction= calibobj[cindx].extinction, $
          mags=mags, var_mags=var_mags
        out[oindx].psfmag= mags
        out[oindx].psfmagerr= sqrt(var_mags)
        out[oindx].extinction_u= calibobj[cindx].extinction[0]
        mwrfits, out, outname, /create
    ENDIF
ENDFOR

END
