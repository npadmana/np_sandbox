PRO SANITYCHECK_XDCORE, run, xdcoredir=xdcoredir,outdir=outdir
_MAXSCATTER= 2000L
IF ~keyword_set(xdcoredir) THEN xdcoredir= '/mount/hydra4/jb2777/sdss/xd/core/301/'
IF ~keyword_set(outdir) THEN outdir= '/mount/hydra4/jb2777/sdss/xd/core_primary_check/301/'

outname= xdcoredir+'xdcore_'+strtrim(string(run,format='(I6.6)'),2)+'.fits'
xd= mrdfits(outname,1)

;;Let's look at the color-color plots for alleged QSOs and stars
xdqso= xd[where(xd.good EQ 0L AND xd.pqso GT 0.5)]
xdstar= xd[where(xd.good EQ 0L AND xd.pstar GT 0.95)]

;;Photometry
calib= read_calibobj(run,type='star')

;;QSO match to photometry
pid1= sdss_photoid(xdqso)
pid2= sdss_photoid(calib)
match, pid1, pid2, m1, m2, /sort
calibqso= calib[m2]

prep_data, calibqso.psfflux, calibqso.psfflux_ivar, $
  extinction=calibqso.extinction,  mags=mags, var_mags=var_mags,/colors

plotfilebase= outdir+'xdcore-check-'+strtrim(string(run,format='(I6.6)'),2)+'-'
k_print, filename=plotfilebase+'qso-ug-gr.ps'
charsize=1.1
IF n_elements(mags[0,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[0,*], mags[1,*], $
      ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), psym=3, xrange=[-1,5],$
      yrange=[-.6,4], /outliers, outcolor=djs_icolor('black'), $
      title='run '+strtrim(string(run),2), /internal_weight, charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[0,*], mags[1,*], psym=3, xtitle='u-g',ytitle='g-r', $
      xrange=[-1,5],yrange=[-.6,4], title='run '+strtrim(string(run),2), charsize=charsize
ENDELSE
legend, [strtrim(string(n_elements(mags[0,*])),2)+' objects with p(quasar) > 0.5'], $
  box= 0., /right,/top, charsize=1.4
k_end_print


k_print, filename=plotfilebase+'qso-gr-ri.ps'
ndata= n_elements(mags[1,*])
IF ndata GT 100000 THEN BEGIN
    levels= errorf(0.5*(dindgen(4)+1))
ENDIF ELSE BEGIN
    levels= errorf(0.5*(dindgen(3)+1))
ENDELSE
IF n_elements(mags[1,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[1,*], mags[2,*], $
      xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), psym=3, xrange=[-.6,4],$
      yrange=[-.6,2.6], /outliers, outcolor=djs_icolor('black'), $
      /internal_weight, levels=levels, charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[1,*], mags[2,*], psym=3, ytitle='r-i',xtitle='g-r', $
      yrange=[-.6,2.6],xrange=[-.6,4]
ENDELSE
k_end_print

k_print, filename=plotfilebase+'qso-ri-iz.ps'
ndata= n_elements(mags[2,*])
IF ndata GT 100000 THEN BEGIN
    levels= errorf(0.5*(dindgen(4)+1))
ENDIF ELSE BEGIN
    levels= errorf(0.5*(dindgen(3)+1))
ENDELSE
IF n_elements(mags[2,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[2,*], mags[3,*], $
      ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), psym=3, yrange=[-.5,2.5],$
      xrange=[-.6,2.6], /outliers, outcolor=djs_icolor('black'), $
      /internal_weight, levels=levels, charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[2,*], mags[3,*], psym=3, xtitle='r-i',ytitle='i-z', $
      xrange=[-.6,2.6],yrange=[-.5,2.5]
ENDELSE
k_end_print





;;star match to photometry
pid1= sdss_photoid(xdstar)
pid2= sdss_photoid(calib)
match, pid1, pid2, m1, m2, /sort
calibqso= calib[m2]

prep_data, calibqso.psfflux, calibqso.psfflux_ivar, $
  extinction=calibqso.extinction,  mags=mags, var_mags=var_mags,/colors

plotfilebase= outdir+'xdcore-check-'+strtrim(string(run,format='(I6.6)'),2)+'-'
k_print, filename=plotfilebase+'star-ug-gr.ps'
ndata= n_elements(mags[0,*])
IF ndata GT 100000 THEN BEGIN
    levels= errorf(0.5*(dindgen(4)+1))
ENDIF ELSE BEGIN
    levels= errorf(0.5*(dindgen(3)+1))
ENDELSE
IF n_elements(mags[0,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[0,*], mags[1,*], $
      ytitle=textoidl('g-r'),xtitle=textoidl('u-g'), psym=3, xrange=[-1,5],$
      yrange=[-.6,4], /outliers, outcolor=djs_icolor('black'), $
      title='run '+strtrim(string(run),2), /internal_weight, levels=levels, $
      charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[0,*], mags[1,*], psym=3, xtitle='u-g',ytitle='g-r', $
      xrange=[-1,5],yrange=[-.6,4], title='run '+strtrim(string(run),2)
ENDELSE
legend, [strtrim(string(n_elements(mags[0,*])),2)+' objects with p(star) > 0.95'], $
  box= 0., /right,/top, charsize=1.4
k_end_print


k_print, filename=plotfilebase+'star-gr-ri.ps'
ndata= n_elements(mags[1,*])
IF ndata GT 100000 THEN BEGIN
    levels= errorf(0.5*(dindgen(4)+1))
ENDIF ELSE BEGIN
    levels= errorf(0.5*(dindgen(3)+1))
ENDELSE
IF n_elements(mags[1,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[1,*], mags[2,*], $
      xtitle=textoidl('g-r'),ytitle=textoidl('r-i'), psym=3, xrange=[-.6,4],$
      yrange=[-.6,2.6], /outliers, outcolor=djs_icolor('black'), $
      /internal_weight, levels=levels, charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[1,*], mags[2,*], psym=3, ytitle='r-i',xtitle='g-r', $
      yrange=[-.6,2.6],xrange=[-.6,4]
ENDELSE
k_end_print

k_print, filename=plotfilebase+'star-ri-iz.ps'
ndata= n_elements(mags[2,*])
IF ndata GT 100000 THEN BEGIN
    levels= errorf(0.5*(dindgen(4)+1))
ENDIF ELSE BEGIN
    levels= errorf(0.5*(dindgen(3)+1))
ENDELSE
IF n_elements(mags[2,*]) GT _MAXSCATTER THEN BEGIN
    hogg_scatterplot, mags[2,*], mags[3,*], $
      ytitle=textoidl('i-z'),xtitle=textoidl('r-i'), psym=3, yrange=[-.5,2.5],$
      xrange=[-.6,2.6], /outliers, outcolor=djs_icolor('black'), $
      /internal_weight, levels=levels, charsize=charsize
ENDIF ELSE BEGIN
    djs_plot, mags[2,*], mags[3,*], psym=3, xtitle='r-i',ytitle='i-z', $
      xrange=[-.6,2.6],yrange=[-.5,2.5]
ENDELSE
k_end_print

END
