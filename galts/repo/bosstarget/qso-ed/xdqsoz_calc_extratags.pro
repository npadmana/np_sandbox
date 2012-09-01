PRO XDQSOZ_CALC_EXTRATAGS, psfflux, psfflux_ivar, extinction, tmpfile, $
                           nzs=nzs, nother=nother, galex=galex,ukidss=ukidss, $
                           ggalex_used=ggalex_used, $
                           uukidss_used=uukidss_used
nobj= n_elements(psfflux_ivar[0,*])
extraTags= xdqsoz_extratags_struct(nother)
extraTags= replicate(extraTags,nobj)
FOR ii=0L, nobj-1 DO BEGIN
    print, format = '("Working on ",i7," of ",i7,a1,$)', $
      ii+1,nobj,string(13B)
    ;;Calculate redshift information
        if keyword_set(galex) and keyword_set(ukidss) then begin
            ;;check whether there actually is galex and ukidss
            if ggalex_used[ii] and uukidss_used[ii] then begin
                flux= sdss_deredden(psfflux[*,ii],extinction[*,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[*,ii],extinction[*,ii])
                thisgalex= 1
                thisukidss= 1
            endif else if ggalex_used[ii] then begin
                flux= sdss_deredden(psfflux[0:6,ii],extinction[0:6,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[0:6,ii],extinction[0:6,ii])
                thisgalex= 1
                thisukidss= 0
            endif else if uukidss_used[ii] then begin
                flux= sdss_deredden(psfflux[0:8,ii],extinction[0:8,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[0:8,ii],extinction[0:8,ii])
                thisgalex= 0
                thisukidss= 1
            endif else begin
                flux= sdss_deredden(psfflux[0:4,ii],extinction[0:4,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[0:4,ii],extinction[0:4,ii])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else if keyword_set(galex) then begin
            if ggalex_used[ii] then begin
                flux= sdss_deredden(psfflux[*,ii],extinction[*,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[*,ii],extinction[*,ii])
                thisgalex= 1
                thisukidss= 0
            endif else begin
                flux= sdss_deredden(psfflux[0:4,ii],extinction[0:4,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[0:4,ii],extinction[0:4,ii])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else if keyword_set(ukidss) then begin
            if uukidss_used[ii] then begin
                flux= sdss_deredden(psfflux[*,ii],extinction[*,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[*,ii],extinction[*,ii])
                thisgalex= 0
                thisukidss= 1
            endif else begin
                flux= sdss_deredden(psfflux[0:4,ii],extinction[0:4,ii])
                flux_ivar= sdss_deredden_error(psfflux_ivar[0:4,ii],extinction[0:4,ii])
                thisgalex= 0
                thisukidss= 0
            endelse                
        endif else begin
            flux= sdss_deredden(psfflux[*,ii],extinction[*,ii])
            flux_ivar= sdss_deredden_error(psfflux_ivar[*,ii],extinction[*,ii])
        endelse
    npeaks= xdqsoz_peaks(flux,flux_ivar,$
                         nzs=nzs,xdqsoz=xdqsoz,galex=thisgalex,ukidss=thisukidss)
    extraTags[ii].npeaks= npeaks
    extraTags[ii].peakz= xdqsoz.peakz
    extraTags[ii].peakprob= xdqsoz.peakprob
    extraTags[ii].peakfwhm= xdqsoz.peakfwhm
    if npeaks GT (nother+1) or npeaks LE 1 then continue
    CATCH, Error_status ;;catch annoying bug
    IF Error_status NE 0 THEN BEGIN  
        PRINT, 'Error index: ', Error_status  
        PRINT, 'Error message: ', !ERROR_STATE.MSG  
        extraTags[ii].otherz= -9999.99
        extraTags[ii].otherprob= -9999.99
        extraTags[ii].otherfwhm= -9999.99
        CATCH, /CANCEL  
    ENDIF ELSE BEGIN
        extraTags[ii].otherz[0:npeaks-2]= xdqsoz.otherz
        extraTags[ii].otherprob[0:npeaks-2]= xdqsoz.otherprob
        extraTags[ii].otherfwhm[0:npeaks-2]= xdqsoz.otherfwhm
    ENDELSE
ENDFOR
mwrfits, extraTags, tmpfile,/create
END
