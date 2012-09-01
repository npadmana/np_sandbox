PRO DEREDDEN_UKIDSS_QSO, infile

qso= mrdfits(infile,1)

euler, qso.ra, qso.dec, gl, gb, 1
value = dust_getval(gl, gb, /interp)

;;Y
ext= value*1.259D0
good= where(qso.APERCSIFLUX3_Y NE min(qso.APERCSIFLUX3_Y),cnt);;HACK
qso[good].APERCSIFLUX3_Y= sdss_deredden(qso[good].APERCSIFLUX3_Y,ext)
qso[good].APERCSIFLUX3ERR_Y= sdss_deredden(qso[good].APERCSIFLUX3ERR_Y,ext)

;;J
ext= value*0.920D0
good= where(qso.APERCSIFLUX3_J NE min(qso.APERCSIFLUX3_J),cnt);;HACK
qso[good].APERCSIFLUX3_J= sdss_deredden(qso[good].APERCSIFLUX3_J,ext)
qso[good].APERCSIFLUX3ERR_J= sdss_deredden(qso[good].APERCSIFLUX3ERR_J,ext)

;;H
ext= value*0.597D0
good= where(qso.APERCSIFLUX3_H NE min(qso.APERCSIFLUX3_H),cnt);;HACK
qso[good].APERCSIFLUX3_H= sdss_deredden(qso[good].APERCSIFLUX3_H,ext)
qso[good].APERCSIFLUX3ERR_H= sdss_deredden(qso[good].APERCSIFLUX3ERR_H,ext)

;;K
ext= value*0.369D0
good= where(qso.APERCSIFLUX3_K NE min(qso.APERCSIFLUX3_K),cnt);;HACK
qso[good].APERCSIFLUX3_K= sdss_deredden(qso[good].APERCSIFLUX3_K,ext)
qso[good].APERCSIFLUX3ERR_K= sdss_deredden(qso[good].APERCSIFLUX3ERR_K,ext)


;;save
mwrfits, qso, infile, /create

END
