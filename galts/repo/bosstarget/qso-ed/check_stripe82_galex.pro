PRO CHECK_STRIPE82_GALEX, galex=galex

;;select targets
IF keyword_set(galex) THEN BEGIN
    target= mrdfits('/global/data/scr/jb2777/bosstarget/pro/qso-ed/star82-varcat-bound-ts_exd_galex.fits',1)
    target2= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts.fits',1)
    target= struct_combine(target,target2)
    targets= where(target.pqso GT 0.86)
    target= target[targets]
ENDIF ELSE BEGIN
    target= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts.fits',1)
    sindx= reverse(sort(target.qsoed_prob))
    target= target[sindx[0:floor(220*17.8)-1]]
ENDELSE
print, n_elements(target.ra), n_elements(target.ra)/219.93

truth= mrdfits('$SCRATCH/tmp/spAll-v5_4_14.fits',1)
truth = truth[where(strmatch(truth.chunk,'*boss11*'))]
truth = truth[where(truth.specprimary)]
truth = truth[where(truth.thing_id ne -1)]

pid1 = sdss_photoid(target)
pid2 = sdss_photoid(truth)
match, pid1, pid2, m1, m2, /sort

total = struct_combine(target[m1], truth[m2])

print, n_elements(total.ra)/107.8
print, "z > 1 quasars:"
print, n_elements(where(total.z GE 1.))/107.8
print, n_elements(where(total.z GE 1.))/double(n_elements(total.ra))
print, " 2.2 < z < 3.5 quasars:"
print, n_elements(where(total.z GE 2.2 and total.z LE 3.5))/107.8
print, n_elements(where(total.z GE 2.2 and total.z LE 3.5))/double(n_elements(total.ra))
END
