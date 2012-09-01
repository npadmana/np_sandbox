PRO run_flagcuts_dr8
sweepsdir= '$SDSS_DATASWEEPS/'
;;Get runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run

;;Loop through runs
nruns= n_elements(runs)
ncamcols= 6
N= 0
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    FOR jj=0L, ncamcols-1 DO BEGIN
        runstr= strtrim(string(run,format='(I6.6)'),2)
        camcolstr= strtrim(string(jj+1,format='(I1)'),2)
        sweepsfilename= sweepsdir+'calibObj-'+$
          runstr+'-'+$
          camcolstr+'-star.fits.gz'
        sweep= mrdfits(sweepsfilename,1)
        sweep= exd_flagcuts(sweep)
        if sweep[0].run NE -1 THEN N+= n_elements(sweep.ra)
        print, N
    ENDFOR
ENDFOR
print, "Total number of objects", N
END
