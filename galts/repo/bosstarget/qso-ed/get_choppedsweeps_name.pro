FUNCTION GET_CHOPPEDSWEEPS_NAME, ii, min=min, max=max, width=width, $
                                 spacing=spacing, path=path
IF ~keyword_set(min) THEN min= 12.9
IF ~keyword_set(max) THEN max= 22.5
IF ~keyword_set(width) THEN width= 0.2
IF ~keyword_set(spacing) THEN spacing= 0.1

IF keyword_set(path) THEN return, '/mount/hydra4/jb2777/sdss/choppedsweeps/301/'+get_choppedsweeps_name(ii,min=min,max=max,width=width,spacing=spacing) ELSE return, 'choppedsweeps_'+strtrim(string(ii),2)+'_'+$
  strtrim(string(min,format='(F4.1)'),2)+'_'+$
  strtrim(string(max,format='(F4.1)'),2)+'_'+$
  strtrim(string(width,format='(F3.1)'),2)+'_'+$
  strtrim(string(spacing,format='(F3.1)'),2)+'.fits'

END
