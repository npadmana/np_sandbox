;+
;   NAME:
;      add_data
;   PURPOSE:
;      add galex and ukidss data to sdss data
;   INPUT:
;      sdssdata - struct with psfflux, psfflux_ivar, and extinction
;                 tags
;      galexdata - struct with galex data, nuv_flux, nuv_fluxerr,
;                  fuv_flux, fuv_fluxerr
;      ukidssdata - struct with ukidss data
;   OPTIONAL INPUT:
;      savefilename - if set, save output struct to this fits file
;   OUTPUT:
;      struct with psfflux, psfflux_ivar, and extinction tags, for all
;      of the data (sdss+galex+ukidss)
;   HISTORY:
;      2010-05-29 - Written - Bovy (NYU)
;-
FUNCTION ADD_DATA, sdssdata, galexdata=galexdata, ukidssdata=ukidssdata, $
                   savefilename=savefilename, byid=byid, $
                   raw_uv_matches=raw_uv_matches, $
                   raw_nir_matches=raw_nir_matches

; indices of all matches
raw_uv_matches=-1
raw_nir_matches=-1

IF keyword_set(galexdata) THEN BEGIN
    IF (tag_exist(sdssdata,'run') AND $
              tag_exist(sdssdata,'rerun') AND $
              tag_exist(sdssdata,'camcol') AND $
              tag_exist(sdssdata,'field') AND $
              tag_exist(sdssdata,'id') AND $
              tag_exist(galexdata,'run') AND $
              tag_exist(galexdata,'rerun') AND $
              tag_exist(galexdata,'camcol') AND $
              tag_exist(galexdata,'field') AND $
              tag_exist(galexdata,'id')) OR keyword_set(byid) THEN begin

          get_uv_fluxes, galexdata, uvflux, uvflux_ivar, uvextinction, sdssdata, $
              /byid, raw_matches=raw_uv_matches

    endif ELSE begin
        get_uv_fluxes, galexdata, uvflux, uvflux_ivar, uvextinction, sdssdata, $
            raw_matches=raw_uv_matches
    endelse
ENDIF ELSE BEGIN
    uvflux= 0.
    uvflux_ivar= 0.
    uvextinction= 0.
ENDELSE
IF keyword_set(ukidssdata) THEN BEGIN
    IF (tag_exist(sdssdata,'run') AND $
                tag_exist(sdssdata,'rerun') AND $
                tag_exist(sdssdata,'camcol') AND $
                tag_exist(sdssdata,'field') AND $
                tag_exist(sdssdata,'id') AND $
                tag_exist(ukidssdata,'run') AND $
                tag_exist(ukidssdata,'rerun') AND $
                tag_exist(ukidssdata,'camcol') AND $
                tag_exist(ukidssdata,'field') AND $
                tag_exist(ukidssdata,'id')) OR keyword_set(byid) THEN begin

        get_nir_fluxes, ukidssdata, nirflux, nirflux_ivar, nirextinction, $
            sdssdata, /byid, raw_matches=raw_nir_matches
    endif ELSE begin
        get_nir_fluxes, ukidssdata, nirflux, nirflux_ivar, nirextinction, sdssdata, $
            raw_matches=raw_nir_matches
    endelse
ENDIF ELSE BEGIN
    nirflux= 0.
    nirflux_ivar= 0.
    nirextinction= 0.
ENDELSE
    combine_fluxes, sdssdata.psfflux, sdssdata.psfflux_ivar, sdssdata.extinction, $
      anirflux=nirflux, $
      bnirflux_ivar=nirflux_ivar, $
      cnirextinction= nirextinction, duvflux=uvflux, $
      euvflux_ivar=uvflux_ivar, fuvextinction=uvextinction, $
      nir=keyword_set(ukidssdata), $
      uv=keyword_set(galexdata), $
      fluxout=flux, ivarfluxout=flux_ivar, $
      extinctionout=extinction

ndata= n_elements(flux[0,*])
nfluxes= n_elements(flux[*,0])
outStruct= {psfflux: dblarr(nfluxes), psfflux_ivar: dblarr(nfluxes), $
            extinction: dblarr(nfluxes)}
combineddata= replicate(outStruct,ndata)
combineddata.psfflux= flux
combineddata.psfflux_ivar= flux_ivar
combineddata.extinction= extinction

IF keyword_set(savefilename) THEN mwrfits, combineddata, savefilename, /create
RETURN, combineddata
END
mwrfits, rank, 'galextest_nogalex.fits', /create
