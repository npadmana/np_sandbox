PRO CREATE_CORE_SAMPLE, outfile, threshold=threshold, xdcoredir=xdcoredir
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'
IF ~keyword_set(threshold) THEN threshold= 0.4240

outStruct= {pqsomidz:-1D, run:0L,camcol:0L,rerun:'',field:0L,ID:0L,$
           ra:0D, dec:0D}
out= replicate(outStruct,1)

;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    print, "Working on run "+strtrim(string(run),2)
    filename= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)$
      +'.fits'
    if file_test(filename) then xd= mrdfits(filename,1) else continue
    keep= where(xd.pqsomidz gt threshold and xd.good eq 0 and $
                (xd.psfmag[1] LE 22. or xd.psfmag[2] LE 21.85) and $
                xd.psfmag[3] GE 17.8,count)
    if count eq 0 then continue
    thisout= replicate(outStruct,count)
    thisout.pqsomidz= xd[keep].pqsomidz
    thisout.run= xd[keep].run
    thisout.rerun= xd[keep].rerun
    thisout.camcol= xd[keep].camcol
    thisout.field= xd[keep].field
    thisout.ID= xd[keep].ID
    thisout.ra= xd[keep].ra
    thisout.dec= xd[keep].dec
    out= [out,thisout]
    print, "currently: "+strtrim(string(n_elements(out.run)-1),2)
ENDFOR

;;BOVY: Limit to BOSS footprint, mask hot pixels, remove bad
;;u-columns, and remove known quasars

mwrfits, out[1:n_elements(out.run)-1], outfile, /create
END
