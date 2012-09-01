FUNCTION mags2flux, m
f= 10D0^(-m/2.5D0+9D0)
RETURN, f
END
