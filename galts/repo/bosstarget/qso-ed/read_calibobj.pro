;+
;   NAME:
;      read_calibobj
;   PURPOSE:
;      read (a) calibobj file(s)
;   CALLING SEQUENCE:
;      sweep= read_calibobj(308)
;   INPUT:
;      run - run
;      camcol - a camcol or list of camcols (not given means all
;               camcols)
;      type - 'star', gal', or 'sky'
;   KEYWORDS:
;      galex - add galex
;      dr9 - read dr9 data sweep
;   OUTPUT:
;      calibObj struct
;   HISTORY:
;      2010-08-01 - Written - Bovy (NYU)
;-
FUNCTION READ_CALIBOBJ, run, camcol=camcol,type=type, silent=silent, $
                        galex=galex, dr9=dr9
if keyword_set(dr9) then begin
    sweepsdir= '/mount/coma1/bw55/sdss3/mirror/dr9/boss/sweeps/dr9/301/'
endif else begin
    sweepsdir= '$SDSS_DATASWEEPS/'
endelse
galexdir= '$SDSS_GALEX_DATASWEEPS/'
IF ~keyword_set(camcol) THEN BEGIN
    camcols= [1,2,3,4,5,6]
ENDIF ELSE IF n_elements(camcol) EQ 1 THEN BEGIN
    camcols= [camcol]
ENDIF ELSE BEGIN
    camcols= camcol
ENDELSE
IF ~keyword_set(type) THEN type= 'star'

runstr= strtrim(string(run,format='(I6.6)'),2)
IF n_elements(camcols) EQ 1 THEN BEGIN
    camcolstr= strtrim(string(camcol,format='(I1)'),2)
    sweepsfilename= sweepsdir+'calibObj-'+$
      runstr+'-'+$
      camcolstr+'-'+type+'.fits.gz'
    galexfilename= galexdir+'aper_calibObj-'+$
      runstr+'-'+$
      camcolstr+'-'+type+'.fits.gz'
    if ~keyword_set(galex) then $
      return, mrdfits(sweepsfilename,1,silent=silent) $
    else $
      return, struct_combine(mrdfits(sweepsfilename,1,silent=silent),$
                             mrdfits(galexfilename,1,silent=silent))
ENDIF ELSE BEGIN
    camcolstr= strtrim(string(camcols[0],format='(I1)'),2)
    sweepsfilename= sweepsdir+'calibObj-'+$
      runstr+'-'+$
      camcolstr+'-'+type+'.fits.gz'
    galexfilename= galexdir+'aper_calibObj-'+$
      runstr+'-'+$
      camcolstr+'-'+type+'.fits.gz'
    if ~keyword_set(galex) then $
      out= mrdfits(sweepsfilename,1,silent=silent) $
    else $
      out= struct_combine(mrdfits(sweepsfilename,1,silent=silent),$
                          mrdfits(galexfilename,1,silent=silent))
    FOR ii=1L, n_elements(camcols)-1 DO BEGIN
        camcolstr= strtrim(string(camcols[ii],format='(I1)'),2)
        sweepsfilename= sweepsdir+'calibObj-'+$
          runstr+'-'+$
          camcolstr+'-'+type+'.fits.gz'
        galexfilename= galexdir+'aper_calibObj-'+$
          runstr+'-'+$
          camcolstr+'-'+type+'.fits.gz'
        if ~keyword_set(galex) then $
          out= [out,mrdfits(sweepsfilename,1,silent=silent)] $
        else $
          out= [out,struct_combine(mrdfits(sweepsfilename,1,silent=silent),$
                                   mrdfits(galexfilename,1,silent=silent))]
    ENDFOR
    return, out
ENDELSE
END
