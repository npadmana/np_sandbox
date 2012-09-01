PRO write_ir_flagcuts, infile, ramin, ramax, decmin, decmax, keepmags=keepmags
;
; INPUTS: obj: a sweeps file to cut to just the minimal info
;             Richard Mcmahon needs to process to match to IR
;             (so that transferring and photometering in UKIDSS is fast)
;         ramin,ramax,decmin,decmax: ra and dec box to limit which to limit
; 
; OPTIONAL INPUTS: If keepmags is true, the output structure retains
;                  (unextincted) SDSS luptitudes
;
; OUTPUTS: no output but an output file with a name corresponding to
;         infile(-'.fits')+radeclimits+'-trim4ir.fits.gz' is written. This output file
;         passes just the BOSS flag cuts and is cut to ra, dec, run
;         rerun, camcol, thing_id and the passed radec box
;
; PROCEDURE CALL:
;   write_ir_flagcuts, infile, ramin, ramax, decmin, decmax, /keepmags
;
; COMMENTS:
;   as 0f v1.3 will automatically deal with wraparound if ramin > ramax
;
; REQUIREMENTS:
;   BOSS quasar TS code stack and its dependencies (sdssidl, idlutils)
;   main call is to ir_flagcuts.pro
;
; VERSION HISTORY:
;   1.0 Adam D. Myers, UIUC, Nov 17, 2010
;   1.1 Adam D. Myers, UIUC, Nov 18, 2010: 
;     don't write an output file if nothing passes flag cuts in ir_flagcuts.pro
;     pass dec = x to cut to declinations less than x 
;   1.2 Adam D. Myers, UIUC, Nov 20, 2010:
;     add two-sided dec limits and ra limits
;     cut to boss sgc and ngc areas
;   1.3 Adam D. Myers, UWyo, Apr 1, 2011: 
;     automatically deal with wraparound if ramin > ramax
;   1.4 Adam D. Myers, UWyo, May 10, 2011:
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

        ;ADM name the output file
        rastr = strcompress(ramin,/rem)+'to'+strcompress(ramax,/rem)
        decstr = strcompress(decmin,/rem)+'to'+strcompress(decmax,/rem)
        outfile = repstr(infile,'.fits.gz','-ra-'+rastr+'-dec-'+decstr+'-trim4ir.fits')
	
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
              if ramax gt ramin then begin
                 w2 = where(done.dec ge decmin and done.dec lt decmax and    $
                            done.ra gt ramin and done.ra lt ramax,cnt2)
              endif else begin
                 w2 = where(done.dec ge decmin and done.dec lt decmax and    $
                            (done.ra gt ramin or done.ra lt ramax),cnt2)
              endelse
              if cnt2 gt 0 then begin
                 done = done[w2]

                 ;ADM write output
                 mwrfits, done, outfile, /create
                 spawn, 'gzip -f '+outfile
              endif
              splog, strcompress(cnt2)+' pass all cuts (including final ra/dec cuts)'
              splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'           
           endif else begin
              splog, strcompress(0)+' pass all cuts (including final ra/dec cuts)'
              splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'           
           endelse 



        endif else begin
           
           splog, strcompress(0)+' pass all cuts (including final ra/dec cuts)'
           splog, 'time...'+strcompress(systime(1)-tm0,/rem)+'s'

        endelse

 
END
