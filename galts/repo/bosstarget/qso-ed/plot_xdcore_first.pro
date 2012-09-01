PRO PLOT_XDCORE_FIRST, infile, plotfile, tmpfile

in= mrdfits(infile,1)
indx= where(in.pqso ne -1D)
in= in[indx]

k_print, filename=plotfile+'_hist.ps'
hogg_plothist, in.pqso, xtitle='P(quasar)', ytitle='# FIRST objects',/totalweight
k_end_print

;;Create catalog of all matching FIRST sources
bq = obj_new('bosstarget_qso')
IF ~file_test(tmpfile) THEN BEGIN
    data= mrdfits('../../data/first_08jul16.fits',1)
    nobj= n_elements(in.ra)
    spherematch, in.ra, in.dec, data.ra, data.dec, 0.5/3600., iindx, dindx
    out= data[dindx]
    in= in[iindx]

    calibobj= read_calibobj(2964,camcol=1)
    extraOutStruct= calibobj[0]
    extraOut= replicate(extraOutStruct,nobj)
    iid= sdss_photoid(in) 
    runs= in[UNIQ(in.run, SORT(in.run))].run
    nruns= n_elements(runs)
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

bad= out[where(in.pqso LT 0.05)]
k_print, filename=plotfile+'_modelpsfflux.ps'
hogg_plothist, bad.psfflux[2]-bad.modelflux[2], xtitle='PSF flux - modeflux in r',/totalweight, $
  xrange=[0.,0.1]
k_end_print


prep_data, bad.psfflux, bad.psfflux_ivar, extinction=bad.extinction, $
  mags=mags,var_mags=var_mags

k_print, filename=plotfile+'_ihist.ps'
hogg_plothist, mags[3,*], xtitle='i [mag]', ytitle='# FIRST objects',/totalweight
k_end_print

k_print, filename=plotfile+'_ug-gr.ps'
djs_plot, mags[0,*]-mags[1,*], mags[1,*]-mags[2,*], $
  psym=3, xtitle='u-g',ytitle='g-r', $
  xrange=[-1,5],yrange=[-.6,4], title='FIRST objects with p(QSO) < 0.05'
k_end_print

k_print, filename=plotfile+'_gr-ri.ps'
djs_plot, mags[1,*]-mags[2,*], mags[2,*]-mags[3,*], $
  psym=3, ytitle='r-i',xtitle='g-r', $
  yrange=[-.6,2.6],xrange=[-.6,4]
k_end_print

k_print, filename=plotfile+'_ri-iz.ps'
djs_plot, mags[2,*]-mags[3,*], mags[3,*]-mags[4,*], $
  psym=3, xtitle='r-i',ytitle='i-z', $
  xrange=[-.6,2.6],yrange=[-.5,2.5]
k_end_print

k_print, filename=plotfile+'_radec.ps'
djs_plot, bad.ra, bad.dec, psym=3, xtitle='RA [deg]', ytitle='Dec [deg]'
k_end_print


prep_data, out.psfflux, out.psfflux_ivar, extinction=out.extinction, $
  mags=mags,var_mags=var_mags
bright= out[where(in.pqso LT 0.1 and mags[3,*] LT 21)]
known= mrdfits('../../data/knownquasarstar.060910.fits',1)
spherematch, known.ra, known.dec, bright.ra, bright.dec, 1.5/3600.,$
  kindx,bindx
print, "FIRST p(QSO) < 0.1 and known: ", n_elements(kindx), n_elements(bright.ra)
k_print, filename=plotfile+'_knownfirst_z.ps'
hogg_plothist,known[kindx].zem, xtitle='z',/totalweight, $
  title='FIRST sources with p(QSO) < 0.1'
k_end_print
END
