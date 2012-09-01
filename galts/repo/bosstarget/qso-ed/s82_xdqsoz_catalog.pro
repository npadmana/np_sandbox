;+
;   NAME:
;      s82_xdqsoz_catalog
;   PURPOSE:
;      Create the superset of the stripe-82 catalog
;   INPUT:
;      outname - filename for output; output is a fits file with
;                multiple tables
;                1: XDQSOz single-epoch
;                2: XDQSOz multi-epoch
;                3: XDQSOz single-epoch, galex, ukidss
;                4: XDQSOz multi-epoch, galex, ukidss
;   OUTPUT:
;       all output is written to a file
;   HISTORY:
;      2011-03-03 - Written - Bovy (NYU)
;-
FUNCTION S82_XDQSOZ_CATALOG_ONE, s82, galexdata, ukidssdata, galex=galex, $
                                 ukidss=ukidss, multi=multi, first=first
_MISSING= 1./1D5
IF keyword_set(galex) and keyword_set(ukidss) THEN BEGIN
    ndim= 11
ENDIF ELSE IF keyword_set(galex) THEN BEGIN
    ndim= 7
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    ndim= 9
ENDIF ELSE BEGIN
    ndim= 5
ENDELSE
IF keyword_set(first) THEN $
  xdstruct= {objId:'', run:0L, rerun:'', camcol:0L, field:0L, ID:0L, $
             RA:0D, DEC:0D, allqsolike:0D, $
             starlike:0D, allqsonumber:0D, $
             starnumber:0D, pstar:0D, pqsolowz:0D, pqsomidz:0D, pqsohiz:0D, $
             pqso: 0D, bitmask:0LL,good:0,$
             photometric:0, nobs:lonarr(5), $
             galexmatch:0, ukidssmatch:0, $
             psfflux:dblarr(ndim), psfflux_ivar:dblarr(ndim), $
             extinction:dblarr(ndim)} ELSE $
  xdstruct= {RA:0D, DEC:0D, allqsolike:0D, $
             starlike:0D, allqsonumber:0D, $
             starnumber:0D, pstar:0D, pqsolowz:0D, $
             pqsomidz:0D, pqsohiz:0D, $
             galexmatch:0, ukidssmatch:0, $
             bitmask:0LL,good:0, $
             photometric:0, nobs:lonarr(5), $
             pqso: 0D, psfflux:dblarr(ndim), psfflux_ivar:dblarr(ndim), $
             extinction:dblarr(ndim)}
IF keyword_set(multi) THEN BEGIN
    s82.psfflux= s82.psfflux_me
    s82.psfflux_ivar= s82.psfflux_me_ivar
ENDIF
;;Prep the ivars (zeros -> merely big)
prep_ivars, s82
;;add galex or ukidss
IF keyword_set(galex) and keyword_set(ukidss) THEN BEGIN
    comb= add_data(s82,galexdata=galexdata, ukidssdata=ukidssdata)
ENDIF ELSE IF keyword_set(galex) THEN BEGIN
    comb= add_data(s82,galexdata=galexdata)
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    comb= add_data(s82,ukidssdata=ukidssdata)
ENDIF ELSE BEGIN
    comb= s82
ENDELSE
;;flag cuts
tmp= s82
flags= exd_flagcuts(tmp)
sid= photoid(s82)
fid= photoid(flags)
match, sid, fid, sindx, findx, /sort
;;run through xdqsoz
exdout= qsoedz_calculate_prob(comb,0.3,5.5,/nocuts,galex=galex,ukidss=ukidss)
;;also calculate lowz, midz, and hiz
lowzlike= marginalize_colorzprob(0.000000000001,2.2,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=ukidss)
midzlike= marginalize_colorzprob(2.2,3.5,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=ukidss)
hizlike= marginalize_colorzprob(3.5,1000.5,sdss_deredden(comb.psfflux,comb.extinction),sdss_deredden_error(comb.psfflux_ivar,comb.extinction),galex=galex,ukidss=ukidss)
;;Create output
nout= n_elements(s82.ra)
thisout= replicate(xdstruct,nout)
IF keyword_set(first) THEN BEGIN
    thisout.run= s82.run
    thisout.rerun= s82.rerun
    thisout.camcol= s82.camcol
    thisout.field= s82.field
    thisout.id= s82.id
    objid= strarr(nout)
    FOR jj=0L, nout-1 DO objid[jj]= sdss_objid(s82[jj].run, $
                                               s82[jj].camcol, $
                                               s82[jj].field, $
                                               s82[jj].id, $
                                               rerun=s82[jj].rerun)
    thisout.objid= objid
