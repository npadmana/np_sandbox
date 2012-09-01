;+
; NAME:
;   likelihood_mergefiles
;
; PURPOSE:
;   Merge output files from LIKELIHOOD_STRIPE82_BATCH
;
; CALLING SEQUENCE:
;   likelihood_mergefiles, [ files , outfile= ]
;
; INPUTS:
;
; OPTIONAL INPUTS:
;   files  - Input file name(s); default to 'QSO-target*.fits'
;   outfile - Output file name; default to 'merge-'+files[0]
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
; COMMENTS:
;   Merge HDU #1 of all files, assuming these are FITS binary tables
;   with identical structures.
;
; EXAMPLES:
;
; PROCEDURES CALLED:
;
; INTERNAL SUPPORT ROUTINES:
;
; REVISION HISTORY:
;   01-Aug-2009  Written by D. Schlegel, J. Hennawi, J. Kirkpatrick,
;                V. Bhardwaj, LBL
;-
;------------------------------------------------------------------------------
pro likelihood_mergefiles, infiles1, outfile=outfile1

   if (keyword_set(infiles1)) then infiles=infiles1 $
    else infiles='QSO-target*.fits'
   fullname = findfile(infiles, count=nfile)
   if (nfile EQ 0) then begin
      splog, 'No files found'
      return
   endif
   if (keyword_set(outfile1)) then outfile=outfile1 $
    else outfile='merge-'+fullname[0]

   ; First count the number of elements
   ntot = 0L
   for ifile=0L, nfile-1L do begin
      hdr = headfits(fullname[ifile], exten=1)
      if (keyword_set(hdr)) then begin
         ntot += sxpar(hdr, 'NAXIS2')
      endif
   endfor
   if (ntot EQ 0) then begin
      splog, 'All data files empty'
      return
   endif

   ; Now concatenate all the data
   i0 = 0L
   for ifile=0L, nfile-1L do begin
      objs = mrdfits(fullname[ifile], 1, /silent)
      if (keyword_set(objs)) then begin
         if (NOT keyword_set(bigobj)) then begin
            blankobj = objs[0]
            struct_assign, {junk:0}, blankobj
            bigobj = replicate(blankobj, ntot)
         endif
         nthis = n_elements(objs)
print, fullname[ifile], nthis
         bigobj[i0:i0+nthis-1] = objs
         i0 += nthis
      endif
   endfor

   splog, 'Writing file ', outfile
   mwrfits, bigobj, outfile, /create

   return
end
;------------------------------------------------------------------------------
