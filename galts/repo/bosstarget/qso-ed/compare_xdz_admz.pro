;+
;   NAME:
;      compare_xdz_admz
;   PURPOSE:
;      compare photo-z PDFs from XDQSOz with those computed by Adam
;   INPUT:
;      indx - index in the XDQSO-0.1 catalog
;      plotfile - filename for plot (optional)
;   OUTPUT:
;      outputs plot
;   EXAMPLE: (2.50399 quasar)
;      compare_xdz_admz, 2008482
;   HISTORY:
;      2011-01-17 - Written - Bovy (NYU)
;-
PRO COMPARE_XDZ_ADMZ, indx, plotfile=plotfile, adm=adm, xdqso=xdqso
;;Load the data
IF ~keyword_set(adm) THEN $
  adm= mrdfits('$BOVYQSOEDDATA/pp_xd_ibpdf_all.fits.gz',1)
IF ~keyword_set(xdqso) THEN $
  xdqso= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/xdcore_targets.sweeps.fits',1)
;;Compute XDQSOz photo-z
xdqsoz_zpdf, sdss_deredden(xdqso[indx].psfflux,xdqso[indx].extinction),$
  sdss_deredden_error(xdqso[indx].psfflux_ivar,xdqso[indx].extinction), $
  zmean=zmean, zcovar=zcovar,zamp=zamp
nzs= 1001
zs= dindgen(nzs)/(nzs-1)*5.2+0.3
xdz= eval_xdqsoz_zpdf(zs,zmean,zcovar,zamp)
xdz/= total(xdz)*(zs[1]-zs[0])
;;ADM's photo-z
admzs= [0.25,dindgen(38)/10+0.55,4.9]
spherematch, xdqso[indx].ra,xdqso[indx].dec, adm.ra, adm.dec,2./3600.,$
  xindx,aindx
admz= adm[aindx].zpdf
admz/= (0.5*admz[0]+1.2*admz[39]+0.1*total(admz[1:38]))
;;Plot both
IF keyword_set(plotfile) THEN k_print, filename=plotfile
djs_plot, zs, xdz, xtitle='redshift', ytitle='p(redshift)', yrange=[0.,1.1*max([xdz,admz])], xrange=[0.,5.5]
djs_oplot, admzs,admz,psym=10, color='blue'
IF keyword_set(plotfile) THEN k_end_print
END
