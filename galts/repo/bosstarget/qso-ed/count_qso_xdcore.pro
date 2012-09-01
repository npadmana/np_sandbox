PRO COUNT_QSO_XDCORE, xdcoredir=xdcoredir, outfile=outfile
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'

;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)

outStruct= {run:0L,ntotal:0LL,nqso:0D,nqsolowz:0D,nqsomidz:0D,nqsohiz:0D}
out= replicate(outStruct,nruns)

;;Loop through, accumulate
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    print, "Working on run "+strtrim(string(run),2)
    filename= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    if file_test(filename) then xd= mrdfits(filename,1) else continue
    out[ii].run= run
    out[ii].ntotal= n_elements(xd.ra)
    indx= where(finite(xd.pqso))
    out[ii].nqso= total(xd[indx].pqso)
    out[ii].nqsolowz= total(xd[indx].pqsolowz)
    out[ii].nqsomidz= total(xd[indx].pqsomidz)
    out[ii].nqsohiz= total(xd[indx].pqsohiz)
ENDFOR

print, "total: ", total(out.ntotal)
print, "total QSO: ", total(out.nqso)
print, "total QSO-lowz: ", total(out.nqsolowz)
print, "total QSO-midz: ", total(out.nqsomidz)
print, "total QSO-hiz: ", total(out.nqsohiz)

IF keyword_set(outfile) THEN mwrfits, out, outfile, /create

END
