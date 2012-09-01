;+
; NAME:
;   qso_rank.pro
;
; PURPOSE:
;   Take (i) input set of spectroscopic quasars targeted at a known fiber density
;   (ii) target photometry that contains the three method parameters used in BOSS 
;	the ratio from the likelihood method
;	the probability from the KDE method 
;	the Neural Net weight from the NN method
;   and ra/dec to match back against the input spectroscopic sample and 
;   (iii) A test sample of targets that also contain the three method parameters and 
;   covers a known area. From this information, return the values of the three 
;   methods that maximize the targeting of new quasars at a given fiber density.
;
; CALLING SEQUENCE:
;  qso_rank, testfile, targfile, specfile, platefile, total_area, fib_den_orig, /score
;
; INPUTS:
; testfile: A file corresponding to a test area of targets. The structure in this file 
;	must contain the tags kde_prob, x2_star, like_ratio, nn_xnn2, nn_znn_phot
;	and inwindow. The area where .inwindow=1 corresponds to the
;	"total_area" input
; targile: A file that contains the photometric information (kde_prob, like_ratio, nn_xnn2)
;	for the passed spectroscopic objects. This file also needs ra/dec
; specfile: A set of spectroscopic objects that were targeted at the fiber density fib_den_orig
;	this file must contain the tag z_person to specify what is a BOSS quasar
; platefile: A file that contains the list of plates occupied by the specfile in the format
;	plate (integer) ra dec (degrees). See specplates documentation for more
; total_area: The area occupied by the testfile with inwindow=1
; fib_den_orig: The fiber density that the objects in specfile were targeted at
;
; OPTIONAL INPUTS:
; /score:   If this keyword is set then each quasars value of "1" is replaced by it's value
; 	from Pat Macdonald's table of LyA forest values
;
; OUTPUTS:
;	retrained_chosen_qso_kde_like_nn_more.dat
;	retrained_target_qso_kde_like_nn_more.dat
;	fiber_density.dat
;	real_fiber_density.dat
;	retrained_value_summed_kde_like_nn.dat
; are all written. The most important files are 
;	fiber_density.dat, 
; which contains the output targeting information from the ranking procedure
; based on an area derived from the input spectroscopic objects and
;	real_fiber_density.dat 
; which is the same targeting information based on the input test area
; and corresponds to what should be done if we target that test area
; 
; COMMENTS:
; You must have $BOSSTARGET_DIR set up as an environment variable. 
; All output files are assumed to be in $BOSSTARGET_DIR/data/rank
; All output files are written to $BOSSTARGET_DIR/data/rank
;
; EXAMPLES:
;
; If no inputs are passed to the code, the following files are defaulted to
;	testfile = 'bosstarget-qso-2010-01-12l-collate-trim2.fits'
;	targfile = 'bosstarget-qso-2010-01-12l-collate-trim2.fits'
;	specfile = 'BOSS_Quasars_1PCplus.nodups.fits'
;	platefile = 'plate_list_RA_DEC'
;	total_area = 151.04801
;	fib_den_orig = 80.
;
; and the output targeting density would be written to 
;	$BOSSTARGET_DIR/data/rank/real_fiber_density.dat
;
; INTERNAL PROCEDURES CALLED:
;   specplates.pro
;
; REVISION HISTORY:
;   Dec-2009:  Written by Shirley Ho, LBNL
;   Jan-21-2010: Substantially reduced size of optimizing fiber matrix 
;	by only updating it when it's state changes rather than fully
;	populating it
;   New philosophy behind method. Now the size of the known quasar sample and its
;	fiber density is used to set the effective area covered by the 
;	known quasars. Then, this area, multiplied by the input density of the
;	objects in the input test file sets the number of "stars" we
;	need to rank interspersed within the known quasars. We then select these
;	"stars" at random from the input test file.
;	Now, in theory, one can use any arbitray set of known quasars 
;	and any set of photometric targets as stars and see how things change
;	in different survey areas.
;	Adam D. Myers, UIUC	
;-
;------------------------------------------------------------------------------
function patval, struc
;Given an input structure that contains g_mag and z_person, 
;return array of Pat Mcdonald's values that correspond to the structure.

	dir=filepath(root=getenv("BOSSTARGET_DIR"), "data")
	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	qvfile = filepath(root=dir, "quasarvalue.txt")
	readcol, qvfile, zval, gval, Pval, format='d,d,d'

	g = double(struc.g_mag)
	z = double(struc.z_person)

	outly = fltarr(n_elements(g))*0.0
	zarr = intarr(n_elements(g))*0
	garr = intarr(n_elements(g))*0

	good = where(z gt 1.975 and z lt 4.025 and g lt 23.05 and g gt 18.05)

	zarr[good] = 50*fix((z[good]-1.975d0)/0.05d0)
	garr[good] = fix(10d0*(23.04999999d0-g[good]))

	outly[good] = Pval[zarr[good]+garr[good]] 

