;+
;   NAME:
;      check_may11_targets
;   PURPOSE:
;      perform known and chunk17 checks on the May 2011 target run
;   INPUT:
;   OUTPUT:
;   HISTORY:
;      2011-05-13 - Written - Bovy (NYU)
;-
PRO CHECK_MAY11_TARGETS
;;data
in= mrdfits('$BOVYQSOEDDATA/bosstarget-qso-2011-05-03-collate.fits',2)
in.psfflux= in.psfflux_me
in.psfflux_ivar= in.psfflux_me_ivar
spall= mrdfits('$BOSS_SPECTRO_REDUX/spAll-$RUN1D.fits',1)
ukidssdata= read_aux(/ukidss)
galexdata= read_aux(/galex)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  KNOWN
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;known box
known= in[where(in.ra GE 150. and in.ra LE 230. and in.dec GE 6.5 and in.dec LE 8.)]
area= 120.
dens= [10.,20.,40.,55.]
nthresh= n_elements(dens)
;;calculate all probabilities
pipe_bonus= known.qsoed_prob_bonus
pipe_multi= known.qsoed_prob_bonus_multi
my_bonus= (qsoed_calculate_prob(known,/zfour,/multi)).pqso
my_galex= (qsoed_calculate_prob(add_data(known,galexdata=galexdata),/galex,/zfour,/multi)).pqso
my_ukidss= (qsoed_calculate_prob(add_data(known,ukidssdata=ukidssdata),/ukidss,/zfour,/multi)).pqso
my_multi= (qsoed_calculate_prob(add_data(known,galexdata=galexdata,ukidssdata=ukidssdata),/ukidss,/galex,/zfour,/multi)).pqso
;;find thresholds
pipe_bonus_threshold= pipe_bonus[(reverse(sort(pipe_bonus)))[floor(dens*area)]]
pipe_multi_threshold= pipe_multi[(reverse(sort(pipe_multi)))[floor(dens*area)]]
my_bonus_threshold= my_bonus[(reverse(sort(my_bonus)))[floor(dens*area)]]
my_galex_threshold= my_galex[(reverse(sort(my_galex)))[floor(dens*area)]]
my_ukidss_threshold= my_ukidss[(reverse(sort(my_ukidss)))[floor(dens*area)]]
my_multi_threshold= my_multi[(reverse(sort(my_multi)))[floor(dens*area)]]
;;find # quasars
nqso_pipe_bonus= lonarr(nthresh)
nqso_pipe_multi= lonarr(nthresh)
nqso_my_bonus= lonarr(nthresh)
nqso_my_galex= lonarr(nthresh)
nqso_my_ukidss= lonarr(nthresh)
nqso_my_multi= lonarr(nthresh)
FOR ii=0L, nthresh-1 DO BEGIN
    nqso_pipe_bonus[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and pipe_bonus GE pipe_bonus_threshold[ii]))
    nqso_pipe_multi[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and pipe_multi GE pipe_multi_threshold[ii]))
    nqso_my_bonus[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and my_bonus GE my_bonus_threshold[ii]))
    nqso_my_galex[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and my_galex GE my_galex_threshold[ii]))
    nqso_my_ukidss[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and my_ukidss GE my_ukidss_threshold[ii]))
    nqso_my_multi[ii]= n_elements(where((known.boss_target1 and 2LL^12) ne 0 and my_multi GE my_multi_threshold[ii]))
ENDFOR
;;print results
print, "for densities", dens
print, "thresholds:"
print, "pipe_bonus", pipe_bonus_threshold
print, "my_bonus", my_bonus_threshold
print, "my_galex", my_galex_threshold
print, "my_ukidss", my_ukidss_threshold
print, "my_multi", my_multi_threshold
print, "pipe_multi", pipe_multi_threshold
print, "# of quasars:"
print, "pipe_bonus", nqso_pipe_bonus
print, "my_bonus", nqso_my_bonus
print, "my_galex", nqso_my_galex
print, "my_ukidss", nqso_my_ukidss
print, "my_multi", nqso_my_multi
print, "pipe_multi", nqso_pipe_multi


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   CHUNK 17
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;use same thresholds
chunk= strmid(spall.chunk,4)
spall= spall[where(chunk EQ 17)]
spherematch, in.ra, in.dec, spall.ra, spall.dec, 2./3600., iindx, sindx
c17= in[iindx]
spall= spall[sindx]
;;calculate all probabilities
pipe_bonus= c17.qsoed_prob_bonus
pipe_multi= c17.qsoed_prob_bonus_multi
my_bonus= (qsoed_calculate_prob(c17,/zfour,/multi)).pqso
my_galex= (qsoed_calculate_prob(add_data(c17,galexdata=galexdata),/galex,/zfour,/multi)).pqso
my_ukidss= (qsoed_calculate_prob(add_data(c17,ukidssdata=ukidssdata),/ukidss,/zfour,/multi)).pqso
my_multi= (qsoed_calculate_prob(add_data(c17,galexdata=galexdata,ukidssdata=ukidssdata),/ukidss,/galex,/zfour,/multi)).pqso
;;find # quasars
nqso_pipe_bonus= lonarr(nthresh)
nqso_pipe_multi= lonarr(nthresh)
nqso_my_bonus= lonarr(nthresh)
nqso_my_galex= lonarr(nthresh)
nqso_my_ukidss= lonarr(nthresh)
nqso_my_multi= lonarr(nthresh)
zmin= 2.15
FOR ii=0L, nthresh-1 DO BEGIN
    nqso_pipe_bonus[ii]= n_elements(where(spall.z GE zmin and pipe_bonus GE pipe_bonus_threshold[ii]))
    nqso_pipe_multi[ii]= n_elements(where(spall.z GE zmin and pipe_multi GE pipe_multi_threshold[ii]))
    nqso_my_bonus[ii]= n_elements(where(spall.z GE zmin and my_bonus GE my_bonus_threshold[ii]))
    nqso_my_galex[ii]= n_elements(where(spall.z GE zmin and ((my_galex GE my_galex_threshold[ii] and c17.galex_matched) or (my_galex GE my_bonus_threshold[ii] and not c17.galex_matched))))
    nqso_my_ukidss[ii]= n_elements(where(spall.z GE zmin and ((my_ukidss GE my_ukidss_threshold[ii] and c17.ukidss_matched) or (my_ukidss GE my_bonus_threshold[ii] and not c17.ukidss_matched))))
    nqso_my_multi[ii]= n_elements(where(spall.z GE zmin and ((my_multi GE my_multi_threshold[ii] and c17.galex_matched and c17.ukidss_matched) or $
                                                             (my_multi GE my_galex_threshold[ii] and c17.galex_matched and not c17.ukidss_matched) or $
                                                             (my_multi GE my_ukidss_threshold[ii] and c17.ukidss_matched and not c17.galex_matched) or $
                                                             (my_multi GE my_bonus_threshold[ii] and not c17.galex_matched and not c17.ukidss_matched))))
ENDFOR
;;print results
print, "# of quasars on chunk17:"
print, "pipe_bonus", nqso_pipe_bonus
print, "my_bonus", nqso_my_bonus
print, "my_galex", nqso_my_galex
print, "my_ukidss", nqso_my_ukidss
print, "my_multi", nqso_my_multi
print, "pipe_multi", nqso_pipe_multi
END
