FUNCTION ExD_flagcuts, objs, dr9=dr9
;
; INPUTS: objs: a star datasweep
;
; OPTIONAL INPUTS: send /dr9 to use a dr9-style sweep
;
; OUTPUTS: same structure but
;   cut to 17.75 <= imag (dereddened luptitudes) < 22.45
;   has a new tag "bitmask" that records BOSS flags for later cuts
;   and a new tag "good" that is
;      0 for always good
;      = 2^0 for fails moved, deblend_problems or interp_problems flag cuts
;      = 2^1 for fails BOSS flag cuts		
;      Note that 2^0 has also implicitlf failed the BOSS flag cuts so anything
;      with good > 0 is a BOSS failure, good=1 is our subset of these
;   and new tags primary and photometric to indicate the resolve and
;      calib status
;
; REQUIREMENTS:
;   BOSS quasar TS code stack and its dependencies (sdssidl, idlutils)
;
; VERSION HISTORY:
;   1.0 Adam D. Myers, UIUC, July 28, 2010
;   1.1 Jo Bovy, NYU, July 28, 2010 - deredden/mag limits/IO
;   1.2 ADM, UIUC, Sep 7, 2010 - checks default_pars for nocalib to determine
;	  			         whether to cut on photometric
;                                no cut on primary (but retain primary info)
;                                include primary, photometric in
;                                        BOSS/ExD output flags
;   1.3 Bovy, NYU, Sep 7, 2010 - don't cut on photometric ever
;   1.4 ADM, UWyo, Jun 8, 2012 - added dr9 flag. This was needed as
;                                the rowv tags in the dr9 sweeps have
;                                been renamed rowvdeg and rescaled accordingly
;                                      
;;
        ;timer
	tm0=systime(1)

	;initialize the BOSS quasar target class that has my flag logic code in it
        ;ADM make sure to use the dr9 style of sweep if /dr9 is passed
        if not keyword_set(dr9) then $
           dr9 = 0
        bq = obj_new('bosstarget_qso', pars={dr9:dr9})
        
        ;initialize the BOSS utility class. Contains luptitude conversion.
	bu=obj_new('bosstarget_util')
	
        ;get the default pars so we know whether photometric is being cut
	pars = bq->pars()

	;impose i limits
	lups = bu->get_lups(objs,/deredden)
	ilups = lups[3,*]
	w = where(ilups ge 17.75 and ilups lt 22.45,cnt)
	splog, 'ilimits    pass' + strcompress(cnt)+' /'+strcompress(n_elements(ilups))
	if cnt gt 0 then begin
           objs = objs[w] 
        endif else return, {run:-1L}

        ;now create the output structure
        done = replicate({bitmask:0LL,good:0,primary:0,photometric:0},n_elements(objs))
        done = struct_combine(objs,done)

        ;limit to things that are photometric
        calib_bitmask = bq->calib_logic(objs)
        
        ;ADM don't specifically cut on
        ;photometric unless that's the default for BOSS TS
        w = where(calib_bitmask eq 0,cnt)
        if cnt gt 0 then begin
           done[w].photometric = 1
        endif
	
	;limit to things that are survey primary
	resolve_bitmask = bq->resolve_logic(objs)
        
        ;ADM don't specifically cut on primary but record it
        w = where(resolve_bitmask eq 0,cnt)
        if cnt gt 0 then begin
           done[w].primary = 1 
        endif

	;BOSS flags
	flag_bitmask = bq->flag_logic(objs)
	;BOSS magnitude range
        gmag_bitmask = bq->gmag_logic(objs)

	;populate our bitmask flag with the bitmask information
	all_bitmask = flag_bitmask + gmag_bitmask + resolve_bitmask
	if not pars.nocalib then all_bitmask += calib_bitmask

	done.bitmask = all_bitmask

	;where all_bitmask is set, this is an object
	;that wouldn't make the BOSS flag cuts
	;set our good flag to 2L^1 for these objects
	w = where(all_bitmask ne 0,cnt)
	if cnt gt 0 then done[w].good = 2L^1
	splog, 'BOSS flags    reject' + strcompress(cnt)+' /'+strcompress(n_elements(done))

	;where moved, interp_problems or deblend_problems
	;are set, this is an object that doesn't make our
	;less restrictive flag cuts
	;set our good flag to 2L^0 for these objects
	ip_bitmask = (flag_bitmask and bq->badflag('interp_problems'))
	dp_bitmask = (flag_bitmask and bq->badflag('deblend_problems'))
	mov_bitmask = (flag_bitmask and bq->badflag('moved'))
        ;also cut to primary (and photometric if applicable to BOSS)
	exd_bitmask = ip_bitmask + dp_bitmask + mov_bitmask + resolve_bitmask
	if not pars.nocalib then exd_bitmask += calib_bitmask

	w = where(exd_bitmask ne 0,cnt)
	if cnt gt 0 then done[w].good = 2L^0
	splog, 'ExD flags    reject' + strcompress(cnt)+' /'+strcompress(n_elements(done))

	splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'

        RETURN, done
END
