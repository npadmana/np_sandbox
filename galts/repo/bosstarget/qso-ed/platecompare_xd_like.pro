PRO PLATECOMPARE_XD_LIKE, plate, mjd=mjd

;;Read plate targeting info
platestr= strtrim(string(plate,'(I4)'),2)
if keyword_set(mjd) then mjdstr= strtrim(string(mjd,'(I5)'),2) else mjdstr='?????'
target= mrdfits('$BOSS_SPECTRO_REDUX/v5_4_14/'+platestr+'/spPlate-'+platestr+'-'+mjdstr+'.fits',5)
;;read data
data= mrdfits('$BOSS_SPECTRO_REDUX/v5_4_14/'+platestr+'/v5_4_14/spZbest-'+platestr+'-'+mjdstr+'.fits',1)
;;compare
ed= where((target.boss_target1 and 2LL^42) NE 0)
like= where((target.boss_target1 and 2LL^43) NE 0)
edlike= where((target.boss_target1 and 2LL^43) NE 0 or (target.boss_target1 and 2LL^42) ne 0)
edsuccess= n_elements(where(data[ed].z GE 2.2 and data[ed].z LE 3.5 $
                            AND strmatch(data[ed].class,'QSO*') $
                            AND data[ed].zwarning EQ 0))
likesuccess= n_elements(where(data[like].z GE 2.2 and data[like].z LE 3.5 $
                            AND strmatch(data[like].class,'QSO*') $
                            AND data[like].zwarning EQ 0))
print, "XD: "+strtrim(string(edsuccess),2)+"/"+strtrim(string(n_elements(ed)),2)
print, "Like: "+strtrim(string(likesuccess),2)+"/"+strtrim(string(n_elements(like)),2)
;;overlap?
match, ed, like, subed, sublike
edlikesuccess= n_elements(where(data[ed[subed]].z GE 2.2 and data[ed[subed]].z LE 3.5 and data[like[sublike]].z GE 2.2 and data[like[sublike]].z LE 3.5 and data[ed[subed]].zwarning EQ 0))
print, "Overlap: "+strtrim(string(edlikesuccess),2)+"/"+strtrim(string(n_elements(edlike)),2)
END
