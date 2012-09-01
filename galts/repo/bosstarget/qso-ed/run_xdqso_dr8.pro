;+
;   NAME:
;      run_xdqso_dr8
;   PURPOSE:
;      run the XDQSO code on all of the DR8 data sweeps
;   INPUT:
;      outdir - directory that will hold the output files
;   OPTIONAL INPUT:
;      minrun - start at this run (GT)
;      maxrun - stop at this run (LE)
;   KEYWORDS:
;      fitz - use XDQSOz
;      full - use 'full' star fits
;      multi - use 'multi' processors
;      primary - only work with primary objects
;      galex - use GALEX where available
;      ukidss - use UKIDSS where available
;      dr9 - use DR9
;      clean - use CLEAN (multi-epoch) photometry where available
;   OUTPUT:
;      (none)
;   HISTORY:
;      2011-01-28 - Started - Bovy (NYU)
;      2012-01-26 - Add GALEX - Bovy (IAS)
;      2012-06-08 - Add DR9 and clean - Bovy (IAS)
;-
PRO PREP_IVARS, sweep
_BIGVAR= 1D5
FOR ii=0L, n_elements(sweep[0].psfflux_ivar)-1 DO BEGIN
    badivar= where(sweep.psfflux_ivar[ii] EQ 0.)
    IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[ii]= 1D0/_BIGVAR
ENDFOR
END
PRO RUN_XDQSOZ_DR8_ONERUN, run, outname, full=full, primary=primary, $
                           galex=galex, ukidss=ukidss, dr9=dr9, $
                           clean=clean
if keyword_set(dr9) then sweepsdir= '/mount/coma1/bw55/sdss3/mirror/dr9/boss/sweeps/dr9/301/' else sweepsdir= '$SDSS_DATASWEEPS/'
;;Define structure, name it
IF keyword_set(primary) THEN $
  xdstruct= {xdqsoz, objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
             RA:0D, DEC:0D, allqsolike:0D, $
             starlike:0D, allqsonumber:0D, $
             starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
             pqso: 0D, bitmask:0LL,good:0,$
             photometric:0} ELSE $
  xdstruct= {xdqsoz, objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
             RA:0D, DEC:0D, allqsolike:0D, $
             starlike:0D, allqsonumber:0D, $
             starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
             pqso: 0D, bitmask:0LL,good:0,$
             primary:0,photometric:0}