ENDIF
thisout.ra= s82.ra
thisout.dec= s82.dec
thisout.allqsolike= exdout.allqsolike
thisout.starlike= exdout.everythinglike
thisout.allqsonumber= exdout.qsonumber
thisout.starnumber= exdout.everythingnumber
thisout.pqso= exdout.pqso
thisout.pstar= 1D0-thisout.pqso
thisout.pqsolowz= lowzlike/thisout.allqsolike*thisout.pqso
thisout.pqsomidz= midzlike/thisout.allqsolike*thisout.pqso
thisout.pqsohiz= hizlike/thisout.allqsolike*thisout.pqso
;;psfflux
thisout.psfflux= comb.psfflux
thisout.psfflux_ivar= comb.psfflux_ivar
thisout.extinction= comb.extinction
;;galex or ukidss match
if keyword_set(galex) and keyword_set(ukidss) THEN BEGIN
    indx= where(comb.psfflux_ivar[5] NE _MISSING AND $
                comb.psfflux_ivar[6] NE _MISSING,cnt)
    if cnt gt 0 then thisout[indx].galexmatch= 1
    indx= where(comb.psfflux_ivar[7] NE _MISSING AND $
                comb.psfflux_ivar[8] NE _MISSING AND $
                comb.psfflux_ivar[9] NE _MISSING AND $
                comb.psfflux_ivar[10] NE _MISSING,cnt)
    if cnt gt 0 then thisout[indx].ukidssmatch= 1
ENDIF ELSE IF keyword_set(galex) THEN BEGIN
    indx= where(comb.psfflux_ivar[5] NE _MISSING AND $
                comb.psfflux_ivar[6] NE _MISSING,cnt)
    if cnt gt 0 then thisout[indx].galexmatch= 1
ENDIF ELSE IF keyword_set(ukidss) THEN BEGIN
    indx= where(comb.psfflux_ivar[5] NE _MISSING AND $
                comb.psfflux_ivar[6] NE _MISSING AND $
                comb.psfflux_ivar[7] NE _MISSING AND $
                comb.psfflux_ivar[8] NE _MISSING,cnt)
    if cnt gt 0 then thisout[indx].ukidssmatch= 1
ENDIF
;;number of observations
IF keyword_set(multi) THEN $
  thisout.nobs= s82.PSFFLUX_ME_NUSE $
  ELSE $
  thisout.nobs= lonarr(5)+1
;;flag cuts tags
thisout.good= 2
thisout[sindx].bitmask= flags[findx].bitmask
thisout[sindx].good= flags[findx].good
thisout[sindx].photometric= flags[findx].photometric
;;return
return, thisout
END
PRO PREP_IVARS, sweep
_BIGVAR= 1D5
badivar= where(sweep.psfflux_ivar[0] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[0]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[1] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[1]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[2] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[2]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[3] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[3]= 1D0/_BIGVAR
badivar= where(sweep.psfflux_ivar[4] EQ 0.)
IF badivar[0] NE -1 THEN sweep[badivar].psfflux_ivar[4]= 1D0/_BIGVAR
END
PRO S82_XDQSOZ_CATALOG, outname
;;load data
s82= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts.fits',1)
galex= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts_sdss_galex.fits',1)
ukidss= mrdfits('$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits',1)
;;hack rowv etc to make the code run
ns82= n_elements(s82.ra)
newstruct= {rowv:dblarr(5), $
            colv:dblarr(5), $
            rowverr:dblarr(5), $
            colverr:dblarr(5)}
newstruct= replicate(newstruct,ns82)
newstruct.rowverr= 1
newstruct.colverr=1
s82= struct_combine(s82,newstruct)
;;run everything
print, "Working on single ..."
single= s82_xdqsoz_catalog_one(s82, galex, ukidss, /first)
mwrfits, single, outname, /create
print, "Working on multi ..."
multi= s82_xdqsoz_catalog_one(s82, galex, ukidss, /multi)
mwrfits, multi, outname
print, "Working on single+ ..."
singleplus= s82_xdqsoz_catalog_one(s82, galex, ukidss, /galex, /ukidss)
mwrfits, singleplus, outname
print, "Working on multi+ ..."
multiplus= s82_xdqsoz_catalog_one(s82, galex, ukidss, /galex, /multi, $
  /ukidss)
mwrfits, multiplus, outname
END
