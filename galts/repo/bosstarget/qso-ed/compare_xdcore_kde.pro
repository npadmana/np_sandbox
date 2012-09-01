;+
;   NAME:
;      compare_xdcore_kde
;   PURPOSE:
;      compare the XD algorithm to KDE
;   INPUT:
;      tempfile - savefilename
;      zrange - 0, 1, or 2 for lowz, midz, or hiz
;   OPTIONAL INPUT:
;      xdcoredir - directory that has the catalog
;      filebasename - basename of catalog files (e.g., 'xdcore')
;   KEYWORDS:
;      icut - cut to i < 21.3
;   OUTPUT:
;   HISTORY:
;      2010-09-03 - Written - Bovy (NYU)
;-
PRO COMPARE_XDCORE_KDE, tempfile, zrange, icut=icut, xdcoredir=xdcoredir, filebasename=filebasename
;;Restore DR6 NBCKDE file
kde= mrdfits('$BOVYQSOEDDATA/nbckde_dr6_uvx_highz_faint_qsos_021908.cat.rasort.match.hennawi.072408.dr6cut.fits',1)

if zrange EQ 0 then begin
    kde= kde[where(kde.lowzts EQ 1 and kde.good GE 0)]
endif else if zrange EQ 1 then begin
    kde= kde[where(kde.midzts EQ 1 and kde.good GE 0)]
endif else begin
    kde= kde[where(kde.highzts EQ 1 and kde.good GE 0)]
endelse
if keyword_set(icut) then begin
    keep= where(kde.imag ge 17.75,cnt)
    if cnt ne 0 then kde= kde[keep]
endif

ntargets= n_elements(kde.ra)

;;Now run through the XD targets, and select them
IF ~file_test(tempfile) THEN BEGIN
    IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'
    IF ~keyword_set(filebasename) THEN filebasename= 'xdcore'
    ;;Runs
    runs= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/dr8runs.fits',1)
    runs= runs.run
    nruns= n_elements(runs)
    ;;outstruct
    xd= mrdfits(xdcoredir+filebasename+'_'+strtrim(string(runs[0],format='(I6.6)'),2)+'.fits',1)
    out= xd[0]
    ;;Loop through runs, save everything that could be a QSO
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
        pcut= 0.1
        keep= where(xd.pqsolowz GE pcut or $
                    xd.pqsomidz GE pcut or $
                    xd.pqsohiz GE pcut,cnt)
        IF cnt EQ 0 then continue
        out= [out,xd[keep]]
        print, "Current number of objects: ", n_elements(out.ra)-1
    ENDFOR
    out= out[1:n_elements(out.ra)-1]
    mwrfits, out, tempfile, /create
    xd= out
ENDIF ELSE BEGIN
    xd= mrdfits(tempfile,1)
ENDELSE
;;Cut to DR6
xd= dr6cut(xd)

;;Select XD targets
if zrange EQ 0 then begin
    sindx= reverse(sort(xd.pqsolowz))
endif else if zrange EQ 1 then begin
    sindx= reverse(sort(xd.pqsomidz))
endif else begin 
    sindx= reverse(sort(xd.pqsohiz))
endelse
xd= xd[sindx[0:ntargets-1]]


;;Now match both to the known QSO file
known= mrdfits('$BOSSTARGET_DIR/data/knownquasarstar.060910.fits',1)
if zrange EQ 0 then begin
    known= known[where(known.zem GE 0.1 and known.zem LT 2.2)]
endif else if zrange EQ 1 then begin
    known= known[where(known.zem GE 2.2 and known.zem LE 3.5)]
endif else begin 
    known= known[where(known.zem GE 3.5)]
endelse

spherematch, kde.ra, kde.dec, known.ra, known.dec, 2./3600., kde_indx, kindx
print, "KDE: ", n_elements(kde_indx), " out of ", ntargets

spherematch, xd.ra, xd.dec, known.ra, known.dec, 2./3600., xd_indx, kindx
print, "XD: ", n_elements(xd_indx), " out of ", ntargets

END
