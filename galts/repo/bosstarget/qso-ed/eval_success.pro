PRO EVAL_SUCCESS, file
;;read data and process
columns= [2,13,17,35,37,56,225]
truth= hogg_mrdfits('$BOSS_SPECTRO_REDUX/spAll-$RUN1D.fits',1,columns=columns,/silent)
truth = truth[where(truth.thing_id ne -1)]
truth = truth[where(truth.specprimary)]
truth= truth[where(strmatch(truth.class,'QSO*'))]
truth= truth[where(truth.zwarning EQ 0)]
;;back out XDCORE sample
chunk= strmid(truth.chunk,4)
targets= where(((truth.boss_target1 AND 2LL^42) NE 0 AND chunk LT 14) OR $
              ((truth.boss_target1 AND 2LL^40) NE 0 AND chunk GE 14));XD=CORE

;;Calculate successes
nqso= n_elements(targets)
nqsomidz= n_elements(where(truth[targets].z GE 2.2))

;;Call sed
spawn, "sed 's/TEMPLATE_NQSOMIDZ/"+strtrim(string(nqsomidz),2)+$
  "/g' "+file+" > tmp"
spawn, "mv tmp "+file
spawn, "sed 's/TEMPLATE_NQSO/"+strtrim(string(nqso),2)+"/g' "+file+" > tmp"
spawn, "mv tmp "+file
END
