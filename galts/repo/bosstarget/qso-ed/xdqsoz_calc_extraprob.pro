FUNCTION XDQSOZ_CALC_EXTRAPROB, in, zmin=zmin, zmax=zmax, $
                                galex=galex, ukidss=ukidss, $
                                dr9=dr9, clean=clean
;+
;   NAME:
;      xdqsoz_calc_extraprob
;   PURPOSE
;      calculate a different p(QSO zmin <= z <= zmax) probability
;   INPUT:
;      structure contaning psfflux, psfflux_ivar, extinction, pqso,
;      run, camcol
;      (like a catalog)
;   KEYWORDS:
;      galex - use GALEX
;      ukidss - use UKIDSS
;      dr9 - use dr9 sweeps
;      clean - use multi-epoch photometry where possible
;   OUTPUT:
;      new probabilities (array)
;   HISTORY:
;      2012-02-13 - Written - Bovy (IAS)
;-
IF ~keyword_set(zmin) THEN zmin= 0.3
IF ~keyword_set(zmax) THEN zmax= 5.5
if keyword_set(dr9) and keyword_set(clean) then begin
    ;;save old psffluxes
    old_psfflux= in.psfflux
    old_psfflux_ivar= in.psfflux_ivar
    nfilters= 5
    for jj=0L, nfilters-1 do begin
        cleanindx= where(in.psf_clean_nuse[jj] gt 1,cnt)
        if cnt gt 1 then begin
            in[cleanindx].psfflux[jj]= in[cleanindx].psfflux_clean[jj]
            in[cleanindx].psfflux_ivar[jj]= in[cleanindx].psfflux_clean_ivar[jj]
        endif
    endfor
endif
out= dblarr(n_elements(in))
nobj= n_elements(in)
FOR ii=0L, n_elements(in)-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,nobj,string(13B)
        ;;Calculate redshift information
        if keyword_set(galex) and keyword_set(ukidss) then begin
            ;;check whether there actually is galex and ukidss
            if in[ii].galex_used and in[ii].ukidss_used then begin
                flux= sdss_deredden(in[ii].psfflux,in[ii].extinction)
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar,in[ii].extinction)
                thisgalex= 1
                thisukidss= 1
            endif else if in[ii].galex_used then begin
                flux= sdss_deredden(in[ii].psfflux[0:6],in[ii].extinction[0:6])
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar[0:6],in[ii].extinction[0:6])
                thisgalex= 1
                thisukidss= 0
            endif else if in[ii].ukidss_used then begin
                flux= sdss_deredden(in[ii].psfflux[0:8],in[ii].extinction[0:8])
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar[0:8],in[ii].extinction[0:8])
                thisgalex= 0
                thisukidss= 1
            endif else begin
                flux= sdss_deredden(in[ii].psfflux[0:4],in[ii].extinction[0:4])
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar[0:4],in[ii].extinction[0:4])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else if keyword_set(galex) then begin
            if in[ii].galex_used then begin
                flux= sdss_deredden(in[ii].psfflux,in[ii].extinction)
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar,in[ii].extinction)
                thisgalex= 1
                thisukidss= 0
            endif else begin
                flux= sdss_deredden(in[ii].psfflux[0:4],in[ii].extinction[0:4])
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar[0:4],in[ii].extinction[0:4])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else if keyword_set(ukidss) then begin
            if in[ii].ukidss_used then begin
                flux= sdss_deredden(in[ii].psfflux,in[ii].extinction)
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar,in[ii].extinction)
                thisgalex= 0
                thisukidss= 1
            endif else begin
                flux= sdss_deredden(in[ii].psfflux[0:4],in[ii].extinction[0:4])
                flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar[0:4],in[ii].extinction[0:4])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else begin
            flux= sdss_deredden(in[ii].psfflux,in[ii].extinction)
            flux_ivar= sdss_deredden_error(in[ii].psfflux_ivar,in[ii].extinction)
        endelse
    prob= xdqsoz_marginalize_colorzprob(zmin,zmax,$
                                        flux,flux_ivar,$
                                        galex=thisgalex,$
                                        ukidss=thisukidss,$
                                        norm=totlike)
    out[ii]= prob/totlike*in[ii].pqso
ENDFOR
return, out
END
