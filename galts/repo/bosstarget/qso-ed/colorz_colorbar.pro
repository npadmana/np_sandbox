PRO COLORZ_COLORBAR, plotfile
k_print, filename=plotfile
;;density
bar = REPLICATE(1B, 10) # BINDGEN(256)
;;plot
ncolors= !D.TABLE_SIZE
bar = BYTSCL(bar, TOP=255-1)

!X.RANGE= [0.,1]
!Y.RANGE= [0.5,5.]
djs_plot, [0],[1],xrange=xrange,yrange=yrange, $
  position=[0.45,0.1,0.55,0.9], xtickname=strarr(30)+' '

;;color scheme
loadct, 34
tv, bar, !X.RANGE[0],!Y.RANGE[0],/data, $
  xsize=(!X.CRANGE[1]-!X.CRANGE[0]), $
  ysize=(!Y.CRANGE[1]-!Y.CRANGE[0])
loadct, 0
!P.MULTI[0]= !P.MULTI[0]+1
djs_plot, [0],[1],xrange=xrange, yrange=yrange, ytitle='redshift', $
  position=[0.45,0.1,0.55,0.9], xtickname=strarr(30)+' ', xstyle=4, $
  yminor=5, ticklen=0.2
axis, xaxis=0, xtickname=strarr(30)+' ', ticklen=0
axis, xaxis=1, xtickname=strarr(30)+' ', ticklen=0
k_end_print
END