;	print, zval[zarr+garr], gval[zarr+garr]

return, outly

END

PRO test_each_method, testfile, bq, total_area, area
; This code tests each method's return individually based on
; 'testfile' The file containing the test photometry
; 'bq' The structure containing the successful BOSS QSOs
; 'total_area' The total area covered by testfile with inwindow=1
; 'realarea' The effective area covered by the spectroscopic objects in bq
; Adam D. Myers, January 28, 2010

	;ADM now let's assume that we give each method 40 or 60 fibs per sq. deg. and
	;see how well they do

	;ADM load code in bosstarget define code
	bqcode = obj_new('bosstarget_qso')

	testobj = mrdfits(testfile,1)
;	testobj = testobj[where(testobj.inwindow)]
	;ADM get the magnitudes for testobj
	lups = bqcode->get_lups(testobj, /deredden)
	umg = reform(lups[0,*]-lups[1,*])
	gmi = reform(lups[1,*] - lups[3,*])

	; ADM always downweight unwanted KDE objects
	testobj[where(testobj.x2_star le 7.0)].kde_prob = 0.0
	; ADM always downweight unwanted NN objects
	testobj[where(testobj.nn_znn_phot le 2.1)].nn_xnn2 = -9999.
;	testobj[where(umg lt 0.4)].nn_xnn2 = -9999.
;	testobj[where(gmi gt 2.0)].nn_xnn2 = -9999.

	sixty = floor(total_area*60.)
	forty = floor(total_area*40.)

	;ADM order by kde_prob
	sorted = sort(testobj.kde_prob)
	revs = reverse(sorted)
	;ADM find the minimum value of kde_prob allowed to populate all fibers
	ffk = testobj[revs[forty]].kde_prob
	ssk = testobj[revs[sixty]].kde_prob
	;ADM find the sum of the QSO values (per sq. deg.) for this minimum value
	qso40 = total(bq[where(bq.kde_prob gt ffk)].qsoval)/area
	qso60 = total(bq[where(bq.kde_prob gt ssk)].qsoval)/area
	print, 'KDE: QSOs recovered at 40 and 60 fibers per sq. deg.', qso40, qso60

	;ADM order by like_ratio
	sorted = sort(testobj.like_ratio)
	revs = reverse(sorted)
	;ADM find the minimum value of like_ratio allowed to populate all fibers
	ffl = testobj[revs[forty]].like_ratio
	ssl = testobj[revs[sixty]].like_ratio
	;ADM find the sum of the QSO values (per sq. deg.) for this minimum value
	qso40 = total(bq[where(bq.like_ratio gt ffl)].qsoval)/area
	qso60 = total(bq[where(bq.like_ratio gt ssl)].qsoval)/area
	print, 'LIKE: QSOs recovered at 40 and 60 fibers per sq. deg.', qso40, qso60

	;ADM order by nn_xnn2
	sorted = sort(testobj.nn_xnn2)
	revs = reverse(sorted)
	;ADM find the minimum value of nn_xnn2 allowed to populate all fibers
	ffn = testobj[revs[forty]].nn_xnn2
	ssn = testobj[revs[sixty]].nn_xnn2
	;ADM find the sum of the QSO values (per sq. deg.) for this minimum value
	qso40 = total(bq[where(bq.nn_xnn2 gt ffn)].qsoval)/area
	qso60 = total(bq[where(bq.nn_xnn2 gt ssn)].qsoval)/area
	print, 'NN: QSOs recovered at 40 and 60 fibers per sq. deg.', qso40, qso60

	;ADM plot quasars recoved by each method

	ps_start,/encapsulated, filename = '40fib.eps', bits_per_pixel=24, /color, /helv,/isolatin1 

	!p.font=0   ; select hardware fonts
	!p.thick=2

	plot, bq[where(bq.kde_prob gt ffk)].z_person, bq[where(bq.kde_prob gt ffk)].g_mag,    $
		xrange = [2.09, 3.51], yrange=[17.9,22.2], xtitle='z', ytitle='g', charsize=1.2,   $
		/NODATA, /YSTYLE, /XSTYLE
	oplot, bq[where(bq.kde_prob gt ffk)].z_person, bq[where(bq.kde_prob gt ffk)].g_mag,  $
		psym=7, color=FSC_COLOR('blue')
	oplot, bq[where(bq.like_ratio gt ffl)].z_person, bq[where(bq.like_ratio gt ffl)].g_mag,   $
		psym=6, color=FSC_COLOR('red'), symsize=1.1
	oplot, bq[where(bq.nn_xnn2 gt ffn)].z_person, bq[where(bq.nn_xnn2 gt ffn)].g_mag,     $
		psym=5, color=FSC_COLOR('green'), symsize=1.1
	ps_end, /png

	ps_start,/encapsulated, filename = '60fib.eps', bits_per_pixel=24, /color, /helv,/isolatin1
	!p.font=0   ; select hardware fonts
	!p.thick=2

	plot, bq[where(bq.kde_prob gt ssk)].z_person, bq[where(bq.kde_prob gt ssk)].g_mag,    $
		xrange = [2.09, 3.51], yrange=[17.9,22.2], xtitle='z', ytitle='g', charsize=1.2,   $
		/NODATA, /YSTYLE, /XSTYLE
	oplot, bq[where(bq.kde_prob gt ssk)].z_person, bq[where(bq.kde_prob gt ssk)].g_mag,  $
		psym=7, color=FSC_COLOR('blue')
	oplot, bq[where(bq.like_ratio gt ssl)].z_person, bq[where(bq.like_ratio gt ssl)].g_mag,   $
		psym=6, color=FSC_COLOR('red'), symsize=1.1
	oplot, bq[where(bq.nn_xnn2 gt ssn)].z_person, bq[where(bq.nn_xnn2 gt ssn)].g_mag,     $
		psym=5, color=FSC_COLOR('green'), symsize=1.1
	ps_end, /png

	;ADM print number of unique quasars acquired by each method
	kdeff = where(bq.kde_prob gt ffk) ; ADM quasars acquired by each
	likeff = where(bq.like_ratio gt ffl) ; method at 40 per sq. deg.
	nnff = where(bq.nn_xnn2 gt ffn)
	kdess = where(bq.kde_prob gt ssk) ; ADM quasars acquired by each
	likess = where(bq.like_ratio gt ssl) ; method at 60 per sq. deg.
	nnss = where(bq.nn_xnn2 gt ssn)

	good = indgen(n_elements(kdeff))*0
	;ADM where the KDE finds quasars set good to 1
	good[kdeff] = 1
	;ADM where the like, nn also found these quasars zero good
	good[likeff] = 0
	good[nnff] = 0
	uniq40 = total(good)/area ; ADM the unique quasars the KDE found at 40 per sq. deg

	good = indgen(n_elements(kdess))*0
	;ADM where the KDE finds quasars set good to 1
	good[kdess] = 1
	;ADM where the like, nn also found these quasars zero good
	good[likess] = 0
	good[nnss] = 0
	uniq60 = total(good)/area ; ADM the unique quasars the KDE found at 60 per sq. deg

	print, 'KDE: Unique QSOs recovered at 40 and 60 fibers per sq. deg.', uniq40, uniq60

	good = indgen(n_elements(likeff))*0
	;ADM where the LIKE finds quasars set good to 1
	good[likeff] = 1
	;ADM where the kde, nn also found these quasars zero good
	good[kdeff] = 0
	good[nnff] = 0
	uniq40 = total(good)/area ; ADM the unique quasars the LIKE found at 40 per sq. deg

	good = indgen(n_elements(likess))*0
	;ADM where the LIKE finds quasars set good to 1
	good[likess] = 1
	;ADM where the kde, nn also found these quasars zero good
	good[kdess] = 0
	good[nnss] = 0
	uniq60 = total(good)/area ; ADM the unique quasars the LIKE found at 60 per sq. deg

	print, 'LIKE: Unique QSOs recovered at 40 and 60 fibers per sq. deg.', uniq40, uniq60

	good = indgen(n_elements(nnff))*0
	;ADM where the NN finds quasars set good to 1
	good[nnff] = 1
	;ADM where the like, kde also found these quasars zero good
	good[likeff] = 0
	good[kdeff] = 0
	uniq40 = total(good)/area ; ADM the unique quasars the NN found at 40 per sq. deg

	good = indgen(n_elements(nnss))*0
	;ADM where the NN finds quasars set good to 1
	good[nnss] = 1
	;ADM where the like, kde also found these quasars zero good
	good[likess] = 0
	good[kdess] = 0
	uniq60 = total(good)/area ; ADM the unique quasars the NN found at 60 per sq. deg

	print, 'NN: Unique QSOs recovered at 40 and 60 fibers per sq. deg.', uniq40, uniq60



