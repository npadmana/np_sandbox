;+
;   NAME:
;      plot_numcounts
;   PURPOSE:
;      plot the number count priors for the different classes
;   INPUT:
;      outfile - filename for plot
;   OUTPUT:
;       (none)
;   HISTORY:
;      2010-08-30 - Written - Bovy (NYU)
;-
PRO RESTRICT_RANGE, i, dndi
indx= where(i GE 17.75 and i LT 22.45)
i= i[indx]
dndi= dndi[indx]
END
FUNCTION NORMALIZE_NUMCOUNTS, i, dndi
print, total(dndi)*(i[1]-i[0])
RETURN, dndi/total(dndi)/(i[1]-i[0])
END
PRO PLOT_NUMCOUNTS, outfile

;;Read the differential number counts
dataDir= '$BOSSTARGET_DIR/data/qso-ed/numcounts/'
lumfunc= 'HRH07'
dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
dndi_qsofile= dndipath(3.5,6.,lumfunc)
dndi_qsolowzfile= 'dNdi_zmin_0.30_zmax_2.20_HRH07.prt'
dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'

read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything

;;Restrict each to the right range
restrict_range, i_qsobossz, dndi_qsobossz
restrict_range, i_qso, dndi_qso
restrict_range, i_qsolowz, dndi_qsolowz
restrict_range, i_everything, dndi_everything

;;normalize each
dndi_qsobossz= normalize_numcounts(i_qsobossz,dndi_qsobossz)
dndi_qso= normalize_numcounts(i_qso,dndi_qso)
dndi_qsolowz= normalize_numcounts(i_qsolowz,dndi_qsolowz)
dndi_everything= normalize_numcounts(i_everything,dndi_everything)

;;Plot
k_print, filename=outfile

djs_plot, i_qso, dndi_qso, xtitle='i [mag]', ytitle='normalized dN/di [mag^{-1}]',linestyle=1
djs_oplot, i_qsobossz, dndi_qsobossz, linestyle=0
djs_oplot, i_qsolowz, dndi_qsolowz, linestyle=2
djs_oplot, i_everything, dndi_everything, linestyle=3

;;add legend
legend, ['2.2 !9l!x z !9l!x 3.5', 'z > 3.5', 'z < 2.2', 'star'], $
  linestyle=indgen(4), /left, /top, box=0., charsize=1.4

k_end_print
END
