; Converts magnitude errors to ivars

FUNCTION sdss_magerr2ivar, magerr, m, b

a = 1.08574
ln10_min10 = -23.02585
df= b/5.0*COSH(-m/a-ln10_min10-ALOG(b))*magerr/a
RETURN, 1./df^2D0
END
