;+
;   NAME:
;      xdqsoz_create_catalog
;   PURPOSE:
;      create the photometric catalog for XDQSOz
;   INPUT:
;      outfile - output filename
;      pmin=- minimum P(QSO) to be included
;      pmax=- maximum P(QSO) to be included
;      xdqsozdir= directory that has the XDQSOz results for all
;                 objects
;      filebasename= start of the filename of files in xdqsozdir
;      ramin, ramax, decmin,decmax - min, max of ra and dec in deg
;   KEYWORDS:
;      good - only include good objects
;      galex - add GALEX to psfflux, etc., #of fluxes set globally
;      ukidss - add UKIDSS to psfflux, etc.
;      dr9 - match to dr9 sweeps
;      clean - also include clean photometry
;   OUTPUT:
;      catalog in outfile
;   HISTORY:
;      2011-07-04 - Written - Bovy (NYU)
;      2012-06-08 - Added dr9 and clean - Bovy (IAS)
;-
PRO XDQSOZ_CREATE_CATALOG, outfile, pmin=pmin, pmax=pmax, good=good, $
                           xdqsozdir=xdqsozdir, $
                           filebasename=filebasename, $
                           ramin=ramin, ramax=ramax, $
                           decmin=decmin, decmax=decmax, $
                           galex=galex, ukidss=ukidss, $
                           dr9=dr9, clean=clean
IF ~keyword_set(pmin) THEN pmin= 0.
IF ~keyword_set(pmax) THEN pmax= 1.01 ;;to make LT work
IF ~keyword_set(xdqsozdir) THEN xdqsozdir= '/mount/hydra4/jb2777/sdss/xdqsoz/core_primary/301/'
IF ~keyword_set(filebasename) THEN filebasename= 'xdqsoz'
;;Runs
runs= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)
tempfile= 'xdqsozcat.'+strtrim(string(pmin,format='(F4.2)'),2)+'.'+strtrim(string(pmax,format='(F4.2)'),2)+'.'+'.tmp'
print, tempfile
IF ~file_test(tempfile) THEN BEGIN
   ;;outstruct
    xd= mrdfits(xdqsozdir+filebasename+'_'+strtrim(string(runs[0],format='(I6.6)'),2)+'.fits',1)
    out= xd[0]
   ;;Loop through runs, save everything that could be a QSO
    FOR ii=0L, nruns -1 DO BEGIN
        run= runs[ii]
        print, format = '("Working on ",i7," of ",i7,a1,"Current number of objects: ",i8,a1,$)', $
          ii+1,nruns,string(9B), n_elements(out.ra), string(13B)
        filename= xdqsozdir+filebasename+'_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
        if file_test(filename) then xd= mrdfits(filename,1,/silent) else continue
        if keyword_set(good) then begin
            keep= where(xd.good EQ 0,cnt)
            IF cnt EQ 0 then continue
            xd= xd[keep]
        endif
        ;ra, dec cut
        if keyword_set(ramin) then begin
            keep= where(xd.ra GE ramin and xd.ra LE ramax $
                        and xd.dec GE decmin and xd.dec LE decmax,cnt)
            IF cnt EQ 0 then continue
            xd= xd[keep]
        endif
        ;;probability cut
        keep= where(xd.pqso GE pmin and xd.pqso LT pmax,cnt) ;;LT st non-overlapping
        IF cnt EQ 0 then continue
        out= [out,xd[keep]]
        ;print, "Current number of objects: ", n_elements(out.ra)-1
    ENDFOR
    out= out[1:n_elements(out.ra)-1]
    mwrfits, out, tempfile, /create
ENDIF
;;now match back to the sweeps
match_xd_sweeps, tempfile, outfile, /basic, galex=galex,ukidss=ukidss, $
  dr9=dr9, clean=clean
;;add psfmag etc.
in= mrdfits(outfile,1)
nfluxes= 5
if keyword_set(galex) then nfluxes+= 2
if keyword_set(ukidss) then nfluxes+= 4
xtraTags= {psfmag:dblarr(nfluxes),psfmagerr:dblarr(nfluxes),extinction_u:0D0}
xtra= replicate(xtraTags,n_elements(in.ra))
if keyword_set(clean) and keyword_set(dr9) then begin
    ;;Use best fluxes to calculate magnitudes
    newStruct= {psfflux: dblarr(nfluxes), psfflux_ivar: dblarr(nfluxes), $
                extinction: dblarr(nfluxes)}
    new= replicate(newStruct,n_elements(in))
    new.psfflux= in.psfflux
    new.psfflux_ivar= in.psfflux_ivar
    new.extinction= in.extinction
    nfilters= 5
    for jj=0L, nfilters-1 do begin
        cleanindx= where(in.psf_clean_nuse[jj] gt 1,cnt)
        if cnt gt 1 then begin
            new[cleanindx].psfflux[jj]= in[cleanindx].psfflux_clean[jj]
            new[cleanindx].psfflux_ivar[jj]= in[cleanindx].psfflux_clean_ivar[jj]
        endif
    endfor
    prep_data, new.psfflux, new.psfflux_ivar, extinction=new.extinction,$
      mags=mags,var_mags=var_mags
endif else begin
    prep_data, in.psfflux, in.psfflux_ivar, extinction=in.extinction,$
      mags=mags,var_mags=var_mags
endelse
xtra.psfmag= mags
xtra.psfmagerr= sqrt(var_mags)
xtra.extinction_u= in.extinction[0]
mwrfits, struct_combine(in,xtra), outfile, /create
file_delete, tempfile
END
