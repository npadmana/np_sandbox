FUNCTION XDQSOZ_MATCH2ADM, in, binned=binned
IF keyword_set(binned) THEN BEGIN
    admfiles= ['$BOVYQSOEDDATA/pp_xd_ibpdf_all.fits.gz']
ENDIF ELSE BEGIN
    admdir='/mount/hydra4/jb2777/fromADM/IBkNNPDF/'
    admfiles= file_search(admdir+'*.fits.gz',/test_regular)
ENDELSE
adm= mrdfits(admfiles[0],1,/silent)
out= adm[0]
out.pqso= -1.
out= replicate(out,n_elements(in.ra))
for ii= 0L, n_elements(admfiles)-1 do begin
    print, format = '("Working on file ",i7," of ",i7,a1,$)', $
      ii+1,n_elements(admfiles),string(13B)
    adm= mrdfits(admfiles[ii],1,/silent)
    spherematch, in.ra, in.dec, adm.ra, adm.dec, 2./3600., $
      iindx, aindx
    if aindx[0] EQ -1 then continue
    out[iindx]= adm[aindx]
END
return, out
end
