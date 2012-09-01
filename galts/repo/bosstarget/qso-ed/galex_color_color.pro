;+
;   NAME:
;      galex_color_color
;   PURPOSE:
;      make color-color plots of the Galex data
;   INPUT:
;      galexfilename - file that holds the galex data
;      coadddatafilename - filename of coadded data
;      imin - minimum i-band magnitude
;      imax - maximum i-band magnitude
;      basefilename - filename for figure
;      minsnr -
;      zmin - minimum redshift (if used with qso)
;      zmax - maximum redshift (if used with qso)
;   KEYWORDS:
;      hoggscatter - if set, hogg-scatterplot
;      star - if set, isolate stars
;   OUTPUT:
;      figures in basefilename+'...'
;   HISTORY:
;      2010-05-27 - Written - Bovy (NYU)
;-
PRO GALEX_COLOR_COLOR, galexfilename=galexfilename, imin=imin, imax=imax, $
                       basefilename=basefilename, $
                       coadddatafilename=coadddatafilename, $
                       hoggscatter=hoggscatter, minsnr=minsnr, $
                       zmin=zmin, zmax=zmax, star=star
IF ~keyword_set(galexfilename) THEN everything= 1B ELSE everything=0B
IF keyword_set(star) THEN everythinglegend='STAR' ELSE everythinglegend='everything'
IF ~keyword_set(galexfilename) THEN galexfilename= '$BOVYQSOEDDATA/Bovy_Likeli_everything_sdss_galex.fits'
IF ~keyword_set(coadddatafilename) THEN coadddatafilename= '$BOVYQSOEDDATA/coaddedMatch.fits'

data= mrdfits(galexfilename,1)
data= data[where(data.nuv_fluxerr NE 0. AND data.fuv_fluxerr NE 0. and data.nuv_flux GE 0. and data.fuv_flux GE 0.)]
IF keyword_set(minsnr) THEN data= data[where(data.nuv_flux/data.nuv_fluxerr GE minsnr AND data.fuv_flux/data.fuv_fluxerr GE minsnr)]

coadd= mrdfits(coadddatafilename,1)
IF keyword_set(star) THEN BEGIN
    coadd= coadd[where(coadd.FLUX_CLIP_RCHI2 LT 1.4)]
ENDIF
spherematch, coadd.ra, coadd.dec, data.ra, data.dec, 1./3600., match1,match2
data= data[match2]
IF tag_exist(coadd,'extinction') THEN BEGIN
    flux= sdss_deredden(coadd[match1].psfflux,coadd[match1].extinction)
ENDIF ELSE BEGIN
    flux= coadd[match1].psfflux
ENDELSE
b_u = 1.4
b_g = 0.9
b_r = 1.2
b_i = 1.8
b_z = 7.4
bs= [b_u,b_g,b_r,b_i,b_z]
ndata= n_elements(data.ra)
IF tag_exist(coadd,'extinction') THEN BEGIN
    uvextinction= dblarr(2,ndata)
    uvextinction[0,*]= coadd[match1].extinction[0]/5.155D0*8.18D
    uvextinction[1,*]= coadd[match1].extinction[0]/5.155D0*8.29D
    nuvflux= sdss_deredden(data.nuv_flux,uvextinction[0,*])*1D-9
    fuvflux= sdss_deredden(data.fuv_flux,uvextinction[1,*])*1D-9
ENDIF ELSE BEGIN
    nuvflux= data.nuv_flux*1D-9
    fuvflux= data.fuv_flux*1D-9
ENDELSE
mags= dblarr(7,ndata)
FOR ii=0L, 4 DO mags[ii,*]= sdss_flux2mags(flux[ii,*],bs[ii])
mags[5,*]= flux2mags(nuvflux)
mags[6,*]= flux2mags(fuvflux)

IF keyword_set(zmin) THEN mags= mags[*,where(coadd[match1].z GE zmin)]
IF keyword_set(zmax) THEN mags= mags[*,where(coadd[match1].z LE zmax)]
IF keyword_set(imin) THEN BEGIN
    IF ~keyword_set(imax) THEN BEGIN
        print, "If imin is set, imax needs to be set as well ..."
        print, "Returning ..."
        return
    ENDIF
    indx= where(mags[3,*] GE imin and mags[3,*] LE imax)
    mags= mags[*,indx]
ENDIF

legendcharsize= 1.5
IF keyword_set(basefilename) THEN k_print, filename=basefilename+'_nu_fn.ps'
IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[6,*]-mags[5,*], $
  mags[5,*]-mags[0,*], /outliers, outcolor=djs_icolor('black'),$
  ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10] ELSE $
  djs_plot, mags[6,*]-mags[5,*], mags[5,*]-mags[0,*], $
  ytitle='NUV-u',xtitle='FUV-NUV', psym=3, yrange=[-3,7],xrange=[-7.5,10]
IF keyword_set(imin) THEN BEGIN
    legend, [strtrim(string(imin,format='(F4.1)'),2)+" !9l!X i !9l!X "+strtrim(string(imax,format='(F4.1)'),2)], box=0., /bottom, charsize=legendcharsize
ENDIF
IF keyword_set(zmin) THEN legend, ['z !9b!X '+strtrim(string(zmin,format='(F4.1)'),2)], box=0.,charsize=legendcharsize, /bottom,/right
IF keyword_set(zmax) THEN legend, ['z !9l!X '+strtrim(string(zmax,format='(F4.1)'),2)], box=0.,charsize=legendcharsize, /bottom,/right
IF keyword_set(zmin) OR keyword_set(zmax) THEN legend, ['QSO'],box=0.,charsize=legendcharsize,pos=[0.45,0.9],/norm
IF everything THEN legend, [everythinglegend],box=0.,charsize=legendcharsize,pos=[0.4,0.9],/norm
IF keyword_set(basefilename) THEN k_end_print ELSE stop
IF keyword_set(basefilename) THEN k_print, filename=basefilename+'_ug_nu.ps'
IF keyword_set(hoggscatter) THEN hogg_scatterplot, mags[5,*]-mags[0,*], $
  mags[0,*]-mags[1,*], /outliers, outcolor=djs_icolor('black'),$
  xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7] ELSE $
  djs_plot, mags[5,*]-mags[0,*], mags[0,*]-mags[1,*], $
  xtitle='NUV-u',ytitle='u-g', psym=3, yrange=[-1,5],xrange=[-3,7]
IF keyword_set(imin) THEN BEGIN
    legend, [strtrim(string(imin,format='(F4.1)'),2)+" !9l!X i !9l!X "+strtrim(string(imax,format='(F4.1)'),2)], box=0., /top,/right, charsize=legendcharsize
ENDIF
IF keyword_set(zmin) THEN legend, ['z !9b!X '+strtrim(string(zmin,format='(F4.1)'),2)], box=0.,charsize=legendcharsize, /bottom,/right
IF keyword_set(zmax) THEN legend, ['z !9l!X '+strtrim(string(zmax,format='(F4.1)'),2)], box=0.,charsize=legendcharsize, /bottom,/right
IF keyword_set(zmin) OR keyword_set(zmax) THEN legend, ['QSO'],box=0.,charsize=legendcharsize,pos=[0.45,0.9],/norm
IF everything THEN legend, [everythinglegend],box=0.,charsize=legendcharsize,pos=[0.4,0.9],/norm
IF keyword_set(basefilename) THEN k_end_print       


END

