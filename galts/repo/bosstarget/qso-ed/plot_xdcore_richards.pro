PRO PLOT_XDCORE_RICHARDS, infile, plotfile, tmpfile

in= mrdfits(infile,1)
data= mrdfits('$BOVYQSOEDDATA/nbckde_dr6_uvx_highz_faint_qsos_021908.cat.rasort.match.hennawi.072408.fits',1)
spherematch, in.ra, in.dec, data.ra, data.dec, 2./3600., iindx, dindx
in= in[iindx]
data= data[dindx]
indx= where(in.pqso ne -1D and data.uvxts EQ 1)
in= in[indx]
data= data[indx]

k_print, filename=plotfile+'_histqso.ps'
hogg_plothist, in.pqso, xtitle='P(quasar)', ytitle=textoidl('log_{10} # UVX objects'), /totalweight, $
  title='Richards+09 UVX objects', /log
k_end_print

;;Create catalog of all matching sources
bq = obj_new('bosstarget_qso')
IF ~file_test(tmpfile) THEN BEGIN
    nobj= n_elements(in.ra)
    out= data

    calibobj= read_calibobj(2964,camcol=1)
    extraOutStruct= calibobj[0]
    extraOut= replicate(extraOutStruct,nobj)
    runs= in[UNIQ(in.run, SORT(in.run))].run
    nruns= n_elements(runs)
    iid= sdss_photoid(in)
    FOR ii=0L, nruns-1 DO BEGIN
        print, ii, nruns
        calibobj= READ_CALIBOBJ(runs[ii], type='star')
	;limit to things that are survey primary
	resolve_bitmask = bq->resolve_logic(calibobj)
	w = where(resolve_bitmask eq 0,cnt)
	if cnt gt 0 then calibobj = calibobj[w] else continue
        ;calib_bitmask = bq->calib_logic(calibobj)
	;w = where(calib_bitmask eq 0,cnt)
	;if cnt gt 0 then calibobj = calibobj[w] else continue
        cid= sdss_photoid(calibobj)
        match, cid, iid, cindx, iindxt, /sort
        extraOut[iindxt]= calibobj[cindx]
    ENDFOR
    out= struct_combine(out,extraOut)
    save, filename=tmpfile, out
ENDIF ELSE BEGIN
    restore, tmpfile
ENDELSE


bad= out[where(in.pqso LT 0.05 and data.uvxts EQ 1)]
prep_data, bad.psfflux, bad.psfflux_ivar, extinction=bad.extinction, $
  mags=mags,var_mags=var_mags

k_print, filename=plotfile+'_pzero_ihist.ps'
hogg_plothist, mags[3,*], xtitle='i [mag]', /totalweight
k_end_print

k_print, filename=plotfile+'_pzero_snihist.ps'
hogg_plothist, bad.psfflux[3]*sqrt(bad.psfflux_ivar[3]), xtitle='SNR in i band [mag]', /totalweight
k_end_print

k_print, filename=plotfile+'_pzero-ug-gr.ps'
djs_plot, mags[0,*]-mags[1,*], mags[1,*]-mags[2,*], $
  psym=3, xtitle='u-g',ytitle='g-r', $
  xrange=[-1,5],yrange=[-.6,4], title='QSO with p(QSO) < 0.05'
k_end_print

k_print, filename=plotfile+'_pzero-gr-ri.ps'
djs_plot, mags[1,*]-mags[2,*], mags[2,*]-mags[3,*], $
  psym=3, ytitle='r-i',xtitle='g-r', $
  yrange=[-.6,2.6],xrange=[-.6,4]
k_end_print

k_print, filename=plotfile+'_pzero-ri-iz.ps'
djs_plot, mags[2,*]-mags[3,*], mags[3,*]-mags[4,*], $
  psym=3, xtitle='r-i',ytitle='i-z', $
  xrange=[-.6,2.6],yrange=[-.5,2.5]
k_end_print

k_print, filename=plotfile+'_pzero_radec.ps'
djs_plot, bad.ra, bad.dec, psym=3, xtitle='RA [deg]', ytitle='Dec [deg]'
k_end_print


END
