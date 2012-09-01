PRO OVERPLOT_SPECLINE_CROSSFILTERS, lambda, filter=filter, _extra=_extra
IF ~keyword_set(filter) THEN filter= 'u'
CASE filter of
    'FUV': BEGIN
        fmin= 1340.6
        fmax= 1810.
    END
    'NUV': BEGIN
        fmin= 1699.
        fmax= 2999.5
    END
    'u': BEGIN
        fmin= 3028.3
        fmax= 3894.6;4026.8
    END
    'g': BEGIN
        fmin= 3894.6;3766.
        fmax= 5485;5523.
    END
    'r': BEGIN
        fmin= 5485;5447.
        fmax= 6838.5;6994.
    END
    'i': BEGIN
        fmin= 6838.5;6683.
        fmax= 8116.1;8359.7
    END
    'z': BEGIN
        fmin= 8116.1;7872.5
        fmax= 10768.2
    END
    'Y': BEGIN
        fmin= 9700.
        fmax= 1070.
    END
    'J': BEGIN
        fmin= 11700.
        fmax= 13300.
    END
    'H': BEGIN
        fmin= 14900.
        fmax= 17800.
    END
    'K': BEGIN
        fmin= 20300.
        fmax= 23700.
    END
ENDCASE

xs= [fmin/lambda-1.,fmax/lambda-1.]
;only plot between 0.3 and 5.5
indx= where(xs GE 0.3 and xs LE 5.5,cnt)
if cnt eq 0 then return
xs= xs[indx]

oplotbarx, xs, _extra=_extra
END
