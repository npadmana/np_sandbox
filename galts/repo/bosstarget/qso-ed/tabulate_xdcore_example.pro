;+
;   NAME:
;      tabulate_xdcore_example
;   PURPOSE:
;      give an example of the SDSS-XDQSO catalog
;   INPUT:
;      run - run number
;      nentries -number of entries to include in the table
;      outfile - filename for table
;   OUTPUT:
;      table in outfile
;   HISTORY:
;      2010-08-31 - Written - Bovy (NYU)
;-
PRO TABULATE_XDCORE_EXAMPLE, outfile, run=run, nentries=nentries, $
                             xdcoredir=xdcoredir
IF ~keyword_set(run) THEN run= 1345
IF ~keyword_set(nentries) THEN nentries= 20
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core/301/'

;;Open catalog
outname= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
xd= mrdfits(outname,1)

;;Open file for writing
OPENW, wlun, outfile, /GET_LUN
parameterformat=strarr(20)
END