END

;------------------------------------------------------------------------------
PRO specplates, photfile, fieldfile,outdata,ext
; This routine simply uses specmatch to cut a sample in 
; photfile (structure that must contain ra/dec)
; Down to the boundaries of a set of passed plates in
; fieldfile which is a flat file that has the format
; plate (integer)  ra dec (both degrees)
; e.g., 3655 110.34 40.31
; The matching is always done at a BOSS-style plate radius of 1.5 
; the resulting cut-down structure is returned as outdata
; and written to a file that is the input file with
; .fits changed to .reducflds.fits
; ext is the extension in the input file that stores the fits structure.
;
; e.g. ; specplates, 'bosstarget-qso-comm-collate-bitmask-infields-rankprob-patranksV3.fits', 'fieldcenters.txt', givemethisnewstructure, 1
; Adam D. Myers, November 2009

	outfile = strsplit(photfile, '.fits',/regex, /extract)+".reducflds.fits"

	; ADM make a structure for the fields listed in fieldfile
	readcol, fieldfile, plate, racent, deccent, $
        		format='i,d,d', skip=1

	stdef={plate:-1,ra:0d, dec:0d}

	fld = replicate(stdef, n_elements(racent))

	fld.plate = plate
	fld.ra = racent
	fld.dec = deccent

	sgc = mrdfits(photfile,ext) 
	inobj = indgen(n_elements(sgc))*0 
	; ADM we need inobj because there are a lot of duplicate objects in 
	; overlapping fields and we only want to store one of each object

	spherematch, sgc.ra, sgc.dec, fld.ra, fld.dec, 1.5, sgcmatch, fldmatch, maxmatch=0
	; ADM Find everything in the field centers out to a "BOSS" radius 1.5 degrees.

	splog, 'size of the matched targets in the plates we specified: ', size(sgcmatch)
	inobj[sgcmatch]=1 
	; ADM now uniquely know the index of everything that matches the field centers

	outdata = sgc[where(inobj)]

	mwrfits, outdata, outfile, /create
	splog,'done with specplates'

	;plot,outdata.ra,outdata.dec, psym=3, position=[0.08,0.55,0.99,0.92], ytitle='Dec', 
	;charsize=1.5, /NOERASE, title='NEW'

