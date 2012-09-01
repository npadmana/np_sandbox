;+
;   NAME:
;      ADM_zdist
;   PURPOSE:
;      make a redshift distribution of the QSOs found by ExD
;   INPUT:
;      savefilename - name of the file that holds the targets
;      plotfilename
;      chunk - 1 or 2
;   OPTIONAL INPUT:
;      lumfunc - QSO luminosity function to use ('HRH07' or 'R06';
;                default= 'HRH07')
;   OUTPUT:
;      a figure
;   BUGS:
;      paths not universal
;   HISTORY:
;      2010-05-12 - Written - Bovy (NYU) 
;-
PRO ADM_ZDIST, savefilename=savefilename, plotfilename=plotfilename, $
                   treshold=treshold, chunk=chunk, lumfunc=lumfunc
IF ~keyword_set(lumfunc) THEN lumfunc= 'HRH07';;CHANGED
IF ~keyword_set(chunk) THEN chunk= 1
IF chunk EQ 1 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk1truth_270410_ADM.fits'
    IF ~keyword_set(savefilename) THEN savefilename= 'chunk1_extreme_deconv_'+lumfunc+'.fits'
    specarea= 81.2
    area= 219.93
ENDIF ELSE IF chunk EQ 2 THEN BEGIN
    datafilename= '$BOVYQSOEDDATA/chunk2truth_200410_ADM.fits'
    IF ~keyword_set(savefilename) THEN savefilename= 'chunk2_extreme_deconv_'+lumfunc+'.fits'
    specarea= 95.7
    area= 143.66
ENDIF ELSE BEGIN
    print, "No chunk "+strtrim(chunk)
    print, "returning ..."
    RETURN
ENDELSE
print, savefilename
IF ~keyword_set(treshold) THEN treshold= 20
in=mrdfits(savefilename,1)
sortindx= REVERSE(SORT(in.pqso))
data= mrdfits(datafilename,1)
targetindx= sortindx[0:floor(treshold*area)]
indx= where(data[targetindx].zem GE 2.2,complement=fails); AND in[0:floor(treshold*area)].z LT 3.5)
print, n_elements(indx)/specarea
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags, var_mags=ycovar
;indxcut= where((mags[1,*] LT 22 OR mags[2,*] LT 21.85) AND mags[3,*]  GT 17.8,complement=nindx)
;data= data[indxcut]

failed= data[targetindx[fails]]
;; Add J. Hennawi's high-z tags for the objects in the catalog
X2_struct  = add_x2_tags(failed)
;failed = struct_addtags(failed, X2_struct)

data=data[targetindx[indx]]

prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=mags,var_mags=var_mags,/colors
prep_data, data.psfflux, data.psfflux_ivar, extinction=data.extinction, $
  mags=imags,var_mags=var_mags

k_print, filename=plotfilename

hogg_plothist, data.zem, /totalweight, xtitle='redshift', $
  ytitle='Number of QSO',$
  title=strtrim(string(treshold),2)+textoidl(" fibers / deg^2 !96!X  ")+strtrim(string(n_elements(indx)/specarea,format='(F4.2)'),2)+textoidl(" QSO / deg^2"), $
  xrange=[2.2,3.6]

k_end_print

END
