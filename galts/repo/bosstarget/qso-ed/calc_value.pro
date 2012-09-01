FUNCTION CALC_VALUE, zem, gmag
;;read quasar value table
readcol, '$BOVYQSOEDDATA/quasarvalue.txt', z,g,v,format='F,F,F'
g= long(10*g)
z= long(20*z)
ndata= n_elements(gmag)
out= dblarr(ndata)
FOR ii=0L, ndata-1 DO BEGIN
    vg= long(round(gmag[ii]*10.))
    vz= long(round(zem[ii]*20.))
    line= where(g EQ vg and z eq vz,cnt)
    if cnt eq 0 then continue
    out[ii]= v[line]
ENDFOR
RETURN, out
END