END

;----------------------------------------------------------
PRO qso_rank, testfile, targfile, specfile, platefile, total_area, fib_den_orig, score=score

	tm0=systime(1)

	bqcode = obj_new('bosstarget_qso')

	dir=filepath(root=getenv("BOSSTARGET_DIR"), "data")
        	if dir eq '' then message,'$BOSSTARGET_DIR not set'
	dir=filepath(root=dir, "rank")
	
	; ADM defaults, and some example standard inputs
	if not keyword_set(testfile) then $
		testfile = 'bosstarget-qso-2010-01-12l-collate-trim2.fits'
	if not keyword_set(targfile) then $
		targfile = 'bosstarget-qso-2010-01-12l-collate-trim2.fits'
	if not keyword_set(specfile) then $
		specfile = 'BOSS_Quasars_1PCplus.nodups.fits'
	if not keyword_set(platefile) then $
		platefile = 'plate_list_RA_DEC'
	if not keyword_set(total_area) then $
		total_area = 141.04801

	if not keyword_set(fib_den_orig) then fib_den_orig = 80.

	testfile = dir+'/'+testfile
	targfile = dir+'/'+targfile
	specfile = dir+'/'+specfile
	platefile = dir+'/'+platefile

	;The output files:
	file_match_chosen = dir+'/retrained_chosen_qso_kde_like_nn_more.dat'
	file_target_chosen = dir+'/retrained_target_qso_kde_like_nn_more.dat'
	file_fib = dir+'/fiber_density.dat'
	file_fib_real = dir+'/real_fiber_density.dat'
	file_f = dir+'/retrained_value_summed_kde_like_nn.dat'
		
	nmethod =3 ; Number of methods

	;READING in the inputs
	;ADM the test photometry

	testobj = mrdfits(testfile,1)
