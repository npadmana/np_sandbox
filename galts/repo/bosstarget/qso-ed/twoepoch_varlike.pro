FUNCTION TWOEPOCH_VARLIKE, in, gri=gri
;gri= use g, r, and i
;;deredden
ndata= n_elements(in.modelflux1[0])
prep_data, in.modelflux1, in.modelflux_ivar1, $
  extinction=in.extinction, mags=mags1, var_mags=ycovar1
prep_data, in.modelflux2, in.modelflux_ivar2, $
  extinction=in.extinction, mags=mags2, var_mags=ycovar2
if keyword_set(gri) then begin
    g2r= mags2[2,*]+(mags1[1,*]-mags1[2,*])
    g2r_invvar= 1./(ycovar2[2,*]+ycovar1[1,*]+ycovar1[2,*])
    g2i= mags2[3,*]+(mags1[1,*]-mags1[3,*])
    g2i_invvar= 1./(ycovar2[3,*]+ycovar1[1,*]+ycovar1[3,*])
    mags2[1,*]= mags2[1,*]/ycovar2[1,*]+g2r*g2r_invvar+g2i*g2i_invvar
    ycovar2[1,*]= 1./(1./ycovar2[1,*]+g2r_invvar+g2i_invvar)
    mags2[1,*]*= ycovar2[1,*]
endif
;;load fits
qsofits= mrdfits('kmeans_30_powerlawSF_g.fits',1)
starfits= mrdfits('kmeans_30_star_powerlawSF_g.fits',1)
;;do the relevant calculation for each
nqso= n_elements(qsofits.loga)
qso_out= dblarr(ndata)
for ii=0L, ndata-1 do begin
    tmp_out= dblarr(nqso)
    for jj=0L, nqso-1 do begin
        thisvar= exp(qsofits[jj].logA)*(abs(float(in[ii].mjd1)-float(in[ii].mjd2))/365.25)^qsofits[jj].gamma+ycovar1[1,ii]+ycovar2[1,ii]
        tmp_out[jj]= -(mags1[1,ii]-mags2[1,ii])^2/2./thisvar-0.5*alog(thisvar*2.*!DPI)+qsofits[jj].logweight
    endfor
    qso_out[ii]= bovy_logsum(tmp_out)
endfor
qso_out-= bovy_logsum(qsofits.logweight)
nstar= n_elements(starfits.loga)
star_out= dblarr(ndata)
for ii=0L, ndata-1 do begin
    tmp_out= dblarr(nstar)
    for jj=0L, nqso-1 do begin
        thisvar= exp(starfits[jj].logA)*(abs(float(in[ii].mjd1)-float(in[ii].mjd2))/365.25)^starfits[jj].gamma+ycovar1[1,ii]+ycovar2[1,ii]
        tmp_out[jj]= -(mags1[1,ii]-mags2[1,ii])^2/2./thisvar-0.5*alog(thisvar*2.*!DPI)+starfits[jj].logweight
    endfor
    star_out[ii]= bovy_logsum(tmp_out)
endfor
star_out-= bovy_logsum(starfits.logweight)
;;create output structure
outStruct= {qsologlike:0.D,$
           starloglike:0.D}
out= replicate(outStruct,ndata)
out.qsologlike= qso_out
out.starloglike= star_out
RETURN, out
END