IF keyword_set(galex) THEN xdstruct= struct_addtags(xdstruct,'galex_matched','0B')
IF keyword_set(galex) THEN xdstruct= struct_addtags(xdstruct,'galex_used','0B')
IF keyword_set(ukidss) THEN xdstruct= struct_addtags(xdstruct,'ukidss_matched','0B')
IF keyword_set(ukidss) THEN xdstruct= struct_addtags(xdstruct,'ukidss_used','0B')
IF keyword_set(clean) THEN xdstruct= struct_addtags(xdstruct,'clean_matched','bytarr(5)')
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
    sweep= exd_flagcuts(sweep,dr9=dr9)
    IF sweep[0].run EQ -1 THEN BEGIN
        splog, "Empty: run "+runstr+" camcol "+camcolstr
        CONTINUE
    ENDIF
    ;;cut to primary if desired
    IF keyword_set(primary) THEN BEGIN
        prim_indx= where(sweep.primary EQ 1, cnt)
        IF cnt eq 0 THEN BEGIN
            splog, "Empty: run "+runstr+" camcol "+camcolstr
            CONTINUE
        ENDIF
        sweep= sweep[prim_indx]
    ENDIF
    ;;switch to clean photometry where available
    if keyword_set(clean) and keyword_set(dr9) then begin
        nfilters= 5
        for jj=0L, nfilters-1 do begin
            cleanindx= where(sweep.psf_clean_nuse[jj] gt 1,cnt)
            if cnt gt 0 then begin
                sweep[cleanindx].psfflux[jj]= sweep[cleanindx].psfflux_clean[jj]
                sweep[cleanindx].psfflux_ivar[jj]= sweep[cleanindx].psfflux_clean_ivar[jj]
            endif
        endfor
    endif
    ;;Add galex or ukidss
    if keyword_set(galex) then begin
        galexdata= read_galex(run=run,camcol=ii+1)
    endif else begin
        galexdata= keyword_set(galex)
    endelse
    if keyword_set(ukidss) then begin
        ukidssdata= read_aux(run=run,/ukidss)
        if ukidssdata[0].run EQ -1 then ukidssdata= 0
    endif else begin
        ukidssdata= keyword_set(ukidss)
    endelse
    if keyword_set(galex) or keyword_set(ukidss) then begin
        comb= add_data(sweep,galexdata=galexdata,ukidssdata=ukidssdata)
    endif else begin
        comb= sweep
    endelse
    ;;Prep the ivars (zeros -> merely big)
    prep_ivars, sweep
    ;;run through qsoedz
    exdout= qsoedz_calculate_prob(comb,0.3,5.5,/nocuts,full=full,$
                                  galex=galex,ukidss=(n_tags(ukidssdata) NE 0))
    ;;also calculate lowz, midz, and hiz
    lowzlike= marginalize_colorzprob(0.000000000001,2.2,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=(n_tags(ukidssdata) NE 0))
    midzlike= marginalize_colorzprob(2.2,3.5,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=(n_tags(ukidssdata) NE 0))
    hizlike= marginalize_colorzprob(3.5,1000.5,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=(n_tags(ukidssdata) NE 0))
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
    IF ~keyword_set(primary) THEN thisout.primary= sweep.primary
    thisout.photometric= sweep.photometric
    thisout.allqsolike= exdout.allqsolike
    thisout.starlike= exdout.everythinglike
    thisout.allqsonumber= exdout.qsonumber
    thisout.starnumber= exdout.everythingnumber
    thisout.pqso= exdout.pqso
    thisout.pstar= 1D0-thisout.pqso
    thisout.pqsolowz= lowzlike/thisout.allqsolike*thisout.pqso
    thisout.pqsomidz= midzlike/thisout.allqsolike*thisout.pqso
    thisout.pqsohiz= hizlike/thisout.allqsolike*thisout.pqso
    ;;galex_matched and ukidss_matched
    iv = comb.psfflux_ivar
    if keyword_set(galex) then begin
        if keyword_set(ukidss) and n_tags(ukidssdata) ne 0 then begin
            ;;both available
            ukidss_matched_good = (iv[7,*] ne 1/1d5 or iv[8,*] ne 1/1d5 or iv[9,*] ne 1/1d5 or iv[10,*] ne 1/1d5)
            galex_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5)
            thisout.ukidss_matched = ukidss_matched_good[*]
            thisout.galex_matched = galex_matched_good[*]
        endif else begin
            galex_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5)
            thisout.galex_matched = galex_matched_good[*]
        endelse
    endif else if keyword_set(ukidss) and n_tags(ukidssdata) ne 0 then begin
        ukidss_matched_good = (iv[5,*] ne 1/1d5 or iv[6,*] ne 1/1d5 or iv[7,*] ne 1/1d5 or iv[8,*] ne 1/1d5)
        thisout.ukidss_matched = ukidss_matched_good[*]
    endif
    ;;galex_used and ukidss_used (which underlying model was used?)
    if keyword_set(galex) then thisout.galex_used= 1B
    if keyword_set(ukidss) and n_tags(ukidssdata) ne 0 then $
      thisout.ukidss_used= 1B
    ;;clean_matched
    if keyword_set(clean) and keyword_set(dr9) then begin
        for jj=0L, nfilters-1 do begin
            cleanindx= where(sweep.psf_clean_nuse[jj] gt 1,cnt)
            if cnt gt 0 then begin
                thisout[cleanindx].clean_matched[jj]= 1B
            endif
        endfor
    endif
    ;;add this camcol to the results
    xdout= [xdout,thisout]