;	testobj = testobj[where(testobj.inwindow)]

	;ADM get the magnitudes for testobj
	lups = bqcode->get_lups(testobj, /deredden)
	umg = reform(lups[0,*]-lups[1,*])
	gmi = reform(lups[1,*] - lups[3,*])

	; ADM always downweight unwanted KDE objects
	testobj[where(testobj.x2_star le 7.0)].kde_prob = 0.0 
	; ADM always downweight unwanted NN objects
	testobj[where(testobj.nn_znn_phot le 2.1)].nn_xnn2 = -9999. 
;	testobj[where(umg lt 0.4)].nn_xnn2 = -9999. 
;	testobj[where(gmi gt 2.0)].nn_xnn2 = -9999. 

	testdens = 1.*n_elements(testobj)/total_area

	;ADM the target photometry to match to the spectroscopy
	targs = mrdfits(targfile, 1)
;	targs = targs[where(targs.inwindow)]
	;ADM get the magnitudes for targs
	lups = bqcode->get_lups(targs, /deredden)
	umg = reform(lups[0,*]-lups[1,*])
	gmi = reform(lups[1,*] - lups[3,*])

	;ADM always downweight unwanted KDE objects
	targs[where(targs.x2_star le 7.0)].kde_prob = 0.0
	;ADM always downweight unwanted NN objects 
	targs[where(targs.nn_znn_phot le 2.1)].nn_xnn2 = -9999.
