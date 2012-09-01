PRO GOOD_TO_BITMASK, xdcoredir=xdcoredir,outdir=outdir
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'
IF ~keyword_set(outdir) THEN outdir= '/mount/hydra4/jb2777/sdss/xd/core_primary_goodbitmask/301/'

;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
FOR ii=0L, n_elements(runs)-1 DO BEGIN
    run= runs[ii]
    inname= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    outname= outdir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    IF file_test(inname) THEN xd= mrdfits(inname,1) ELSE CONTINUE
    badgood= where(xd.good EQ 2,cnt)
    IF cnt GT 0 THEN xd[badgood].good= 3L
    mwrfits, xd, outname, /create
ENDFOR

END
