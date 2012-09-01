;+
;-
PRO PLOT_NUMBERCOUNTS, correct=correct, attenuate=attenuate, $
                       everythingcorrect=everythingcorrect

;;Read the differential number counts
dndi_qsobosszfile= '../data/dNdi_hiz_zmin_2.20_zmax_3.5_HRH07.prt'
dndi_qsofile= '../data/dNdi_hiz_zmin_2.15_zmax_6.0_HRH07.prt'
dndi_qsolowzfile= '../data/dNdi_lowz_zmin_0.30_zmax_2.15_HRH07.prt'
dndi_everythingfile= '../data/dNdi_everything_coadd_1.4.prt'
dndi_chunk2file= '../data/dNdi_chunk2.prt'
read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, correct=correct, attenuate=attenuate
read_dndi, dndi_qsofile, i_qso, dndi_qso, correct=correct, attenuate=attenuate
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, correct=correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything, everythingcorrect=everythingcorrect
read_dndi, dndi_chunk2file, i_chunk2, dndi_chunk2

dndi_qsobossz= dndi_qsobossz/(total(dndi_qsobossz)*(i_qsobossz[1]-i_qsobossz[0]))
dndi_qso= dndi_qso/(total(dndi_qso)*(i_qso[1]-i_qso[0]))
dndi_qsolowz= dndi_qsolowz/(total(dndi_qsolowz)*(i_qsolowz[1]-i_qsolowz[0]))
dndi_everything= dndi_everything/(total(dndi_everything)*(i_everything[1]-i_everything[0]))
dndi_chunk2= dndi_chunk2/(total(dndi_chunk2)*(i_chunk2[1]-i_chunk2[0]))

djs_plot, i_qsobossz, dndi_qsobossz
djs_oplot, i_qso, dndi_qso, color=djs_icolor('red')
djs_oplot, i_qsolowz, dndi_qsolowz, color=djs_icolor('blue')
djs_oplot, i_everything, dndi_everything, color=djs_icolor('green')
djs_oplot, i_chunk2, dndi_chunk2, color=djs_icolor('yellow')

END
