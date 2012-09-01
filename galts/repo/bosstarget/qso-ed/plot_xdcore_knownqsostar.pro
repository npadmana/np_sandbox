PRO PLOT_XDCORE_KNOWNQSOSTAR, infile, plotfile, tmpfile

in= mrdfits(infile,1)
indx= where(in.pqso ne -1D)
in= in[indx]

k_print, filename=plotfile+'_histqso.ps'
hogg_plothist, in[where(in.zem GT 0.1)].pqso, xtitle='P(quasar)', ytitle='# known quasar', /totalweight, /log
k_end_print

k_print, filename=plotfile+'_histqsolowz.ps'
hogg_plothist, in[where(in.zem GT 0.1 and in.zem LT 2.2)].pqsolowz, xtitle='P(low-z quasar)', ytitle=textoidl('log_{10} # known low-z quasar'), /totalweight, /log
k_end_print

k_print, filename=plotfile+'_histqsomidz.ps'
hogg_plothist, in[where(in.zem GE 2.2 and in.zem LE 3.5)].pqsomidz, xtitle='P(mid-z quasar)', ytitle='# known mid-z quasar', /totalweight
hogg_plothist, in[where(in.zem GE 2.2 and in.zem LE 3.5)].pstar, /overplot, /totalweight,linestyle=2
k_end_print

k_print, filename=plotfile+'_histqsohiz.ps'
hogg_plothist, in[where(in.zem GT 3.5)].pqsohiz, xtitle='P(high-z quasar)', ytitle='# known high-z quasar', /totalweight
hogg_plothist, in[where(in.zem GT 3.5)].pstar, /overplot, /totalweight,linestyle=2
k_end_print

k_print, filename=plotfile+'_histstar.ps'
hogg_plothist, in[where(in.zem LT 0.1)].pqso, xtitle='P(quasar)', ytitle=textoidl('log_{10} # known stars'), /totalweight, /log
k_end_print


;;Create catalog of all matching sources
bq = obj_new('bosstarget_qso')
IF ~file_test(tmpfile) THEN BEGIN
    data= mrdfits('../../data/knownquasarstar.060910.fits',1)
    nobj= n_elements(in.ra)
    spherematch, in.ra, in.dec, data.ra, data.dec, 1.5/3600., iindx, dindx
    out= data[dindx]
    in= in[iindx]

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


bad= out[where(in.pqso LT 0.05 and in.zem GT 0.1)]
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
  xrange=[-1,5],yrange=[-.6,4], title='QSO with P(QSO) < 0.05'
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
