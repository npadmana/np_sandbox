;+
;   NAME:
;      dndipath
;   PURPOSE:
;      return the path to the dndi function for a certain redshift and
;      luminosity function
;   INPUT:
;      zmin, zmax - redshift range
;      lumfunc - luminosity function ('HRH07' or 'R06')
;   OUTPUT:
;      full path
;   HISTORY:
;      2010-05-06 - Written - Bovy (NYU)
;-
FUNCTION DNDIPATH, zmin, zmax, lumfunc
path = '$BOSSTARGET_DIR/data/qso-ed/numcounts/'
path+= 'dNdi_zmin_'+strtrim(string(zmin,format='(F4.2)'),2)+'_zmax_'+strtrim(string(zmax,format='(F4.2)'),2)+'_'+lumfunc+'.prt'
return, path
END
