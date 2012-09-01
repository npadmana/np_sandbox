;+
;   NAME:
;      xdcore_calculate_prob
;   PURPOSE:
;      calculate the extreme-deconvolution XDQSO QSO probability
;   INPUT:
;      in - structure containing PSFFLUX, PSFFLUX_IVAR, EXTINCTION
;   KEYWORDS:
;      dereddened - psfflux, and psfflux_ivar is already dereddened
;      galex - GALEX fluxes are included in psfflux, psfflux_ivar, and
;              extinction; use them
;   OUTPUT:
;      out - structure containing pqso, ... (see catalog description)
;   HISTORY:
;      2010-04-30 - Written - Bovy (NYU)
;      2010-05-29 - Added Galex - Bovy
;      2010-09-26 - Re-written to be stand-alone - Bovy
;-
FUNCTION sdss_deredden, flux, extinction
exponent = 0.4*extinction
flux_correct = (10.0^exponent)*flux
return, flux_correct
end
FUNCTION sdss_deredden_error, ivar2, extinction
exponent = -0.8*extinction
ivar2_correct = (10.0^exponent)*ivar2
return, ivar2_correct
end
FUNCTION DNDIPATH, zmin, zmax, lumfunc
;;check for environment variable
path= getenv('XDQSODATA')
if strcmp(path,'') then path= 'data/' else path = '$XDQSODATA/'
path+= 'dNdi_zmin_'+strtrim(string(zmin,format='(F4.2)'),2)+'_zmax_'+strtrim(string(zmax,format='(F4.2)'),2)+'_'+lumfunc+'.prt'
return, path
END
PRO READ_DNDI, filename, i, dndi, correct=correct, attenuate=attenuate, $
               everythingcorrect=everythingcorrect
_CORRECTMEAN= 21.9
_CORRECTWIDTH= 0.2
_ATTENUATECUT= 24.5D
_ATTENUATESLOPE= -0.5D
OPENR, lun, filename, /GET_LUN
;;Read the header (1 line)
hdr= ""
READF, lun, hdr
cmd= "wc -l "+filename
spawn, cmd, nlines
nlines= nlines[0]-1
i= dblarr(nlines)
dndi= dblarr(nlines)
FOR ii=0L, nlines-1 DO BEGIN
    READF, lun, itmp, dnditmp
    i[ii]= itmp
    IF keyword_set(correct) THEN dndi[ii]= dnditmp/(exp((itmp-_CORRECTMEAN)/_CORRECTWIDTH)+1D0) $
    ELSE dndi[ii]= dnditmp
    IF keyword_set(attenuate) AND i[ii] GE _ATTENUATECUT THEN dndi[ii]= dndi[ii]*exp(_ATTENUATESLOPE*(i[ii]-_ATTENUATECUT))
    IF keyword_set(everythingcorrect) AND i[ii] GT 20. THEN BEGIN
        eight= where(i EQ 19.)
        twenty= where(i EQ 20.)
        dndi[ii]= dndi[eight]+(dndi[eight]-dndi[twenty])/(i[eight]-i[twenty])*(i[ii]-i[eight])
        dndi[ii]= dndi[ii]/(exp((itmp-_CORRECTMEAN)/_CORRECTWIDTH)+1D0)
    ENDIF
ENDFOR
; ESS free logical file unit
free_lun, lun
END
FUNCTION EVAL_COLORPROB, flux, flux_ivar, qso=qso, lowz=lowz, midz=midz, $
                         galex=galex
;;check for environment variable
path= getenv('XDQSODATA')
if strcmp(path,'') then _SAVEDIR= 'data/' else _SAVEDIR = '$XDQSODATA/'
IF keyword_set(qso) AND keyword_set(lowz) THEN BEGIN
    savefilename= _SAVEDIR+'xdqso_relflux_fits_qsolowz.fits'
ENDIF ELSE IF keyword_set(qso) AND keyword_set(midz) THEN BEGIN
    savefilename= _SAVEDIR+'xdqso_relflux_fits_qsomidz.fits'
ENDIF ELSE IF keyword_set(qso) THEN BEGIN
    savefilename= _SAVEDIR+'xdqso_relflux_fits_qsohiz.fits'
ENDIF ELSE BEGIN
    savefilename= _SAVEDIR+'xdqso_relflux_fits_star.fits'
ENDELSE

b= 1.8;;Magnitude softening
_IMIN= 17.7
_IMAX= 22.5
_ISTEP= 0.1
_IWIDTH= 0.2
_NGAUSS= 20
nbins= (_IMAX-_IMIN)/_ISTEP

nfi= n_elements(flux[0,*])
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(flux[3,*],b)
out= dblarr(nfi)
;;Just loop through the solutions bin
FOR ii=0L, nbins-1 DO BEGIN
    indx= where(mi GE (_IMIN+(ii+0.5)*_ISTEP) AND $
                mi LT (_IMIN+(ii+1.5)*_ISTEP))
    IF indx[0] EQ -1 THEN CONTINUE ;;Nothing here
    ;;Prep the data
    if scalarOut THEN prep_data, flux, flux_ivar, mags=ydata,var_mags=ycovar, $
      /relfluxes ELSE $
      prep_data, flux[*,indx], flux_ivar[*,indx], mags=ydata,var_mags=ycovar, $
      /relfluxes
    ;;Load solution
    fits= mrdfits(savefilename,ii+1,/silent)
    out[indx]= exp(calc_loglike(ydata,ycovar,fits.xmean,fits.xcovar,fits.xamp))
