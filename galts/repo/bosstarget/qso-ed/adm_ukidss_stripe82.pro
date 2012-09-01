PRO ADM_UKIDSS_STRIPE82, outfile

sdss= mrdfits('$BOVYQSOEDDATA/star82-varcat-bound-ts.fits',1)
ukidss= mrdfits('$BOVYQSOEDDATA/stripe82_varcat_join_ukidss_dr8_20101027a.fits',1)
sdss.psfflux= sdss.psfflux_clean
sdss.psfflux_ivar= sdss.psfflux_clean_ivar
comb= add_data(sdss,ukidssdata=ukidss)

out= qsoed_calculate_prob(comb,/ukidss)

dummy= {run:0L,rerun:"",camcol:0L,field:0L,id:0L}
new= struct_combine(out,replicate(dummy,n_elements(sdss.ra)))
new.run= sdss.run
new.rerun= sdss.rerun
new.camcol= sdss.camcol
new.field= sdss.field
new.id= sdss.id

mwrfits, new, outfile, /create
END
