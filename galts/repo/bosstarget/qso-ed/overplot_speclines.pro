PRO OVERPLOT_SPECLINES, filter, lylim=lylim
thick=4.
;;Lyman-alpha
lya= 1215.668
overplot_specline_crossfilters, lya, filter=filter, $
  color=djs_icolor('gray'), thick=thick
;;CIV
c4= 1549.06
overplot_specline_crossfilters, c4, filter=filter, $
  color=djs_icolor('gray'), thick=thick, linestyle=1
;;CIII
c3= 1908.73
overplot_specline_crossfilters, c3, filter=filter, $
  color=djs_icolor('gray'), thick=thick, linestyle=2
;;MgII
mg2= 2798.75
overplot_specline_crossfilters, mg2, filter=filter, $
  color=djs_icolor('gray'), thick=thick, linestyle=3
;;Ha
ha= 6564.61
overplot_specline_crossfilters, ha, filter=filter, $
  color=djs_icolor('gray'), thick=thick, linestyle=4
IF keyword_set(lylim) THEN BEGIN
    ;;Lyman-limit
    lyl= 912.
    overplot_specline_crossfilters, lyl, filter=filter, $
      color=djs_icolor('light gray'), thick=10., linestyle=0
ENDIF
END
