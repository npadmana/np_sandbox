FUNCTION READ_GALEX, run=run, camcol=camcol
basedir='$BOSSTARGET_DATA/'
basedir+= 'galex/bycamcol/aper_calibObj-'
files= file_search(basedir+'*.fits.gz',/test_regular)
IF ~keyword_set(run) THEN BEGIN
    runs= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/dr8runs.fits',1,/silent)
    run= runs.run
ENDIF
IF ~keyword_set(camcol) then camcol= [1,2,3,4,5,6]
;;match
match_indx= lonarr(n_elements(files))
ii= 0L
jj= 0L
galexfile= basedir+strtrim(string(run[ii],format='(I06)'),2)+$
  '-'+strtrim(string(camcol[jj],format='(I1)'),2)+'-star.fits.gz'
galex= mrdfits(galexfile,1,/silent)
calibobj= extract_tags(read_calibobj(run[ii],camcol=camcol[jj],$
                                     type='star',/silent),$
                       ['RA','DEC','RUN','RERUN','CAMCOL','FIELD','ID'])
out= struct_combine(galex,calibobj)
for jj=1L, n_elements(camcol)-1 do begin
    galexfile= basedir+strtrim(string(run[ii],format='(I06)'),2)+$
      '-'+strtrim(string(camcol[jj],format='(I1)'),2)+'-star.fits.gz'
    galex= mrdfits(galexfile,1,/silent)
    calibobj= extract_tags(read_calibobj(run[ii],camcol=camcol[jj],$
                                         type='star',/silent),$
                           ['RA','DEC','RUN','RERUN','CAMCOL','FIELD','ID'])
    out= [out,struct_combine(galex,calibobj)]
endfor
for ii=1L, n_elements(run)-1 do begin
    for jj= 0L, n_elements(camcol)-1 do begin
        galexfile= basedir+strtrim(string(run[ii],format='(I06)'),2)+$
          '-'+strtrim(string(camcol[jj],format='(I1)'),2)+'-star.fits.gz'
        galex= mrdfits(galexfile,1,/silent)
        calibobj= extract_tags(read_calibobj(run[ii],camcol=camcol[jj],type='star',/silent),$
                               ['RA','DEC','RUN','RERUN','CAMCOL','FIELD','ID'])
        out= [out,struct_combine(galex,calibobj)]
    endfor
endfor
return, out
END
