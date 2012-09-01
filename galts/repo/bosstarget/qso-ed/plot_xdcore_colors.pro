;+
;   NAME:
;      plot_xdcore_colors
;   PURPOSE:
;      make color-color plots of star and quasar targets
;   INPUT:
;      outfile - filename for plot
;      savefile - filename for savefile
;      cut - cut on probability
;      less - if set, use less than cut
;      fraction - plot a fraction of the objects
;   OUTPUT:
;      plot
;   HISTORY:
;      2010-11-17 - Written - Bovy
;-
PRO PLOT_XDCORE_COLORS, xdcoredir=xdcoredir, outfile=outfile, $
                        savefile=savefile, cut=cut, less=less, $
                        fraction=fraction
IF ~keyword_set(cut) THEN cut= 0.8
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'

if ~file_test(savefile) THEN BEGIN
   ;;Read runs
    runs= mrdfits('dr8runs.fits',1)
    runs= runs.run
    nruns= n_elements(runs)
    
    outStruct= {psfmag:dblarr(5)}
    out= outStruct
    
   ;;Loop through, accumulate
    FOR ii=0L, nruns-1 DO BEGIN
        run= runs[ii]
        print, "Working on run "+strtrim(string(run),2)
        filename= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
        if file_test(filename) then xd= mrdfits(filename,1) else continue
        IF keyword_set(less) THEN indx= where(xd.pqso LE cut and xd.good EQ 0 and xd.psfmag[3] LT 21.) ELSE indx= where(xd.pqso GE cut and xd.good EQ 0 and xd.psfmag[3] LT 21.)
        IF indx[0] EQ -1 THEN CONTINUE
        thisOut= replicate(outStruct,n_elements(indx))
        thisOut.psfmag= xd[indx].psfmag
        out= [out,thisOut]
    ENDFOR
    out= out[1:n_elements(out.psfmag[0])-1]
    save, filename=savefile, out
ENDIF ELSE BEGIN
    restore, savefile
ENDELSE

print, n_elements(out.psfmag[0])

;;plot
levels= errorf(0.5*(dindgen(3)+1))
charsize=1.1
k_print, filename=outfile+'-ug-gr.ps'
hogg_scatterplot, out.psfmag[0]-out.psfmag[1], $
  out.psfmag[1]-out.psfmag[2], $
  ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), psym=3, xrange=[-1,5],$
  yrange=[-.6,4], xnpix=101, ynpix= 101, ioutliers=ioutliers, $
  /internal_weight, charsize=charsize, levels=levels
;;Cut outliers to fraction, random sampling
x= lindgen(n_elements(ioutliers))
y= randomu(seed,n_elements(ioutliers))
z= x[sort(y)]
z= z[0:floor(fraction*n_elements(ioutliers))-1]
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .15*cos(phi), .15*sin(phi), /fill
djs_oplot, out[ioutliers[z]].psfmag[0]-out[ioutliers[z]].psfmag[1],$
  out[ioutliers[z]].psfmag[1]-out[ioutliers[z]].psfmag[2], psym=8
if ~keyword_set(less) then overplot_qso_colors, /ugr else overplot_stellar_colors, /ugr
k_end_print

k_print, filename=outfile+'-gr-ri.ps'
hogg_scatterplot, out.psfmag[1]-out.psfmag[2], $
  out.psfmag[2]-out.psfmag[3], $
  ytitle=textoidl('r-i'),xtitle=textoidl('g-r'), psym=3, xrange=[-.6,4],$
  yrange=[-.6,2.6], xnpix=101, ynpix=101, ioutliers=ioutliers, $
  /internal_weight, charsize=charsize, levels=levels
;;Cut outliers to fraction, random sampling
x= lindgen(n_elements(ioutliers))
y= randomu(seed,n_elements(ioutliers))
z= x[sort(y)]
z= z[0:floor(fraction*n_elements(ioutliers))-1]
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .15*cos(phi), .15*sin(phi), /fill
djs_oplot, out[ioutliers[z]].psfmag[1]-out[ioutliers[z]].psfmag[2],$
  out[ioutliers[z]].psfmag[2]-out[ioutliers[z]].psfmag[3], psym=8
if ~keyword_set(less) then overplot_qso_colors, /gri else overplot_stellar_colors, /gri
k_end_print


k_print, filename=outfile+'-ri-iz.ps'
hogg_scatterplot, out.psfmag[2]-out.psfmag[3], $
  out.psfmag[3]-out.psfmag[4], $
  ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), psym=3, yrange=[-.5,2.5],$
  xrange=[-.6,2.6], xnpix=101, ynpix=101, ioutliers=ioutliers,$
  /internal_weight, charsize=charsize, levels=levels
;;Cut outliers to fraction, random sampling
x= lindgen(n_elements(ioutliers))
y= randomu(seed,n_elements(ioutliers))
z= x[sort(y)]
z= z[0:floor(fraction*n_elements(ioutliers))-1]
phi=findgen(32)*(!PI*2/32.)
phi = [ phi, phi(0) ]
usersym, .15*cos(phi), .15*sin(phi), /fill
djs_oplot, out[ioutliers[z]].psfmag[2]-out[ioutliers[z]].psfmag[3],$
  out[ioutliers[z]].psfmag[3]-out[ioutliers[z]].psfmag[4], psym=8
if ~keyword_set(less) then overplot_qso_colors, /riz else overplot_stellar_colors, /riz
k_end_print
END
