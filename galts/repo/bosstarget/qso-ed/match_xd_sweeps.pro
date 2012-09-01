;+
;   NAME:
;      match_xd_sweeps
;   PURPOSE:
;      match an xd-type file to the sweeps, add sweeps tags
;   INPUT:
;      infile - XD type file
;      outfile - name of output file (infile+sweeps tags)
;   KEYWORDS:
;      basic - only include 'basic' sweeps tags: psfflux,
;              psfflux_ivar, extinction, run, rerun, camcol, field, id
;      galex - add GALEX to psfflux, etc., #of fluxes set globally
;      ukidss - add UKIDSS to psfflux, etc.
;      dr9 - match to dr9 sweeps
;      clean - also include clean photometry
;   OUTPUT:
;      (in outfile)
;   HISTORY:
;      2010-09-04 - Finally written - Bovy (NYU)
;      2012-06-08 - Added dr9 and clean - Bovy (IAS)
;-
PRO MATCH_XD_SWEEPS, infile, outfile, basic=basic, galex=galex,ukidss=ukidss, $
                     dr9=dr9, clean=clean
;;Read input
in= mrdfits(infile,1)
ndata= n_elements(in.run)
iid= photoid(in)
;;Extra tags are sweeps tags
calibobj= read_calibobj(94,camcol=1,/silent,dr9=dr9)
if keyword_set(basic) and (~keyword_set(clean) or ~keyword_set(dr9)) then begin
    calibobj= struct_selecttags(calibobj,$
                                select_tags=['psfflux',$
                                             'psfflux_ivar',$
                                             'extinction',$
                                             'ra',$
                                             'dec',$
                                             'run',$
                                             'rerun',$
                                             'camcol',$
                                             'field',$
                                             'id'])
endif else if keyword_set(basic) then begin
    calibobj= struct_selecttags(calibobj,$
                                select_tags=['psfflux',$
                                             'psfflux_ivar',$
                                             'extinction',$
                                             'psfflux_clean',$
                                             'psfflux_clean_ivar',$
                                             'psf_clean_nuse',$
                                             'ra',$
                                             'dec',$
                                             'run',$
                                             'rerun',$
                                             'camcol',$
                                             'field',$
                                             'id'])
endif
if keyword_set(galex) then begin
    galexdata= read_galex(run=94,camcol=1)
endif else begin
    galexdata= keyword_set(galex)
endelse
if keyword_set(ukidss) then begin
    ukidssdata= read_aux(run=94,/ukidss)
    if ukidssdata[0].run EQ -1 then ukidssdata= 0
endif else begin
    ukidssdata= keyword_set(ukidss)
endelse
if keyword_set(galex) or keyword_set(ukidss) then begin
    comb= add_data(calibobj,galexdata=galexdata,ukidssdata=ukidssdata)
    nfluxes= 5
    if keyword_set(galex) then nfluxes+= 2
    if keyword_set(ukidss) then nfluxes+= 4
    if ~(keyword_set(clean) and keyword_set(dr9)) then begin
        calibobj= struct_selecttags(calibobj,$
                                    except_tags=['psfflux',$
                                                 'psfflux_ivar',$
                                                 'extinction'])
        newStruct= {psfflux: dblarr(nfluxes), psfflux_ivar: dblarr(nfluxes), $
                    extinction: dblarr(nfluxes)}
    endif else begin
        calibobj= struct_selecttags(calibobj,$
                                    except_tags=['psfflux',$
                                                 'psfflux_ivar',$
                                                 'extinction', $
                                                 'psfflux_clean',$
                                                 'psfflux_clean_ivar'])
        newStruct= {psfflux: dblarr(nfluxes), psfflux_ivar: dblarr(nfluxes), $
                    psfflux_clean: dblarr(nfluxes), $
                    psfflux_clean_ivar: dblarr(nfluxes), $
                    extinction: dblarr(nfluxes)}
    endelse
    extraOutStruct= struct_combine(calibobj[0],newStruct)
endif else begin
    extraOutStruct= calibobj[0]
