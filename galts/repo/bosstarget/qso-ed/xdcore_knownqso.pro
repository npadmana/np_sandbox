;+
;   NAME:
;      xdcore_knownqso
;   PURPOSE:
;      see how XD core does on known QSOs
;   INPUT:
;      infile - file of known QSOs
;      outfile - store output in this file
;      maxd= - spherematch distance
;   OUTPUT:
;      (none)
;   HISTORY:
;      2010-08-20 - Written - Bovy (NYU)
;-
PRO XDCORE_KNOWNQSO, infile, outfile, maxd=maxd, xdcoredir=xdcoredir
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'
IF ~keyword_set(maxd) THEN maxd= 1.5/3600.

in= mrdfits(infile,1)

xdstruct= {pstar:-1D, pqsolowz:-1D, pqsomidz:-1D, pqsohiz:-1D, $
           pqso: -1D,run:0L,camcol:0L,rerun:'',field:0L,ID:0L}
xdout= replicate(xdstruct,n_elements(in.ra))

;;Loop through runs, match
;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    print, "Working on run "+strtrim(string(run),2)
    filename= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
    if file_test(filename) then xd= mrdfits(filename,1) else continue
    ;;spherematch
    spherematch, xd.ra, xd.dec, in.ra, in.dec, maxd, xindx, iindx
    if xindx[0] EQ -1 then continue
    xdout[iindx].pstar= xd[xindx].pstar
    xdout[iindx].pqsolowz= xd[xindx].pqsolowz
    xdout[iindx].pqsomidz= xd[xindx].pqsomidz
    xdout[iindx].pqsohiz= xd[xindx].pqsohiz
    xdout[iindx].pqso= xd[xindx].pqso
    xdout[iindx].run= xd[xindx].run
    xdout[iindx].camcol= xd[xindx].camcol
    xdout[iindx].rerun= xd[xindx].rerun
    xdout[iindx].field= xd[xindx].field
    xdout[iindx].id= xd[xindx].id
ENDFOR

;;Save
out= struct_combine(in,xdout)
mwrfits, out, outfile, /create
END
