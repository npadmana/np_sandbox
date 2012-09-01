PRO SAMPLE_OUTLIERS, ioutliers, n
IF n LT n_elements(ioutliers) THEN BEGIN
    ;;Cut outliers to fraction, random sampling
    x= lindgen(n_elements(ioutliers))
    y= randomu(seed,n_elements(ioutliers))
    z= x[sort(y)]
    z= z[0:n-1]
    ioutliers= ioutliers[z]
ENDIF
END
