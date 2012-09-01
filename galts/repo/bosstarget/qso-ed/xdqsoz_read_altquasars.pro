;+
;   NAME:
;      xdqsoz_read_altquasars
;   PURPOSE:
;      read the alternative quasar sample (2LSAQ+BOSS11)
;   INPUT:
;      (none)
;   KEYWORDS:
;      noboss - only read 2SLAQ
;      no2slaq - only read BOSS
;   OUTPUT:
;      struct with z, ra, dec, psfflux, psfflux_ivar, and extinction
;      for these quasars
;   HISTORY;
;      2011-01-21 - Written - Bovy (NYU)
;-
FUNCTION XDQSOZ_READ_ALTQUASARS, noboss=noboss, no2slaq=no2slaq
sdss= mrdfits('$BOVYQSOEDDATA/sdss_qsos.fits',1)
;;2SLAG
IF ~keyword_set(no2slaq) THEN BEGIN
    in= mrdfits('$BOSSTARGET_DIR/pro/qso-ed/knownquasarstar.sweeps.060910.fits',1)
    in= in[where(strmatch(in.source,'*2SLAQ*'))]
    spherematch, sdss.ra, sdss.dec, in.ra, in.dec, 2./3600., sindx, iindx
    if iindx[0] ne -1 then in[iindx].zem= 0.
    mi= sdss_flux2mags(sdss_deredden(in.psfflux[3],in.extinction[3]),1.8)
    in= in[where(in.zem GE 0.3 and in.zem LE 5.5 and mi GE 19.1)] ;;Gets rid of things we don't want
ENDIF
;;BOSS
IF ~keyword_set(noboss) THEN BEGIN
    boss= mrdfits('$BOVYQSOEDDATA/boss11qsos.fits',1)
    spherematch, sdss.ra, sdss.dec, boss.ra, boss.dec, 2./3600., sindx, bindx
    if bindx[0] ne -1 then boss[bindx].z= 0.
    mi= sdss_flux2mags(sdss_deredden(boss.psfflux[3],boss.extinction[3]),1.8)
    boss= boss[where(boss.z GE 0.3 and boss.z LE 5.5 and mi GE 19.1)]
ENDIF
IF ~keyword_set(noboss) and ~keyword_set(no2slaq) THEN BEGIN
;;combine
    spherematch, boss.ra, boss.dec, in.ra, in.dec, 2./3600., bindx, iindx
    if iindx[0] ne -1 then in[iindx].zem= 0.
    in= in[where(in.zem GE 0.3 and in.zem LE 5.5)] ;;Gets rid of things we don't want
ENDIF
;;output
out= {altqso,z:0D0, psfflux:dblarr(5), psfflux_ivar:dblarr(5), ra:0D0, dec:0D0,$
     extinction:dblarr(5),oname:''}
IF keyword_set(no2slaq) then n2slaq= 0 else n2slaq= n_elements(in.ra)
IF keyword_set(noboss) then nboss= 0 else nboss= n_elements(boss.ra)
out= replicate(out,n2slaq+nboss)
IF ~keyword_set(no2slaq) THEN BEGIN
    out[0:n2slaq-1].z= in.zem
    out[0:n2slaq-1].ra= in.ra
    out[0:n2slaq-1].dec= in.dec
    out[0:n2slaq-1].psfflux= in.psfflux
    out[0:n2slaq-1].psfflux_ivar= in.psfflux_ivar
    out[0:n2slaq-1].extinction= in.extinction
    out[0:n2slaq-1].oname= strtrim(in.source,2)+' '+strtrim(+in.name,2)
ENDIF
IF ~keyword_set(noboss) THEN BEGIN
    out[n2slaq:nboss+n2slaq-1].z= boss.z
    out[n2slaq:nboss+n2slaq-1].ra= boss.ra
    out[n2slaq:nboss+n2slaq-1].dec= boss.dec
    out[n2slaq:nboss+n2slaq-1].psfflux= boss.psfflux
    out[n2slaq:nboss+n2slaq-1].psfflux_ivar= boss.psfflux_ivar
    out[n2slaq:nboss+n2slaq-1].extinction= boss.extinction
    out[n2slaq:nboss+n2slaq-1].oname= hogg_iau_name(boss.ra,boss.dec)
ENDIF
return, out
END
