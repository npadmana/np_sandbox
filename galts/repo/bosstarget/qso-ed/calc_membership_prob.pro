;+
;   NAME:
;      calc_membership_prob
;   PURPOSE:
;      calculate posterior probabilities for objects to be in a
;      component of the mixture
;   CALLING SEQUENCE:
;      calc_membership_prob, logpost, ydata, ycovar, xmean, xcovar, xamp,
;      projection=projection, loglike=loglike
;   INPUT:
;      ydata    - the data [ndimy,ndata]
;      ycovar   - error covariances [ndimy,ndimy,ndata]
;      xmean     - means of the gaussians [ndimx,ngauss]
;      xcovar    - covariances of the gaussians [ndimx,ndimx,ngauss]
;      xamp      - amplitudes of the gaussians [ngauss]
;   OPTIONAL INPUT:
;      projection - [ndimx, ndimy, ndata] non-square matrices
;                  implementing the projection from model space to
;                  observable-space
;   KEYWORDS:
;   OUTPUT:
;      logpost     - matrix of ln of posterior probabilities
;                    [ngauss,ndata]
;   OPTIONAL OUTPUT:
;      loglike     - log-likelihood of all the data points
;   REVISION HISTORY:
;      2008-12-16 - Written - Jo Bovy (NYU)
;      2010-02-24 - ReWritten to be stand-alone - Bovy
;      2010-06-11 - Slightly rewritten to go in 'addons' - Bovy
;      2011-01-18 - Added 'loglike' output - Bovy
;-
FUNCTION BOVY_LOGSUM, array
amax= max(array)
RETURN, amax+alog(total(exp(array-amax),/double))
END
FUNCTION SPECIAL_INVERT, matrix
RETURN, invert(matrix,/double)
END
function bovy_determ, matrix, double=double, check=check

	if n_elements(matrix) eq 1 then begin
		return, matrix 
	endif

	; ESS
	; Got a mysterious crash in one case: Something
	; about a singular matrix.  try to catch
	; the error by wrapping it in a execute() call
	command = 'det = determ(matrix,double=double,check=check)'
	if not execute(command) then begin
		splog,'Failed to get determinant, returning zero'
		det = 0d
	endif
	return, det
end
PRO CALC_MEMBERSHIP_PROB, logpost, ydata, ycovar, xmean, xcovar, xamp, $
                          projection=projection, loglike=loglike

;;This assumes that the dimensions of all datapoints are equal
ngauss= n_elements(xamp)
ndimx= n_elements(xmean)/ngauss
ndimy=(size(ydata,/dimensions))[0]
ndata=n_elements(ydata)/ndimy
if ~keyword_set(projection) and ndimx NE ndimy THEN $
  message, "Dimension of model is not equal to the dimension of the data and projection is not set"
IF n_elements(ycovar) EQ n_elements(ydata) THEN diagcovar= 1B ELSE diagcovar= 0B

twopiterm=0.5*double(ndimy)*alog(2.*!DPI)

logpost= dblarr(ngauss,ndata)
IF arg_present(loglike) THEN loglike= dblarr(ndata)
;;Loop over data and Gaussians to find posterior probabilities
FOR ii= 0L, ndata-1 DO BEGIN
    thisloglike= dblarr(ngauss)
    FOR kk= 0L, ngauss-1 DO BEGIN
        IF keyword_set(projection) THEN BEGIN
            IF diagcovar THEN BEGIN
                tinv=special_invert(transpose(projection[*,*,ii])#xcovar[*,*,kk]# $
                                  projection[*,*,ii]+diag_matrix(ycovar[*,ii]))
            ENDIF ELSE BEGIN
                tinv=special_invert(transpose(projection[*,*,ii])#xcovar[*,*,kk]# $
                                    projection[*,*,ii]+ycovar[*,*,ii])
            ENDELSE
            delta=ydata[*,ii]-transpose(projection[*,*,ii])#xmean[*,kk]
        ENDIF ELSE BEGIN
            IF diagcovar THEN BEGIN
                tinv=special_invert(xcovar[*,*,kk]+diag_matrix(ycovar[*,ii]))
            ENDIF ELSE BEGIN
                tinv=special_invert(xcovar[*,*,kk]+ycovar[*,*,ii])
            ENDELSE
            delta=ydata[*,ii]-xmean[*,kk]
        ENDELSE
        thisloglike[kk]=alog(xamp[kk])+0.5*alog(bovy_determ(tinv,/double,/check) > (machar(/double)).xmin)- $
          0.5*transpose(delta)#tinv#delta-twopiterm
    ENDFOR
    ;;normalize the probabilities
    curr_loglikedata=bovy_logsum(thisloglike)
    IF arg_present(loglike) THEN loglike[ii]= curr_loglikedata
    logpost[*,ii]=thisloglike-curr_loglikedata
ENDFOR
END