ENDFOR
;;Write xdout to the appropriate fits file
IF n_elements(xdout.ra) GT 1 THEN mwrfits, xdout[1:n_elements(xdout.ra)-1], outname, /create
END
PRO RUN_XDQSO_DR8_ONERUN, run, outname, full=full, primary=primary
sweepsdir= '$SDSS_DATASWEEPS/'
;;Define structure, name it
IF keyword_set(primary) THEN $
xdstruct= {xdqso, objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
           RA:0D, DEC:0D, qsolowzlike:0D, qsohizlike:0D, qsomidzlike: 0D, $
           starlike:0D, qsolowznumber:0D, qsohiznumber:0D,qsomidznumber:0D, $
           starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
           pqso: 0D, bitmask:0LL,good:0,$
           photometric:0} ELSE $
  xdstruct= {xdqso, objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
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
    ;;cut to primary if desired
    IF keyword_set(primary) THEN BEGIN
        prim_indx= where(sweep.primary EQ 1, cnt)
        IF cnt eq 0 THEN BEGIN
            splog, "Empty: run "+runstr+" camcol "+camcolstr
            CONTINUE
        ENDIF
        sweep= sweep[prim_indx]
    ENDIF
    ;;Prep the ivars (zeros -> merely big)
    prep_ivars, sweep
    ;;run through exd
    exdout= qsoed_calculate_prob(sweep,/nocuts,full=full)
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
    IF ~keyword_set(primary) THEN thisout.primary= sweep.primary
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
PRO RUN_XDQSO_DR8, outdir=outdir, fitz=fitz, full=full, multi=multi, $
                   minrun=minrun, maxrun=maxrun, primary=primary, $
                   galex=galex, ukidss=ukidss, dr9=dr9, clean=clean
IF ~keyword_set(outdir) THEN outdir= '/mount/hydra4/jb2777/sdss/xdqsoz/core_primary/301/'
;;Get runs
runs= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/dr8runs.fits',1)
runs= runs.run
IF keyword_set(minrun) AND keyword_set(maxrun) THEN BEGIN
    runs= runs[where(runs GT minrun and runs LE maxrun)]
ENDIF ELSE IF keyword_set(minrun) THEN BEGIN
    runs= runs[where(runs GT minrun)]
ENDIF ELSE IF keyword_set(maxrun) THEN BEGIN
    runs= runs[where(runs LE maxrun)]
ENDIF
nruns= n_elements(runs)
IF ~keyword_set(multi) THEN BEGIN
    ;;Loop through runs
    FOR ii=0L, nruns-1 DO BEGIN
        run= runs[ii]
        outname= outdir+'xdqso'
        IF keyword_set(fitz) then outname+= 'z'
        outname+= '_'
        IF keyword_set(full) then outname+= 'full_'
        IF keyword_set(galex) then outname+= 'galex_'
        IF keyword_set(ukidss) then outname+= 'ukidss_'
        IF keyword_set(clean) then outname+= 'clean_'
        IF keyword_set(dr9) then outname+= 'dr9_'
        outname+= strtrim(string(run,format='(I6.6)'),2)+'.fits'
        IF ~file_test(outname) THEN BEGIN
            IF keyword_set(fitz) THEN run_xdqsoz_dr8_onerun, run, outname, $
              full=full, primary=primary, galex=galex, ukidss=ukidss, $
              dr9=dr9, clean=clean $
            ELSE $
              run_xdqso_dr8_onerun, run, outname, full=full, $
              primary=primary ;;galex=galex, ukidss=ukidss
        ENDIF
    ENDFOR
ENDIF ELSE BEGIN
    ;;approximate load balancing: get size of every sweep
    sizes= lonarr(nruns)
    if keyword_set(dr9) then sweepsdir= '/mount/coma1/bw55/sdss3/mirror/dr9/boss/sweeps/dr9/301/' else sweepsdir= '$SDSS_DATASWEEPS/'
    ncamcols= 6
    FOR ii=0L, nruns-1 DO BEGIN
        FOR jj=0L, ncamcols-1 DO BEGIN
            runstr= strtrim(string(runs[ii],format='(I6.6)'),2)
            camcolstr= strtrim(string(jj+1,format='(I1)'),2)
            sweepsfilename= sweepsdir+'calibObj-'+$
              runstr+'-'+$
              camcolstr+'-star.fits.gz'
            fileinfo= file_info(sweepsfilename)
            sizes[ii]+= fileinfo.size
        ENDFOR
    ENDFOR
    sizes= total(sizes,/cumul)
    sizes= sizes/double(sizes[nruns-1])
    cuts= lonarr(multi+1)
    FOR ii= 0L, multi-2 DO BEGIN
        cuts[ii+1]= max(runs[where(sizes LE (ii+1.)/multi)])
    ENDFOR
    cuts[multi]= max(runs)
    ;;run the various processes
    ii= 0
    procs= [obj_new('IDL_IDLBridge')]
    procs[ii]->SetVar, 'outdir', outdir
    procs[ii]->SetVar, 'fitz', keyword_set(fitz)
    procs[ii]->SetVar, 'full', keyword_set(full)
    procs[ii]->SetVar, 'galex', keyword_set(galex)
    procs[ii]->SetVar, 'ukidss', keyword_set(ukidss)
    procs[ii]->SetVar, 'dr9', keyword_set(dr9)
    procs[ii]->SetVar, 'clean', keyword_set(clean)
    procs[ii]->SetVar, 'primary', keyword_set(primary)
    procs[ii]->SetVar, 'minrun', cuts[ii]
    procs[ii]->SetVar, 'maxrun', cuts[ii+1]
    FOR ii=1L, multi-1 DO BEGIN
        procs= [procs,obj_new('IDL_IDLBridge')]
        procs[ii]->SetVar, 'outdir', outdir
        procs[ii]->SetVar, 'fitz', keyword_set(fitz)
        procs[ii]->SetVar, 'full', keyword_set(full)
        procs[ii]->SetVar, 'galex', keyword_set(galex)
        procs[ii]->SetVar, 'ukidss', keyword_set(ukidss)
        procs[ii]->SetVar, 'dr9', keyword_set(dr9)
        procs[ii]->SetVar, 'clean', keyword_set(clean)
        procs[ii]->SetVar, 'primary', keyword_set(primary)
        procs[ii]->SetVar, 'minrun', cuts[ii]
        procs[ii]->SetVar, 'maxrun', cuts[ii+1]
    ENDFOR
    ;;run everything
    count= 0
    catch, err_status
    IF err_status NE 0 THEN BEGIN  
        ;PRINT, 'Error index: ', err_status  
        ;PRINT, 'Error message: ', !ERROR_STATE.MSG  
        count+= 1
        if count EQ multi then CATCH, /CANCEL  
    ENDIF
    FOR ii=0L, multi-1 DO BEGIN
        IF count LT (ii+1) THEN BEGIN
            print, "Running process "+strtrim(string(ii+1),2)+" out of "+strtrim(string(multi),2)+" from run "+strtrim(string(cuts[ii],format='(I)'),2)+" to run "+strtrim(string(cuts[ii+1],format='(I)'),2)
            procs[ii]->Execute, 'RUN_XDQSO_DR8, outdir=outdir, fitz=fitz, full=full, minrun=minrun, maxrun=maxrun, primary=primary, galex=galex,ukidss=ukidss, dr9=dr9, clean=clean', /nowait
        ENDIF
    ENDFOR
    catch, /cancel
    ;;wait for them all to finish
    status= 1
    while status do begin
        wait, 5
        status= 0
        for ii=0L, multi-1 do begin
            if procs[ii]->Status() eq 1 then begin
                status= 1
                break
            endif
        endfor
    endwhile
    for ii=0L, multi-1 do obj_destroy, procs[ii]
ENDELSE
END
