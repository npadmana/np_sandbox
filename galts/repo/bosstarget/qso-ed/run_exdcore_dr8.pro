;+
;   NAME:
;      run_exdcore_dr8
;   PURPOSE:
;      run the ExD CORE code on all of the DR8 data sweeps
;   INPUT:
;      outdir - directory that will hold the output files
;   OUTPUT:
;      (none)
;   HISTORY:
;      2010-07-26 - Started - Bovy (NYU)
;-
PRO PREP_IVARS, sweep
_BIGVAR= 1D5
badivar= where(sweep.psfflux_ivar[0] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[0]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[1] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[1]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[2] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[2]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[3] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[3]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[4] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[4]= 1D0/_BIGVAR
END
PRO RUN_EXDCORE_DR8_ONERUN, run, outname
sweepsdir= '$SDSS_DATASWEEPS/'
;;Define structure, name it
xdstruct= {xdcore, objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
           RA:0D, DEC:0D, qsolowzlike:0D, qsohizlike:0D, qsomidzlike: 0D, $
           starlike:0D, qsolowznumber:0D, qsohiznumber:0D,qsomidznumber:0D, $
           starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
           pqso: 0D, bitmask:0LL,good:0,$
           primary:0,photometric:0}
xdout= replicate(xdstruct,1)
ncamcols= 6
FOR ii=0L, ncamcols-1 DO BEGIN
    runstr= strtrim(string(run,format='(I6.6)'),2)
    camcolstr= strtrim(string(ii+1,format='(I1)'),2)
    sweepsfilename= sweepsdir+'calibObj-'+$
      runstr+'-'+$
      camcolstr+'-star.fits.gz'
    sweep= mrdfits(sweepsfilename,1)
    splog, "Working on run "+runstr+" and camcol "+camcolstr+": "+$
      strtrim(string(n_elements(sweep.ra)),2)+" objects"
    ;;Perform flag cuts + magnitude cuts
    sweep= exd_flagcuts(sweep)
    IF sweep[0].run EQ -1 THEN BEGIN
        splog, "Empty: run "+runstr+" camcol "+camcolstr
        CONTINUE
    ENDIF
    ;;Prep the ivars (zeros -> merely big)
    prep_ivars, sweep
    ;;run through exd
    exdout= qsoed_calculate_prob(sweep,/nocuts)
    ;;Create output
    nout= n_elements(exdout.pqso)
    thisout= replicate(xdstruct,nout)
    thisout.run= sweep.run
    thisout.rerun= sweep.rerun
    thisout.camcol= sweep.camcol
    thisout.field= sweep.field
    thisout.id= sweep.id
    objid= strarr(nout)
    FOR jj=0L, nout-1 DO objid[jj]= sdss_objid(sweep[jj].run, $
                                               sweep[jj].camcol, $
                                               sweep[jj].field, $
                                               sweep[jj].id, $
                                               rerun=sweep[jj].rerun)
    thisout.objid= objid
    thisout.ra= sweep.ra
    thisout.dec= sweep.dec
    thisout.bitmask= sweep.bitmask
    thisout.good= sweep.good
    thisout.primary= sweep.primary
    thisout.photometric= sweep.photometric
    thisout.qsolowzlike= exdout.qsolowzlike
    thisout.qsohizlike= exdout.qsolike
    thisout.qsomidzlike= exdout.bossqsolike
    thisout.starlike= exdout.everythinglike
    thisout.qsolowznumber= exdout.qsolowznumber
    thisout.qsohiznumber= exdout.qsonumber
    thisout.qsomidznumber= exdout.bossqsonumber
    thisout.starnumber= exdout.everythingnumber
    pstar= thisout.starlike*thisout.starnumber
    nonzero= where(pstar NE 0.)
    IF nonzero[0] NE -1 THEN pstar[nonzero]= pstar[nonzero]/$
      (thisout[nonzero].qsolowzlike*thisout[nonzero].qsolowznumber+$
       thisout[nonzero].qsohizlike*thisout[nonzero].qsohiznumber+$
       thisout[nonzero].qsomidzlike*thisout[nonzero].qsomidznumber+$
       thisout[nonzero].starlike*thisout[nonzero].starnumber)
    thisout.pstar= pstar
    pqsolowz= thisout.qsolowzlike*thisout.qsolowznumber
    nonzero= where(pqsolowz NE 0.)
    IF nonzero[0] NE -1 THEN pqsolowz[nonzero]= pqsolowz[nonzero]/$
      (thisout[nonzero].qsolowzlike*thisout[nonzero].qsolowznumber+$
       thisout[nonzero].qsohizlike*thisout[nonzero].qsohiznumber+$
       thisout[nonzero].qsomidzlike*thisout[nonzero].qsomidznumber+$
       thisout[nonzero].starlike*thisout[nonzero].starnumber)
    thisout.pqsolowz= pqsolowz
    pqsohiz= thisout.qsohizlike*thisout.qsohiznumber
    nonzero= where(pqsohiz NE 0.)
    IF nonzero[0] NE -1 THEN pqsohiz[nonzero]= pqsohiz[nonzero]/$
      (thisout[nonzero].qsolowzlike*thisout[nonzero].qsolowznumber+$
       thisout[nonzero].qsohizlike*thisout[nonzero].qsohiznumber+$
       thisout[nonzero].qsomidzlike*thisout[nonzero].qsomidznumber+$
       thisout[nonzero].starlike*thisout[nonzero].starnumber)
    thisout.pqsohiz= pqsohiz
    pqsomidz= thisout.qsomidzlike*thisout.qsomidznumber
    nonzero= where(pqsomidz NE 0.)
    IF nonzero[0] NE -1 THEN pqsomidz[nonzero]= pqsomidz[nonzero]/$
      (thisout[nonzero].qsolowzlike*thisout[nonzero].qsolowznumber+$
       thisout[nonzero].qsohizlike*thisout[nonzero].qsohiznumber+$
       thisout[nonzero].qsomidzlike*thisout[nonzero].qsomidznumber+$
       thisout[nonzero].starlike*thisout[nonzero].starnumber)
    thisout.pqsomidz= pqsomidz
    thisout.pqso= thisout.pqsolowz+thisout.pqsomidz+thisout.pqsohiz
    ;;add this camcol to the results
    xdout= [xdout,thisout]
ENDFOR
;;Write xdout to the appropriate fits file
IF n_elements(xdout.ra) GT 1 THEN mwrfits, xdout[1:n_elements(xdout.ra)-1], outname, /create
END
PRO RUN_EXDCORE_DR8, outdir=outdir
IF ~keyword_set(outdir) THEN outdir= '/mount/hydra4/jb2777/sdss/xd/core/301/'

;;Get runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run

;;Loop through runs
nruns= n_elements(runs)
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    outname= outdir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    IF ~file_test(outname) THEN run_exdcore_dr8_onerun, run, outname
ENDFOR
END
