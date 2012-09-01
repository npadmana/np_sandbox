;+
;   NAME:
;      plot_xdcore_radec_qsostar
;   PURPOSE:
;      plot the sky distribution of the XD CORE targets
;   INPUT:
;      outfile - filename for plot
;      savefile - filename for savefile
;      cut - cut on probability
;      less - if set, use less than cut
;   OUTPUT:
;      plot
;   HISTORY:
;      2010-08-29 - Written - Bovy (NYU)
;      2010-11-16 - Plot in l and b
;      2011-01-04 - edit to make density contrast for stars more apparent
;-
PRO PLOT_XDCORE_RADEC_QSOSTAR, xdcoredir=xdcoredir, outfile=outfile, $
                               savefile=savefile, cut=cut, less=less, $
                               histfile=histfile
IF ~keyword_set(cut) THEN cut= 0.5
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core_primary/301/'

if ~file_test(histfile) and ~file_test(savefile) THEN BEGIN
   ;;Read runs
    runs= mrdfits('dr8runs.fits',1)
    runs= runs.run
    nruns= n_elements(runs)
    
    outStruct= {ra:0D,dec:0D}
    out= outStruct
    
   ;;Loop through, accumulate
    FOR ii=0L, nruns-1 DO BEGIN
        run= runs[ii]
        print, "Working on run "+strtrim(string(run),2)
        filename= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
        if file_test(filename) then xd= mrdfits(filename,1) else continue
        IF keyword_set(less) THEN indx= where(xd.pqso LE cut and xd.good EQ 0) ELSE indx= where(xd.pqso GE cut and xd.good EQ 0)
        IF indx[0] EQ -1 THEN CONTINUE
        thisOut= replicate(outStruct,n_elements(indx))
        thisOut.ra= xd[indx].ra
        thisOut.dec= xd[indx].dec
        out= [out,thisOut]
    ENDFOR
    out= out[1:n_elements(out.ra)-1]
    save, filename=savefile, out
ENDIF ELSE IF ~file_test(histfile) THEN BEGIN
    restore, savefile

    ;;Bin
    glactc, out.ra, out.dec, 2000.0, gl, gb, 1, /degree
    xrange= [0.,360.]
    yrange= [-1.,1.]
    nbins= 201
    hist= hist_2d(gl, sin(gb/180D0*!DPI),bin1=(xrange[1]-xrange[0])/nbins,$
                  bin2=(yrange[1]-yrange[0])/nbins,$
                  max1= 360., max2= 1, $
                  min1= 0., min2= -1.)
    save, filename=histfile, hist, nbins
ENDIF ELSE BEGIN
    restore, histfile
ENDELSE

;;Make density contrast more apparent
IF keyword_set(less) THEN BEGIN
    ;;Make regions that are not covered the same as the lowest-density
    ;;regions that are covered by DR8. Normalize at b=90
    ;minhist= min(hist[where(hist NE 0)])
    minhist= min(hist[where(hist[*,nbins-1] NE 0),nbins-1])
    zero_indx= where(hist LT minhist,nzero)
    ;;Saturate SEGUE stripes
    maxhist1= max(hist[*,140:200])
    maxhist2= max(hist[*,0:60])
    maxhist= max([maxhist1,maxhist2])
    hist[where(hist GT maxhist)]= maxhist
    ;;Clean up
    IF nzero NE 0 THEN hist[zero_indx]= minhist
ENDIF

;;Plot
IF keyword_set(less) THEN title='Star targets' ELSE title= 'Quasar targets'
k_print, filename=outfile, xsize=10., ysize=6
bovy_density, hist, [0.,360.], [-1.,1.],$
  grid=[nbins,nbins], /flip, /keepbangX, $
  xtitle='Galactic longitude [deg]', ytitle='sin(Galactic latitude)', $
  title=title

;;Overplot the Galactic plane
;planel= dindgen(1001)*360./1000.
;planeb= dblarr(1001)
;glactc,ra,dec,2000.,planel,planeb,2, /degree
;dec= dec[sort(ra)]
;ra= ra[sort(ra)]
;djs_oplot, ra, sin(dec/180D0*!DPI)
k_end_print

END
