PRO write_ir_flagcuts_mangle, infile, mangpolyfile, keepmags=keepmags
;
; INPUTS: obj: a sweeps file to cut to just the minimal info
;             Richard Mcmahon needs to process to match to IR
;             (so that transferring and photometering in UKIDSS is fast)
;         magpolyfile: a .ply file (mangle not fits polygons) 
;             to restrict area to
;  
; OPTIONAL INPUTS: If keepmags is true, the output structure retains                          
;                  (unextincted) SDSS luptitudes     
;
; OUTPUTS: no output but an output file with a name corresponding to
;         'infile'(-'.fits.gz')+mangpolyfile+'-trim4ir.fits.gz' is written.
;         This contains objects that pass  just the BOSS flag cuts, is 
;         cut to just the tags ra, dec, run rerun, camcol, thing_id 
;         and is restricted to the mangle polygons in mangpolyfile
;
; PROCEDURE CALL:
;   write_ir_flagcuts_mangle, infile, mangpolyfile, /keepmags
;
; REQUIREMENTS:
;   BOSS quasar TS code stack and its dependencies (sdssidl, idlutils)
;   main call is to ir_flagcuts.pro
;
; VERSION HISTORY:
;   1.0 Adam D. Myers, UWyo, Feb 20, 2011 (from v1.2 of write_ir_flagcuts)
;   1.1 Adam D. Myers, UWyo, May 10, 2011:                                                    
;     add /keepmags to retain sweeps mag info (in unextincted luptitudes)
;;
        ;ADM timer
	tm0=systime(1)

        ;ADM read the mangle representations of the NGC and SGC
        geomdir=filepath(root=getenv("BOSSTARGET_DIR"), "data/geometry/")
        ngc = geomdir+'boss_survey_ngc_good.ply'
        sgc = geomdir+'boss_survey_sgc.ply'
        read_mangle_polygons, ngc, ngcpoly
        read_mangle_polygons, sgc, sgcpoly

        print, mangpolyfile

        ;ADM read the passed mangle
        read_mangle_polygons, mangpolyfile, poly

        ;ADM name the output file
        outmang = repstr(mangpolyfile,'.ply','-trim4ir')
        outmang = repstr(outmang,'geometry/','')
        outfile = repstr(infile,'.fits.gz',outmang+'.fits')
	
        ;ADM read input structure
        objs = mrdfits(infile,1)

        ;ADM trim to only objects we need to pass to RM for UKIDSS match
        trim = ir_flagcuts(objs, /cut)

        ;ADM only write out the smaller file if a structure is returned
        ;ADM otherwise just skip this sweep 
        if size(trim, /type) eq 8 then begin

           ;ADM final structure only needs to contain subset of tags
           done = extract_tags(trim, ['ra','dec','run','rerun','camcol','field','id','thing_id'])

           if keyword_set(keepmags)then begin

              magstruc = replicate(                                               $
                         create_struct('u',0.0,'g',0.0,'r',0.0,'i',0.0,'z',0.0)   $
                         ,n_elements(done)                                        $
                                  )
              
              bu=obj_new('bosstarget_util')
              lups = bu->get_lups(trim)
              magstruc.u = reform(lups[0,*])
              magstruc.g = reform(lups[1,*])
              magstruc.r = reform(lups[2,*])
              magstruc.i = reform(lups[3,*])
              magstruc.z = reform(lups[4,*])
              done = struct_combine(done,magstruc)
           endif


           ;ADM cut to survey footprint
           resngc = is_in_window(ra=done.ra, dec=done.dec, ngcpoly)
           ressgc = is_in_window(ra=done.ra, dec=done.dec, sgcpoly)
           w = where(resngc+ressgc,cnt)
           splog, strcompress(cnt,/rem)+' /'+strcompress(n_elements(done))+' in survey area'
           if cnt gt 0 then begin
              done = done[w]
              resw = is_in_window(ra=done.ra, dec=done.dec, poly)
              w2 = where(resw,cnt2)
              if cnt2 gt 0 then begin
                 done = done[w2]

                 ;ADM write output
                 mwrfits, done, outfile, /create
                 spawn, 'gzip -f '+outfile
              endif
              splog, strcompress(cnt2)+' pass all cuts (including passed mangle)'
              splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'           
           endif else begin
              splog, strcompress(0)+' pass all cuts (including passed mangle)'
              splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'           
           endelse 


        endif else begin
           
           splog, strcompress(0)+' pass all cuts (including passed mangle)'
           splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'

        endelse

 
END
