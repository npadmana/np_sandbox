FUNCTION ir_flagcuts, objs, cut=cut
;
; INPUTS: obj: a calibobj datasweep
;         /cut: if sent then the returned structure has
;               objects that fail flag cuts thrown out. Otherwise
;               the input structure is populated with "bitmask"
;               that contains the flag bits
;               IF NOTHING PASSES /cut 0 is returned
;
; OUTPUTS: same structure but with an extra tag bitmask that
; contains the boss flag cuts.
;
; COMMENTS FROM ADM FOR RICHARD MCMAHON: If you choose not to send /cut
; then anything with bitmask eq 0 should get apertures sunk in UKIDSS
;
; PROCEDURE CALL: 
;   objs = mrdfits('calibObj-008162-6-star.fits.gz',1)
;   done = ir_flagcuts(a, /cut)
;     (/cut is optional)
;
; REQUIREMENTS:
;   BOSS quasar TS code stack and its dependencies (sdssidl, idlutils)
;
; VERSION HISTORY:
;   1.0 Adam D. Myers, UIUC, Sept 24, 2010
;   1.1 Adam D. Myers, UIUC, Nov 18, 2010: Return 0 instead of a structure
;                                          if nothing passes flag cuts
;;
        ;ADM timer
	tm0=systime(1)

	;ADM initialize the BOSS quasar target class that has my flag logic code
	bq = obj_new('bosstarget_qso')
	;ADM< initialize the BOSS utility class. Contains luptitude conversion
	bu=obj_new('bosstarget_util')
	
        ;ADM get the default pars so we know whether photometric is being cut
	pars = bq->pars()

        ;ADM limit to things that are photometric
        calib_bitmask = bq->calib_logic(objs)
        
	;ADM limit to things that are survey primary
	resolve_bitmask = bq->resolve_logic(objs)
        
	;ADM BOSS flag info
	flag_bitmask = bq->flag_logic(objs)
	;ADM BOSS magnitude range info
        gmag_bitmask = bq->gmag_logic(objs)

	;ADM populate our bitmask flag with the bitmask information
	all_bitmask = flag_bitmask + gmag_bitmask
        if not pars.ignore_resolve then begin
           all_bitmask += resolve_bitmask
        endif
        if not pars.nocalib then begin
           splog,'Cutting to photometric'
           all_bitmask += calib_bitmask
        endif else begin
           splog,'NOT cutting to photometric'
        endelse
        
        if keyword_set(cut) then begin
           splog, 'Discarding objects that fail flag cuts...'
           w = where(all_bitmask eq 0,cnt)
           if cnt gt 0 then begin
              done = objs[w]
           endif else begin
              RETURN, 0
           endelse
        endif else begin
           ;ADM create the output structure with flag info
           splog, 'Keeping objects that fail flag cuts but populating bitmask...'
           done = replicate({bitmask:0LL},n_elements(objs))
           done = struct_combine(objs,done)
           done.bitmask = all_bitmask
        endelse

	splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'

        RETURN, done
END
