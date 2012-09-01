PRO CONSTRUCT_XDSTARCATALOG, tempfile, starcut=starcut, icut=icut, $
                             frac=frac

IF ~keyword_set(starcut) THEN starcut=0.99
IF ~keyword_set(frac) THEN frac= 1.
;;Now run through the XD targets, and select them
IF ~file_test(tempfile) THEN BEGIN
    IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xdqsoz/core_primary/301/'
    IF ~keyword_set(filebasename) THEN filebasename= 'xdqsoz'
    ;;Runs
    runs= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/dr8runs.fits',1)
    runs= runs.run
    nruns= n_elements(runs)
    ;;outstruct
    xd= mrdfits(xdcoredir+filebasename+'_'+strtrim(string(runs[0],format='(I6.6)'),2)+'.fits',1)
    out= xd[0]
    ;;Loop through runs, save everything that could be a star
    FOR ii=0L, nruns -1 DO BEGIN
        run= runs[ii]
        print, format = '("Working on ",i7," of ",i7,a1,$)', $
          ii+1,nruns,string(13B)
        filename= xdcoredir+filebasename+'_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
        if file_test(filename) then xd= mrdfits(filename,1,/silent) else continue
        keep= where(xd.good EQ 0,cnt)
        IF cnt EQ 0 then continue
        xd= xd[keep]
        if keyword_set(icut) then begin
            ;;match to sweep for iband mag
            sweep= read_calibobj(run,/silent)
            spherematch, xd.ra, xd.dec, sweep.ra, sweep.dec, 2./3600., $
              xindx, sindx
            xd= xd[xindx]
            sweep= sweep[sindx]
            prep_data, sweep.psfflux, sweep.psfflux_ivar, $
              extinction=sweep.extinction, mags=mags, var_mags=mags_var
            keep= where(mags[3,*] LE 21.3,cnt)
            IF cnt EQ 0 THEN continue
            xd= xd[keep]
        endif
        keep= where(xd.pstar GE starcut,cnt)
        IF cnt EQ 0 then continue
        ;;take frac sample
        IF frac LT 1 THEN BEGIN
            x= lindgen(cnt)
            y= randomu(seed,cnt)
            keep= keep[(x[sort(y)])[0:floor(frac*cnt)-1]]
        ENDIF
        out= [out,xd[keep]]
        print, "Current number of objects: ", n_elements(out.ra)-1
    ENDFOR
    out= out[1:n_elements(out.ra)-1]
    mwrfits, out, tempfile, /create
    xd= out
ENDIF ELSE BEGIN
    print, "'tempfile' exists, returning ..."
ENDELSE


END
