pro make_comm2dr8

    nper=2
	bt=obj_new('bosstarget')
	bt->split_runlist, runptrs, rerunptrs, nper=nper, /force, $
		runs=runs
	njobs = n_elements(runptrs)
	ptr_free, runptrs, rerunptrs

    ; the boss_target kludge because we had hard drive failures
    setups=['setup tree dr8',$
            'setup bosstarget v1_1_2', $
            'setup photoop v1_9_4',$
            'setup idlutils v5_4_9',$
            'export BOSS_TARGET=/clusterfs/riemann/raid008/bosswork/groups/boss/target', $
            'export PHOTO_SWEEP=$PHOTO_SWEEP_BASE/dr8_final',$
            'export PHOTO_RESOLVE=$PHOTO_RESOLVE_BASE/2010-05-23',$
            'export PHOTO_CALIB=$PHOTO_CALIB_BASE/dr8_final', $
            'setup tree dr8']

    exec='/clusterfs/riemann/software/itt/idl70/bin/idl'
    run='comm2dr8'
    pbsdir = '/home/esheldon/pbs/lrg/'+run
    file_mkdir, pbsdir

    for job=0L, njobs-1 do begin

        jstr = string(job,f='(i0)')
        jstrpad = string(job,f='(i03)')

        jobname = 'lrg-'+jstrpad
        
        pbsfile = 'lrg-'+run+'-target-gather-'+jstrpad+'.pbs'
        pbsfile = filepath(root=pbsdir, pbsfile)

        commands=['bt=obj_new("bosstarget")', $
                  'bt->process_partial_runs, "lrg", "'+run+'", '+jstr+', nper=2, /commissioning', $
                  'bt->gather_partial, "lrg", "'+run+'", '+jstr+', nper=2, /commissioning']

        pbs_riemann_idl, pbsfile, commands, job_name=jobname, setup=setups, exec=exec
    endfor
end
