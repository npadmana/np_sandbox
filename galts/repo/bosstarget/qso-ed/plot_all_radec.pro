;+
;   NAME:
;      plot_all_radec
;   PURPOSE:
;      plot the sky distribution of *all* primary objects
;   INPUT:
;      outfile - filename for plot
;      savefile - filename for savefile
;   KEYWORDS:
;      photometric - if set, cut to photometric objects
;   OUTPUT:
;      plot
;   HISTORY:
;      2010-09-06 - Written - Bovy (NYU)
;-
PRO PLOT_ALL_RADEC, outfile, savefile, photometric=photometric

if ~file_test(savefile) THEN BEGIN
   ;;Read runs
    runs= mrdfits('dr8runs.fits',1)
    runs= runs.run
    nruns= n_elements(runs)
    
    outStruct= {ra:0D,dec:0D}
    out= outStruct
    
    ;;Loop through, accumulate
    bq = obj_new('bosstarget_qso')
    FOR ii=0L, nruns-1 DO BEGIN
        run= runs[ii]
        print, "Working on run "+strtrim(string(run),2)
        calibobj= read_calibobj(run,type='star')
        ;;cut to primary
        resolve_bitmask = bq->resolve_logic(calibobj)
	w = where(resolve_bitmask eq 0,cnt)
	if cnt gt 0 then calibobj = calibobj[w] else continue
        if keyword_set(photometric) then begin
            calib_bitmask = bq->calib_logic(calibobj)
            w = where(calib_bitmask eq 0,cnt)
            if cnt gt 0 then calibobj = calibobj[w] else continue
        endif
        thisOut= replicate(outStruct,n_elements(calibobj.ra))
        thisOut.ra= calibobj.ra
        thisOut.dec= calibobj.dec
        out= [out,thisOut]
    ENDFOR
    out= out[1:n_elements(out.ra)-1]
    save, filename=savefile, out
ENDIF ELSE BEGIN
    restore, savefile
ENDELSE

;;Bin
xrange= minmax(out.ra)
yrange= minmax(sin(out.dec/180D0*!DPI))
hist= hist_2d(out.ra, sin(out.dec/180D0*!DPI),bin1=(xrange[1]-xrange[0])/101,$
              bin2=(yrange[1]-yrange[0])/101,$
              max1= max(out.ra), max2= max(sin(out.dec/180D0*!DPI)), $
              min1= min(out.ra), min2= min(sin(out.dec/180D0*!DPI)))

;;Plot
if keyword_set(photometric) then title='Primary + Photometric' else title='Primary'
k_print, filename=outfile
bovy_density, hist, minmax(out.ra), $
  minmax(sin(out.dec/180D0*!DPI)), grid=[101,101], /flip, /keepbangX, $
  xtitle='RA [deg]', ytitle='sin(Dec)', title=title

;;Overplot the Galactic plane
planel= dindgen(1001)*360./1000.
planeb= dblarr(1001)
glactc,ra,dec,2000.,planel,planeb,2, /degree
dec= dec[sort(ra)]
ra= ra[sort(ra)]
djs_oplot, ra, sin(dec/180D0*!DPI)
k_end_print

END
