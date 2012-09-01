;+
;   NAME:
;      match_known_sweeps
;   PURPOSE:
;      match the known QSO/star to the data sweeps
;   INPUT:
;      knownfile - filename
;      outfile - filename
;   OUTPUT:
;      combined file with sweeps info added in outfile
;   HISTORY:
;      2010-08-31 - Written - Bovy (NYU)
;-
PRO MATCH_KNOWN_SWEEPS, knownfile, outfile
;;Read data
data= mrdfits(knownfile,1)
ndata= n_elements(data.ra)
;;Added tags
calib= read_calibobj(94,camcol=1)
extraStruct= calib[0]
extra= replicate(extraStruct,ndata)
extra.run= -1
;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)
;;Loop through runs
bq = obj_new('bosstarget_qso');;for flag logic
FOR ii=0L, nruns-1 DO BEGIN
    run= runs[ii]
    print, "Working on run "+strtrim(string(run),2)
    calibobj= read_calibobj(run)
    ;;limit to things that are survey primary and photometric
    resolve_bitmask = bq->resolve_logic(calibobj)
    w = where(resolve_bitmask eq 0,cnt)
    if cnt gt 0 then calibobj = calibobj[w] else continue
    calib_bitmask = bq->calib_logic(calibobj)
    w = where(calib_bitmask eq 0,cnt)
    if cnt gt 0 then calibobj = calibobj[w] else continue
    ;;match
    spherematch, data.ra, data.dec, calibobj.ra, calibobj.dec, 2./3600., $
      dindx, cindx
    if dindx[0] eq -1 then continue
    extra[dindx]= calibobj[cindx]
END
out= struct_combine(data,extra)

mwrfits, out, outfile, /create

END
