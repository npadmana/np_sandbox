;+
;   NAME:
;      xdqsoz_addxdqsoztags
;   PURPOSE:
;      add the XDQSOZ tags to a catalog
;   INPUT:
;      infile - file that holds a structure that has psfflux, psfflux_ivar, and extinction
;   OPTIONAL INPUT:
;      nother - number of secondary redshift peaks to save
;      ext - extension in infile to use
;   KEYWORDS:
;      create - mwrfits' create keyword
;      galex - use GALEX
;      ukidss - use UKIDSS
;      dr9 - use dr9 sweeps
;      clean - use multi-epoch photometry where possible
;      struct - if set, the infile and outfile s are structs
;   OUTPUT:
;      outfile - infile+extra tags in this file
;   HISTORY:
;      2011-02-04 - Written - Bovy (NYU)
;      2012-06-08 - Added dr9 and clean - Bovy (IAS)
;-
PRO XDQSOZ_ADDXDQSOZTAGS, infile, outfile, nother=nother, multi=multi, $
                          ext=ext, create=create, galex=galex, ukidss=ukidss, $
                          dr9=dr9, clean=clean, struct=struct
IF ~keyword_set(ext) THEN ext= 1
IF ~keyword_set(nother) THEN nother= 5
if ~keyword_set(struct) then in= mrdfits(infile,ext) else in= infile
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
nobj= n_elements(in.ra)
nzs= 1001
extraTags= xdqsoz_extraTags_struct(nother)
extraTags= replicate(extraTags,nobj)
IF ~keyword_set(multi) THEN BEGIN
    FOR ii=0L, nobj-1 DO BEGIN
        ;;if ii GT 10 then break
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
        npeaks= xdqsoz_peaks(flux,flux_ivar, $
                             nzs=nzs,xdqsoz=xdqsoz,$
                             galex=thisgalex,ukidss=thisukidss)
        extraTags[ii].npeaks= npeaks
        extraTags[ii].peakz= xdqsoz.peakz
        extraTags[ii].peakprob= xdqsoz.peakprob
        extraTags[ii].peakfwhm= xdqsoz.peakfwhm
        if npeaks GT (nother+1) or npeaks EQ 1 then continue
        extraTags[ii].otherz[0:npeaks-2]= xdqsoz.otherz
        extraTags[ii].otherprob[0:npeaks-2]= xdqsoz.otherprob
        extraTags[ii].otherfwhm[0:npeaks-2]= xdqsoz.otherfwhm
    ENDFOR
    out= struct_combine(in,extraTags)