;	targs[where(umg lt 0.4)].nn_xnn2 = -9999. 
;	targs[where(gmi gt 2.0)].nn_xnn2 = -9999. 

	;read in spectro objects and restrict to chosen spectroscopic plates
	specplates,specfile,platefile,spec,1 
	;ADM The 1 here is because commissioning spectroscopy files have data in fits extension 1

	;ADM match spectroscopic targets with input photometry
	spherematch, targs.ra, targs.dec, spec.ra, spec.dec, 2/3600., targmatch, specmatch

	;ADM make a structure that has the photometric information for each spectroscopic object
	spec = struct_combine(targs[targmatch], spec[specmatch])

	;ADM what is the effective area covered by the spectroscopic targets
	N_sqdeg = 1.*n_elements(specmatch)/fib_den_orig

	splog, 'Total number of input spectra', n_elements(specmatch)
	splog, 'Effective area based on spectroscopic data', N_sqdeg,  ' sq. deg'

	bossqsos = spec[where(spec.z_person ge 2.2 and spec.z_person lt 3.50)]
	nbq = n_elements(bossqsos)
	;ADM get the magnitudes
	lups = bqcode->get_lups(bossqsos, /deredden)

	splog, 'number of BOSS quasars', nbq
	splog, 'number of BOSS quasars per sq. deg.', 1.*n_elements(bossqsos)/N_sqdeg
	splog, 'efficiency', (1./80)*n_elements(bossqsos)/N_sqdeg

	; ADM make a structure to house what we care about for the known "BOSS" QSOs
	bq = {ra:0.0,dec:0.0,kde_prob:0.0, 	$
		like_ratio:0.0, nn_xnn2:0.0, z_person:0., g_mag:0., qsoval:0.}
	bq = replicate(bq, nbq)
	bq.ra = bossqsos.ra
	bq.dec = bossqsos.dec
	bq.kde_prob = bossqsos.kde_prob
	bq.like_ratio = bossqsos.like_ratio
	bq.nn_xnn2 = bossqsos.nn_xnn2
	bq.z_person = bossqsos.z_person
	bq.g_mag = transpose(lups[1,*])
	if keyword_set(score) then begin
		bq.qsoval = patval(bq)
	endif else begin
		bq.qsoval = 1.0
	endelse

	; ADM We now need to remove any of the known QSOs that we'll test from the 
	; test objects so we don't count them twice

	; ADM match to known QSOs and the test objects
	spherematch, testobj.ra, testobj.dec, bq.ra, bq.dec, 2/3600., m1, m2
	; ADM if there are matches continue

	if size(m1, /dim) gt 0 then begin
	; ADM Let every test object be "good", logical 1
		good = uintarr(n_elements(testobj))+1
	; ADM now set the matches with the QSOs to be"bad"
		good[m2] = 0
	; ADM and only keep the goodies
		testobj = testobj[where(good)]
	endif
	ntestobj = n_elements(testobj)

	; ADM Now, here is the philosophy for obtaining the correct number of test targets
	; we know the effective area covered by the spectroscopic objects
	; we know the sky density of the test objects
	; we can derive the total number of test objects we need to embed the spectro objects in...
	; note that we are obtaining a representative area somewhere different to the 
	; spectro objects but this is OK, because we want objects representative of the input 
	; test area not of the spectroscopic plates

	; ADM How many test objects do we need?
	numtest = fix(testdens*N_sqdeg)

	; ADM How many test objects do we need over the known QSOs?
	numtest -= nbq

	; ADM make a test structure to house the test objects
	teststruc = {ra:0., dec:0.,kde_prob:0., like_ratio:0., nn_xnn2:0., 	$
			z_person:0., g_mag:0., qsoval:0.}
	teststruc = replicate(teststruc, numtest)

	; ADM we'll randomly sample the test objects to get this number
	;to do this efficiently using IDL's random number generator, we generate a list
	;of random floats the length of the number of test objects, sort this list to randomly
	;reorder the indices and extract the first numtest objects from this randomly sorted list

	ranfloat = randomu(s, ntestobj)
	randoms = (sort(ranfloat))[0:numtest-1]

	; ADM populate the teststruc with these randomly selected test objects

	teststruc.ra = testobj[randoms].ra
	teststruc.dec = testobj[randoms].dec
	teststruc.kde_prob = testobj[randoms].kde_prob
	teststruc.like_ratio = testobj[randoms].like_ratio
	teststruc.nn_xnn2 = testobj[randoms].nn_xnn2
	teststruc.z_person = 0.0 ; this says these are stars
	teststruc.g_mag = 0.0 ; this says these are stars
	teststruc.qsoval = 0.0 ; this says these are stars

	; ADM now combine our list of test photometric objects and out list of known QSOs into 
	; a single structure that contains all the info we need at the correct object density

	targs = struct_concat(bq, teststruc)


	nancheck = where(targs.kde_prob ne targs.kde_prob, nancount)

	if nancount gt 0 then begin
		targs[nancheck].kde_prob = 0.0
			; there are a few NaN for the KDE_PROB
	endif		; set these to 0.0

	list_length = size(targs,/n_elements)

	;initializing the value list
	value_sort = fltarr(list_length,6)

	;retrieve the required information from the targs structure
	value_sort(*,0) = targs.qsoval ;
	value_sort(*,1) = targs.kde_prob
	value_sort(*,2) = targs.like_ratio
	value_sort(*,3) = targs.nn_xnn2
	value_sort(*,4) = targs.z_person  ; set BOSS quasars redshifts
	value_sort(*,5) = targs.g_mag  ; set BOSS quasars magnitudes

	list = fltarr(nmethod,list_length,nmethod)
	list_sort_index = fltarr(nmethod,list_length)

	for i = 0,(nmethod-1L) do begin 
		list(i,*,0) = value_sort(*,i+1)  
		; the ranking from method i: 0: KDE, 1: LIKElihood, 2: NN
		list(i,*,1) = value_sort(*,0)  ; the value
		list(i,*,2) = indgen(list_length)  ; the index in the list
		list_sort_ind = reverse(sort(list(i,*,0)))
		list_sort_index(i,*) = list(i,list_sort_ind,2)  ; store the index number
	endfor

	list_used_target = [-1] ; store the index of targets that have been used

	f = fltarr(list_length,4)*0. ; the matrix to store fiber changes, initialized to 0

	x = uintarr(nmethod)
	x(*) = 0 ; starting from 0 index 
	total_val = fltarr(nmethod) ; store the total value of qso we acquire going down the list
	total_qso = uintarr(nmethod) ; store the number of qso we acquire going down each list 
	n_obs =uintarr(nmethod)  ; store the number of targets that are actually observed
	n_obs(*) = 0  ; starting with 0

	close,10
	openw,10,file_match_chosen
	close,20
	openw,20,file_target_chosen
	close,30
	openw,30,file_fib
	close,40
	openw,40,file_fib_real

	totcount = 0L ; ADM keep track of the total numbers of objects to track the object density
	current = fltarr(nmethod) ; ADM keep track of the current value of each of the methods

	track = 0	; ADM this lets us track changes of state in the fiber density for writing out f
	totfibnow = 0 ; ADM this is the state of the f matrix

	; ADM the onscreen information header
	print, 'Fibers QSOs KDE_fib KDE_QSO LIKE_fib LIKE_QSO NN_fib NN_QSO kdeprob likeratio nn_xnn2 efficiency' 

	while ((x(0) lt  list_length-1L ) and (x[1] lt  list_length-1L ) and (x[2] lt  list_length-1L ) $
	and (1.*totcount/N_sqdeg) lt (fib_den_orig+1.)) do begin 
	;ADM terminate when we hit the end of the rankable list or 80 fibers per sq. deg (+1)     

    	for mind = 0,(nmethod-1L) do begin 
	; at each list, we have to resolve conflicts (which means two things)
	; 1) the target is already used
	; 2) some of the candidates from each of these methods are identical
        		ind = list_sort_index(mind,x[mind])
     		dummy = where(list_used_target eq ind, count)
        		if ((count eq 0) ) then begin
        			total_val(mind) = total_val(mind) + value_sort(ind,0)
 	         		n_obs[mind] = n_obs[mind] + 1

        	  		if (value_sort(ind,0) gt 0) then begin 
            				total_qso(mind) = total_qso(mind) + 1
				; number of quasars
            				printf,10,format='(I,I,E19.5,E19.5,E23.5,E19.5,E19.5)', $
				mind,ind,		$
				value_sort(ind,4), 	$; z (0.0 for non BOSS successes)
				value_sort(ind,5), 	$; r mag (0.0 for non BOSS successes)
				value_sort(ind,1), 	$; the KDE value
				value_sort(ind,2), 	$; the LIKE value
				value_sort(ind,3) 	; the NN value
  	        		endif

			list_used_target = [list_used_target,ind]  
			; add target index to list of used targets
		
           			printf,20,format='(I,I,E19.5,E19.5,E23.5,E19.5,E19.5)', 	$
			mind,ind,		$
			value_sort(ind,4), 	$	; redshift (0.0 for non BOSS successes)
			value_sort(ind,5), 	$	; r mag (0.0 for non BOSS successes)
			value_sort(ind,1), 	$	; the KDE value
			value_sort(ind,2), 	$	; the LIKE value
			value_sort(ind,3) 		; the NN value

			totcount += 1L ; total number of targets we have stored
			current(mind) = value_sort(ind, mind+1)
	      		if abs(totcount/nint(N_sqdeg) - 	$
				float(totcount)/nint(N_sqdeg)) lt 1e-16 then begin
				; print results every 1 sq. deg. rather than every result
				
				; ADM better estimate of effective area
				grandtotal = n_elements(where(		$
					testobj.kde_prob ge current[0] or	$ 
					testobj.like_ratio ge current[1] or 	$
					testobj.nn_xnn2 gt current[2]))
				realarea = total_area*totcount/grandtotal

				; ADM write relevant diagnostics to screen
				print,format='(8(F5.2,2x),3(F9.5,2x),F5.3)', 	$
				totcount/N_sqdeg, 	         	$ ; total targets per. sq. deg.
				total(total_val)/N_sqdeg,    	$ ; total QSOs per sq. deg.
      				n_obs[0]/N_sqdeg, 	          	$ ; total KDE targets p.s.d
      				total_val[0]/N_sqdeg,         	$ ; total KDE QSOs p.s.d
      				n_obs[1]/N_sqdeg, 	          	$ ; total LIKE targets p.s.d
      				total_val[1]/N_sqdeg,         	$ ; total LIKE QSOs p.s.d
      				n_obs[2]/N_sqdeg, 	         	$ ; total NN targets p.s.d
      				total_val[2]/N_sqdeg,         	$ ; total NN QSOs p.s.d
				current[0],		$ ; value of KDE
				current[1],		$ ; value of NN
				current[2],		$ ; value of LIKE
				total(total_qso)/totcount	; efficiency

				;write fiber densities based off the spectroscopic area to file
				printf,30,format='(8(F5.2,2x),3(F9.5,2x),F5.3)', 	$
				totcount/N_sqdeg, 	         	$ ; total targets per. sq. deg.
				total(total_val)/N_sqdeg,    	$ ; total QSOs per sq. deg.
      				n_obs[0]/N_sqdeg, 	          	$ ; total KDE targets p.s.d
      				total_val[0]/N_sqdeg,         	$ ; total KDE QSOs p.s.d
      				n_obs[1]/N_sqdeg, 	          	$ ; total LIKE targets p.s.d
      				total_val[1]/N_sqdeg,         	$ ; total LIKE QSOs p.s.d
      				n_obs[2]/N_sqdeg, 	         	$ ; total NN targets p.s.d
      				total_val[2]/N_sqdeg,         	$ ; total NN QSOs p.s.d
				current[0],		$ ; value of KDE
				current[1],		$ ; value of NN
				current[2],		$ ; value of LIKE
				total(total_qso)/totcount	; efficiency

				;write fiber densities based on the full target area to file
				printf,40,format='(8(F5.2,2x),3(F9.5,2x),F5.3)', 	$
				totcount/realarea, 	         	$ ; total targets per. sq. deg.
				total(total_val)/realarea,    	$ ; total QSOs per sq. deg.
      				n_obs[0]/realarea, 	          	$ ; total KDE targets p.s.d
      				total_val[0]/realarea,         	$ ; total KDE QSOs p.s.d
      				n_obs[1]/realarea, 	          	$ ; total LIKE targets p.s.d
      				total_val[1]/realarea,         	$ ; total LIKE QSOs p.s.d
      				n_obs[2]/realarea, 	         	$ ; total NN targets p.s.d
      				total_val[2]/realarea,         	$ ; total NN QSOs p.s.d
				current[0],		$ ; value of KDE
				current[1],		$ ; value of NN
				current[2],		$ ; value of LIKE
				total(total_qso)/totcount	; efficiency

	      		endif
		endif 

        		x[mind] = x[mind]+1L  ; advancing to the next index down the list

      	endfor         

	; ADM if there has been a change in state in the fibers, we'll update the f-matrix
      	totfib = n_obs[0]+n_obs[1]+n_obs[2]
      	if totfib gt totfibnow then begin 	
		f[track,*] = [n_obs[0],n_obs[1],n_obs[2],fix(total(total_qso))]
		totfibnow = n_obs[0]+n_obs[1]+n_obs[2] ; the new state of the f-matrix
          		track += 1
     	endif

	endwhile

	close,10
	close,20
	close,30
	close,40

	print,'Total number of quasars acquired by each method: ',	$
		total_qso[0], total_qso[1], total_qso[2]
	print,'Total value of quasars acquired by each method: ',	$
		total_val[0], total_val[1], total_val[2]

	flength = n_elements(where(total(f,2)) gt 0) 
	; ADM these are the non-zero entries in the f-matrix where
	; meaningful changes of state occured

	; write out the f-matrix
	close,10
	openw,10,file_f
	for i=0, flength-1 do begin
          		printf,10,format='(I,I,I,I,I,E19.5)', f[i,0],f[i,1],f[i,2],	$
				f[i,0]+f[i,1]+f[i,2],f[i,3], f[i,3]/(f[i,0]+f[i,1]+f[i,2])
	endfor
	close,10

	;ADM now let's assume that we give each method 40 or 60 fibs per sq. deg. and
	; see how well they do

	print, 'THESE numbers are based off spectroscopic area (slight overestimates)!!!'
	test_each_method, testfile, bq, total_area, N_sqdeg
	
	splog, 'took', systime(1)-tm0, ' secs'

END
