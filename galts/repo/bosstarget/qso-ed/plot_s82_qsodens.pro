;+
; scale= in sq. deg, npix=grid parameter, zmin= min redshift
;-
PRO PLOT_S82_QSODENS, outfile=outfile, scale=scale, npix=npix, zmin=zmin
IF ~keyword_set(zmin) THEN zmin= 2.15
IF ~keyword_set(npix) then npix= 1001
IF ~keyword_set(scale) then scale=1.
;;estimate density on grid
qsos= mrdfits('bossS82qsos.fits',1)
qsos= qsos[where(qsos.z GE zmin)]
qsos.ra= qsos.ra+180.
qsos[where(qsos.ra GE 360.)].ra= qsos[where(qsos.ra GE 360.)].ra-360.
minra= 130.
maxra= 230.
mindec= -1.25
maxdec= 1.25
gridra= dindgen(npix)/(npix-1d0)*(maxra-minra)+minra
npix_dec= long(floor(npix/35.))
griddec= dindgen(npix_dec)/(npix_dec-1d0)*(maxdec-mindec)+mindec
dens= dblarr(npix,npix_dec)
FOR ii=0L, npix-1 DO FOR jj=0L, npix_dec-1 DO BEGIN
    thisr= sqrt(scale/cos(griddec[jj]/180.*!DPI))/2.
    dens[ii,jj]= n_elements(where(qsos.ra GE (gridra[ii]-thisr) and $
                                  qsos.ra LE (gridra[ii]+thisr) and $
                                  qsos.dec GE (griddec[jj]-thisr) and $
                                  qsos.dec LE (griddec[jj]+thisr)))/scale
ENDFOR
print, "maximum density / deg^2 is", max(dens)
;;plot
IF keyword_set(outfile) THEN k_print, filename=outfile, xsize=15., $
  ysize=3.
bovy_density, dens, [minra,maxra],[mindec,maxdec], grid=[npix,npix_dec], $
  /flip, $
  xtitle=textoidl('\alpha_{J2000} + 180. [deg]'), $
  ytitle=textoidl('\delta_{J2000} [deg]'), $
  title='scale = '+strtrim(string(scale,format='(F4.2)'),2)+textoidl(' deg^2') 
IF keyword_set(outfile) THEN k_end_print

;;find highest density regions
nregions= 5
for ii=0L, nregions-1 do begin
    thism= max(dens,indx)
    indx_ra= indx mod npix
    indx_dec= indx/npix
    thisra= gridra[indx_ra]
    thisdec= griddec[indx_dec]
    print, thisra-180., thisdec, thism
    ;;block density around this maximum
    thisr= sqrt(scale/cos(thisdec/180.*!DPI))/2.
    for kk=0L, npix-1 do for jj=0L, npix_dec-1 do begin
        if gridra[kk] GE (thisra-thisr) and $
          gridra[kk] LE (thisra+thisr) and $
          griddec[jj] GE (thisdec-thisr) and $
          griddec[jj] LE (thisdec+thisr) then dens[kk,jj]= 0.
    endfor
endfor
END
;;results for scale=1 and scale=0.25
;;scale=1
;maximum density / deg^2 is       55.000000
;       23.800000     -0.60185185       55.000000
;       7.9000000      0.41666667       55.000000
;       41.400000     -0.50925926       51.000000
;       36.600000     0.046296296       50.000000
;       9.1000000     0.046296296       48.000000
;;scale=0.25
;maximum density / deg^2 is       76.000000
;       23.500000     -0.32407407       76.000000
;       10.400000      0.41666667       76.000000
;       26.300000      0.50925926       76.000000
;      -23.100000      0.69444444       76.000000
;       41.100000     -0.97222222       72.000000
;;With zmin=1.9 now
;;scale=1
;       7.9000000      0.41666667       58.000000
;       23.800000     -0.60185185       55.000000
;       41.400000     -0.50925926       53.000000
;       36.600000     0.046296296       51.000000
;       15.900000      0.50925926       51.000000
;;scale=0.25
;       10.400000      0.41666667       84.000000
;       7.8000000      0.69444444       80.000000
;       41.100000     -0.97222222       76.000000
;       11.000000     -0.87962963       76.000000
;       41.200000     -0.60185185       76.000000

