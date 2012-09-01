; Batch all stripe 82 co-adds from RA=[-45,45]
pro likelihood_stripe82_batch1, ra_min, ra_max, infile

   batchfile = 'batch-'+string(ra_min,format='(i3.3)')+'-' $
    +string(ra_max,format='(i3.3)')

   get_lun, loglun
   openw, loglun, batchfile
   printf, loglun, '#PBS -l nodes=1'
   printf, loglun, '#PBS -l walltime=20:00:00'
   printf, loglun, '#PBS -V'
   printf, loglun, 'cd $PBS_O_WORKDIR'
   fq = '"'
   printf, loglun, "echo 'likelihood_stripe82,"+strtrim(ra_min,2)+","+strtrim(ra_max,2)+","+fq+infile+fq+"' | idl"

   close, loglun
   free_lun, loglun

   spawn, 'qsub '+batchfile

   return
end

pro likelihood_stripe82_batch

   infile = 'varcat-ra300-330.fits.gz'
   for ra_min=315, 329, 1 do $
    likelihood_stripe82_batch1, ra_min, ra_min+1, infile

   infile = 'varcat-ra330-360.fits.gz'
   for ra_min=330, 359, 1 do $
    likelihood_stripe82_batch1, ra_min, ra_min+1, infile

   infile = 'varcat-ra0-30.fits.gz'
   for ra_min=0, 29, 1 do $
    likelihood_stripe82_batch1, ra_min, ra_min+1, infile

   infile = 'varcat-ra30-60.fits.gz'
   for ra_min=30, 44, 1 do $
    likelihood_stripe82_batch1, ra_min, ra_min+1, infile

   return
end