ENDIF ELSE BEGIN
    ;;load-balance
    sizes= lindgen(nobj)/double(nobj)
    cuts= lonarr(multi+1)
    FOR ii= 0L, multi-2 DO BEGIN
        cuts[ii+1]= max(where(sizes LE (ii+1.)/multi))
    ENDFOR
    cuts[multi]= nobj
    ;;run the various processes
    ii= 0
    procs= [obj_new('IDL_IDLBridge',output='')]
    procs[ii]->SetVar, 'psfflux', in[cuts[ii]:cuts[ii+1]-1].psfflux
    procs[ii]->SetVar, 'psfflux_ivar', in[cuts[ii]:cuts[ii+1]-1].psfflux_ivar
    procs[ii]->SetVar, 'extinction', in[cuts[ii]:cuts[ii+1]-1].extinction
    if ~keyword_set(galex) then begin
        procs[ii]->SetVar, 'ggalex_used', bytarr(n_elements(in[cuts[ii]:cuts[ii+1]-1].psfflux[0]))
    endif else begin
        procs[ii]->SetVar, 'ggalex_used', in[cuts[ii]:cuts[ii+1]-1].galex_used
    endelse
    if ~keyword_set(ukidss) then begin
        procs[ii]->SetVar, 'uukidss_used', bytarr(n_elements(in[cuts[ii]:cuts[ii+1]-1].psfflux[0]))
    endif else begin
        procs[ii]->SetVar, 'uukidss_used', in[cuts[ii]:cuts[ii+1]-1].ukidss_used
    endelse
    procs[ii]->SetVar, 'nzs', nzs
    procs[ii]->SetVar, 'nother', nother
    tmpfiles= [tmpfile(suffix='.fits',tmpdir='/tmp')]
    procs[ii]->SetVar, 'tmpfile', tmpfiles[ii]   
    procs[ii]->SetVar, "galex", keyword_set(galex)
    procs[ii]->SetVar, "ukidss", keyword_set(ukidss)
    FOR ii=1L, multi-1 DO BEGIN
        procs= [procs,obj_new('IDL_IDLBridge',output='')]
        procs[ii]->SetVar, 'psfflux', in[cuts[ii]:cuts[ii+1]-1].psfflux
        procs[ii]->SetVar, 'psfflux_ivar', in[cuts[ii]:cuts[ii+1]-1].psfflux_ivar
        procs[ii]->SetVar, 'extinction', in[cuts[ii]:cuts[ii+1]-1].extinction
        if ~keyword_set(galex) then begin
            procs[ii]->SetVar, 'ggalex_used', bytarr(n_elements(in[cuts[ii]:cuts[ii+1]-1].psfflux[0]))
        endif else begin
            procs[ii]->SetVar, 'ggalex_used', in[cuts[ii]:cuts[ii+1]-1].galex_used
        endelse
        if ~keyword_set(ukidss) then begin
            procs[ii]->SetVar, 'uukidss_used', bytarr(n_elements(in[cuts[ii]:cuts[ii+1]-1].psfflux[0]))
        endif else begin
            procs[ii]->SetVar, 'uukidss_used', in[cuts[ii]:cuts[ii+1]-1].ukidss_used
        endelse
        procs[ii]->SetVar, 'nzs', nzs
        procs[ii]->SetVar, 'nother', nother
        tmpfiles= [tmpfiles,tmpfile(suffix='.fits',tmpdir='/tmp')]
        procs[ii]->SetVar, 'tmpfile', tmpfiles[ii]   
        procs[ii]->SetVar, "galex", keyword_set(galex)
        procs[ii]->SetVar, "ukidss", keyword_set(ukidss)
    ENDFOR
    ;;run everything
    count= 0
    catch, err_status
    IF err_status NE 0 THEN BEGIN  
        ;PRINT, 'Error index: ', err_status  
        ;PRINT, 'Error message: ', !ERROR_STATE.MSG  
        count+= 1
        if count EQ multi then CATCH, /CANCEL  
    ENDIF
    FOR ii=0L, multi-1 DO BEGIN
        IF count LT (ii+1) THEN BEGIN
            print, "Running process "+strtrim(string(ii+1),2)+" out of "+strtrim(string(multi),2)
            procs[ii]->Execute, 'xdqsoz_calc_extratags, psfflux, psfflux_ivar, extinction, tmpfile, nzs=nzs,nother=nother,galex=galex,ukidss=ukidss,ggalex_used=ggalex_used,uukidss_used=uukidss_used', /nowait
        ENDIF
    ENDFOR
    catch, /cancel
    ;;wait for them all to finish
    status= 1
    while status do begin
        wait, 5
        status= 0
        for ii=0L, multi-1 do begin
            thisstatus= procs[ii]->Status(ERROR=err)
            if thisstatus eq 1 or thisstatus eq 2 then begin
                status= 1
                break
            endif
        endfor
    endwhile
    ;;Grab the output
    FOR ii=0L, multi-1 DO BEGIN
        tmpin= mrdfits(tmpfiles[ii],1,/silent)
        extraTags[cuts[ii]:cuts[ii+1]-1]= tmpin
        spawn, 'rm '+tmpfiles[ii]
    ENDFOR
    out= struct_combine(in,extraTags)
    for ii=0L, multi-1 do obj_destroy, procs[ii]
ENDELSE
;;restore single-epoch psffluxes if needed
if keyword_set(dr9) and keyword_set(clean) then begin
    out.psfflux= old_psfflux
    out.psfflux_ivar= old_psfflux_ivar
endif
;;Save
if ~keyword_set(struct) then mwrfits, out, outfile, create=create else outfile=out
END
