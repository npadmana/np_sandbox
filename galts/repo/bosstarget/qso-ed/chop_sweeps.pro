;+
;   NAME:
;      chop_sweeps
;   PURPOSE:
;      chop up the sweeps for training XDQSO
;   INPUT:
;      min - min i (default: 12.9)
;      max - max i (default: 22.5)
;      width - width of each bin (default: 0.2)
;      spacing - spacing of bins (default: 0.1)
;      start - start at this bin
;      stop - end at this bin
;   OUTPUT:
;   HISTORY:
;      2010-11-22 - Written - Bovy (NYU)
;-
PRO CHOP_SWEEPS, min=min, max=max,width=width,spacing=spacing, $
                 start=start, stop=stop
IF ~keyword_set(min) THEN min= 12.9
IF ~keyword_set(max) THEN max= 22.5
IF ~keyword_set(width) THEN width= 0.2
IF ~keyword_set(spacing) THEN spacing= 0.1
IF ~keyword_set(start) THEN start= 0
nbin= floor((max-min)/spacing-1)
IF ~keyword_set(stop) THEN stop= nbin
outdir= '/mount/hydra4/jb2777/sdss/choppedsweeps/301/'

; softening parameters from EDR paper in units of 1.0e-10
; (Stoughton et al. 2002)
b_u = 1.4
b_g = 0.9
b_r = 1.2
b_i = 1.8
b_z = 7.4
bs= [b_u,b_g,b_r,b_i,b_z]

;;For each bin, go through the sweeps, and collect the objects
;;Read runs
runs= mrdfits('dr8runs.fits',1)
runs= runs.run
nruns= n_elements(runs)
outstruct= {RA:0D,Dec:0D,psfflux:dblarr(5),psfflux_ivar:dblarr(5),extinction:dblarr(5)}
FOR ii=start, stop-1 DO BEGIN
    print, "Working on bin "+strtrim(string(ii),2)
    outname= outdir+get_choppedsweeps_name(ii,min=min,max=max,width=width,$
                                           spacing=spacing)
    IF file_test(outname) THEN BEGIN
        print, "File "+outname+" exists ..."
        print, "Continuing ..."
        CONTINUE
    ENDIF
    thisOut= replicate(outStruct,1)
    FOR jj=0L, nruns-1 DO BEGIN
        print, format = '("RUN ",i7," of ",i7,a1,$)' $
          , jj+1, nruns, string(13b)
        calibobj= READ_CALIBOBJ(runs[jj], type='star',/silent)
        indx= ed_qso_trim(calibobj)
        if indx[0] EQ -1 then continue
        calibobj= calibobj[indx]
        ;;Cut to right magnitudes
        flux= sdss_deredden(calibobj.psfflux,calibobj.extinction)
        FOR kk=0L, 4 DO flux[kk,*]= sdss_flux2mags(flux[kk,*],bs[kk])
        indx= where(flux[3,*] GE (min+ii*spacing) AND $
                    flux[3,*] LT (min+ii*spacing+width),nindx)
        IF nindx EQ 0 THEN CONTINUE
        calibobj= calibobj[indx]
        addOut= replicate(outStruct,n_elements(calibobj.ra))
        addOut.ra= calibobj.ra
        addOut.dec= calibobj.dec
        addOut.psfflux= calibobj.psfflux
        addOut.psfflux_ivar= calibobj.psfflux_ivar
        addOut.extinction= calibobj.extinction
        thisOut= [thisOut,addOut]
    ENDFOR
    ;;save
    mwrfits, thisOut[1:n_elements(thisOut.ra)-1], outname, /create
ENDFOR

END