ENDFOR
RETURN, out
END
FUNCTION EVAL_IPROB, fi, i, dndi
b= 1.8
nfi= n_elements(fi)
if nfi EQ 1 THEN scalarOut= 1B ELSE scalarOut= 0B
mi= sdss_flux2mags(fi,b)
out= INTERPOL(dndi,i,mi,/spline)
IF scalarOut THEN RETURN, out[0] ELSE RETURN, out
END
FUNCTION XDQSO_CALCULATE_PROB, in, galex=galex, dereddened=dereddened
ndata= n_elements(in.psfflux[0])
IF ~keyword_set(dereddened) THEN BEGIN
    flux= sdss_deredden(in.psfflux,in.extinction)
    flux_ivar=sdss_deredden_error(in.psfflux_ivar,in.extinction)
ENDIF

;;Read the differential number counts
path= getenv('XDQSODATA')
if strcmp(path,'') then dataDir= 'data/' else dataDir = '$XDQSODATA/'
lumfunc= 'HRH07'
dndi_qsobosszfile= dndipath(2.2,3.5,lumfunc)
dndi_qsofile= dndipath(3.5,6.,lumfunc)
dndi_qsolowzfile= dndipath(0.3,2.2,lumfunc)
dndi_everythingfile= dataDir+'dNdi_everything_coadd_1.4.prt'

read_dndi, dndi_qsobosszfile, i_qsobossz, dndi_qsobossz, /correct
read_dndi, dndi_qsofile, i_qso, dndi_qso, /correct
read_dndi, dndi_qsolowzfile, i_qsolowz, dndi_qsolowz, /correct
read_dndi, dndi_everythingfile, i_everything, dndi_everything

xdstruct= {qsolowzlike:0D, qsohizlike:0D, qsomidzlike: 0D, $
           starlike:0D, qsolowznumber:0D, qsohiznumber:0D,qsomidznumber:0D, $
           starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
           pqso: 0D}
out= replicate(xdstruct,ndata)

;;Now calculate all of the factors in turn
out.qsomidzlike= eval_colorprob(flux,flux_ivar,/qso,/midz,galex=galex)
out.qsomidznumber= eval_iprob(flux[3,*],i_qsobossz,dndi_qsobossz)
out.qsohizlike= eval_colorprob(flux,flux_ivar,/qso,galex=galex)
out.qsohiznumber= eval_iprob(flux[3,*],i_qso,dndi_qso)
out.qsolowzlike= eval_colorprob(flux,flux_ivar,/qso,/lowz,galex=galex)
out.qsolowznumber= eval_iprob(flux[3,*],i_qsolowz,dndi_qsolowz)
out.starlike= eval_colorprob(flux,flux_ivar,galex=galex)
out.starnumber= eval_iprob(flux[3,*],i_everything,dndi_everything)

;;Calculate the probabilities
pstar= out.starlike*out.starnumber
nonzero= where(pstar NE 0.)
IF nonzero[0] NE -1 THEN pstar[nonzero]= pstar[nonzero]/$
  (out[nonzero].qsolowzlike*out[nonzero].qsolowznumber+$
   out[nonzero].qsohizlike*out[nonzero].qsohiznumber+$
   out[nonzero].qsomidzlike*out[nonzero].qsomidznumber+$
   out[nonzero].starlike*out[nonzero].starnumber)
out.pstar= pstar
pqsolowz= out.qsolowzlike*out.qsolowznumber
nonzero= where(pqsolowz NE 0.)
IF nonzero[0] NE -1 THEN pqsolowz[nonzero]= pqsolowz[nonzero]/$
  (out[nonzero].qsolowzlike*out[nonzero].qsolowznumber+$
   out[nonzero].qsohizlike*out[nonzero].qsohiznumber+$
   out[nonzero].qsomidzlike*out[nonzero].qsomidznumber+$
   out[nonzero].starlike*out[nonzero].starnumber)
out.pqsolowz= pqsolowz
pqsohiz= out.qsohizlike*out.qsohiznumber
nonzero= where(pqsohiz NE 0.)
IF nonzero[0] NE -1 THEN pqsohiz[nonzero]= pqsohiz[nonzero]/$
  (out[nonzero].qsolowzlike*out[nonzero].qsolowznumber+$
   out[nonzero].qsohizlike*out[nonzero].qsohiznumber+$
   out[nonzero].qsomidzlike*out[nonzero].qsomidznumber+$
   out[nonzero].starlike*out[nonzero].starnumber)
out.pqsohiz= pqsohiz
pqsomidz= out.qsomidzlike*out.qsomidznumber
nonzero= where(pqsomidz NE 0.)
IF nonzero[0] NE -1 THEN pqsomidz[nonzero]= pqsomidz[nonzero]/$
  (out[nonzero].qsolowzlike*out[nonzero].qsolowznumber+$
   out[nonzero].qsohizlike*out[nonzero].qsohiznumber+$
   out[nonzero].qsomidzlike*out[nonzero].qsomidznumber+$
   out[nonzero].starlike*out[nonzero].starnumber)
out.pqsomidz= pqsomidz
out.pqso= out.pqsolowz+out.pqsomidz+out.pqsohiz
RETURN, out
END