endelse
extraOut= replicate(extraOutStruct,ndata)
;;Which runs do we need?
runs= in[UNIQ(in.run, SORT(in.run))].run
nruns= n_elements(runs)
FOR ii=0L, nruns-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,nruns,string(13B)
    calibobj= READ_CALIBOBJ(runs[ii], type='star',/silent,dr9=dr9)
    if keyword_set(basic) and (~keyword_set(clean) or ~keyword_set(dr9)) then begin
        calibobj= struct_selecttags(calibobj,$
                                    select_tags=['psfflux',$
                                                 'psfflux_ivar',$
                                                 'extinction',$
                                                 'ra',$
                                                 'dec',$
                                                 'run',$
                                                 'rerun',$
                                                 'camcol',$
                                                 'field',$
                                                 'id'])
    endif else if keyword_set(basic) then begin
        calibobj= struct_selecttags(calibobj,$
                                    select_tags=['psfflux',$
                                                 'psfflux_ivar',$
                                                 'extinction',$
                                                 'psfflux_clean',$
                                                 'psfflux_clean_ivar',$
                                                 'psf_clean_nuse',$
                                                 'ra',$
                                                 'dec',$
                                                 'run',$
                                                 'rerun',$
                                                 'camcol',$
                                                 'field',$
                                                 'id'])
    endif
    cid= photoid(calibobj)
    match, cid, iid, cindx, iindxt, /sort
    calibobj= calibobj[cindx]
    if keyword_set(galex) then begin
        galexdata= read_galex(run=runs[ii],camcol=[1,2,3,4,5,6])
    endif else begin
        galexdata= keyword_set(galex)
    endelse
    if keyword_set(ukidss) then begin
        ukidssdata= read_aux(run=runs[ii],/ukidss)
        if ukidssdata[0].run EQ -1 then ukidssdata= 0
    endif else begin
        ukidssdata= keyword_set(ukidss)
    endelse
    if keyword_set(galex) or keyword_set(ukidss) then begin
        comb= add_data(calibobj,galexdata=galexdata,ukidssdata=ukidssdata)
        if ~(keyword_set(clean) and keyword_set(dr9)) then begin
            calibobj= struct_selecttags(calibobj,$
                                        except_tags=['psfflux',$
                                                     'psfflux_ivar',$
                                                     'extinction'])
            newStruct= {psfflux: dblarr(nfluxes), psfflux_ivar: dblarr(nfluxes), $
                        extinction: dblarr(nfluxes)}
        endif else begin
            ;;also combine clean photometry with galex and ukidss
            new= {psfflux: dblarr(5), psfflux_ivar: dblarr(5), $
                  extinction: dblarr(5),ra:0D,dec:0D,run:0L,rerun:'',$
                  camcol:0L,field:0L,ID:0L}
            new= replicate(new,n_elements(calibobj))
            new.psfflux= calibobj.psfflux_clean
            new.psfflux_ivar= calibobj.psfflux_clean_ivar
            new.ra= calibobj.ra
            new.dec= calibobj.dec
            new.run= calibobj.run
            new.rerun= calibobj.rerun
            new.camcol= calibobj.camcol
            new.field= calibobj.field
            new.id= calibobj.id
            comb_clean= add_data(new,galexdata=galexdata,ukidssdata=ukidssdata)
            calibobj= struct_selecttags(calibobj,$
                                        except_tags=['psfflux',$
                                                     'psfflux_ivar',$
                                                     'extinction', $
                                                     'psfflux_clean',$
                                                     'psfflux_clean_ivar'])
            newStruct= {psfflux: dblarr(nfluxes), $
                        psfflux_ivar: dblarr(nfluxes), $
                        psfflux_clean: dblarr(nfluxes), $
                        psfflux_clean_ivar: dblarr(nfluxes), $
                        extinction: dblarr(nfluxes)}
        endelse
        newStruct= replicate(newStruct,n_elements(calibobj))
        nnewfluxes= n_elements(comb[0].psfflux)
        newStruct.psfflux[0:nnewfluxes-1]= comb.psfflux
        newStruct.psfflux_ivar[0:nnewfluxes-1]= comb.psfflux_ivar
        if keyword_set(clean) and keyword_set(dr9) then begin
            newStruct.psfflux_clean[0:nnewfluxes-1]= comb_clean.psfflux
            newStruct.psfflux_clean_ivar[0:nnewfluxes-1]= comb_clean.psfflux_ivar
        endif
        newStruct.extinction[0:nnewfluxes-1]= comb.extinction
        extraOut[iindxt]= struct_combine(calibobj,newStruct)
    endif else begin
        extraOut[iindxt]= calibobj
    endelse
ENDFOR
out= struct_combine(in,extraOut)
;;Save
mwrfits, out, outfile, /create
END
