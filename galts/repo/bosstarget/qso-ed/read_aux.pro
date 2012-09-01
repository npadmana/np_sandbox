FUNCTION READ_AUX, run=run,ukidss=ukidss
basedir='$BOSSTARGET_DATA/'
basedir+= 'ukidss/bycamcol/ukidss-'
files= file_search(basedir+'*.fits',/test_regular)
IF keyword_set(run) THEN BEGIN
    ;;match
    match_indx= lonarr(n_elements(files))
    for ii=0L, n_elements(run)-1 do begin
        match_indx+= strmatch(files,'*-'+strtrim(string(run[ii],format='(I06)'),2)+'*.fits')
    endfor
    indx= where(match_indx EQ 1,cnt)
    IF cnt GT 0 then files= files[indx] else return, {run:-1}
ENDIF
return, mrdfits_multi(files,/silent)
END
