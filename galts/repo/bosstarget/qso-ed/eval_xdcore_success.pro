PRO EVAL_XDCORE_SUCCESS, like=like
;;read data and process
columns= [2,13,17,35,37,56,225]
truth= hogg_mrdfits('$BOSS_SPECTRO_REDUX/spAll-$RUN1D.fits',1,columns=columns,/silent)
;truth= mrdfits('$HOME/scr/spAll-v5_4_35.fits',1)
truth = truth[where(truth.specprimary)]
truth = truth[where(truth.thing_id ne -1)]
;;Find chunks
chunk= strmid(truth.chunk,4)
chunks= chunk[uniq(chunk,sort(chunk))]
chunks= chunks[where(chunks GT 11)]
;;For each chunk, calculate success
print, "CHUNK, NTARGETS, NQSO, NQSO z >= 2.2, NQSO z>=2.2/NTARGETS, NQSOCORE, NQSOCORE/NTARGETS"
ntargets_total= 0
nqso_total= 0
nqsomidz_total= 0
nqsohiz_total= 0
for ii=0L, n_elements(chunks)-1 do begin
    if keyword_set(like) then begin
        targets= where(chunk EQ chunks[ii] and (truth.boss_target1 and 2LL^43) NE 0)
    endif else begin
        if chunks[ii] LT 14 then targets= where(chunk EQ chunks[ii] and (truth.boss_target1 and 2LL^42) NE 0) else targets= where((truth.boss_target1 and 2LL^40) NE 0 and chunk EQ chunks[ii])
    endelse
    ;;Calculate successes
    if targets[0] EQ -1 then continue else ntargets= n_elements(targets)
    indx= where(strmatch(truth[targets].class,'QSO*') and truth[targets].zwarning EQ 0,nqso)
    nqsomidz= n_elements(where(strmatch(truth[targets].class,'QSO*') and truth[targets].zwarning EQ 0 and truth[targets].z GE 2.2 and truth[targets].z LE 3.5))
    nqsohiz= n_elements(where(strmatch(truth[targets].class,'QSO*') and truth[targets].zwarning EQ 0 and truth[targets].z GE 2.2))
    print, format = '(i3,i7,i7,i7,f5.2,i7,f5.2)', chunks[ii], ntargets, nqso, nqsohiz, nqsohiz/double(ntargets), $
      nqsomidz, nqsomidz/double(ntargets)
    ntargets_total+= ntargets
    nqso_total+= nqso
    nqsomidz_total+= nqsomidz
    nqsohiz_total+= nqsohiz
endfor
print, format = '("TOT",i7,i7,i7,f5.2,i7,f5.2)', ntargets_total, nqso_total, nqsohiz_total, $
  nqsohiz_total/double(ntargets_total), nqsomidz_total, $
  nqsomidz_total/double(ntargets_total)
END
