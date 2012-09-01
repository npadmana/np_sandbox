import sys
import os, os.path
import shutil
import subprocess
import math as m
import numpy as nu
from optparse import OptionParser
import time
_MAKE= 'make'
_DEFAULTSAVEDIR= '../../data/qso-ed/fits/'
_DEFAULTPLOTDIR= os.path.join(os.getenv('HOME'),'sdss_qsos/out/plot/')
_DEFAULTTEXDIR= os.path.join(os.getenv('HOME'),'sdss_qsos/out/tex/')
_DEFAULTILOW= 17.7
_DEFAULTIHIGH= 22.5
_DEFAULTBINWIDTH= 0.2
_DEFAULTBINSTEP= 0.1
_DEFAULTNGAUSS= 20
_DEFAULTPANELWIDTH= 0.32
def deconvolve(parser):
    """
    NAME:
       deconvolve_all
    PURPOSE:
       main program that deconvolves the distribution of all point-sources
    INPUT:
       parser - from optparse
    OUTPUT:
       just generates a lot of plots in various directories
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    (options,args)= parser.parse_args()
    nbins= int(round((options.ihigh-options.ilow)/options.binstep-1))
    ilows= [options.ilow+ii*options.binstep for ii in range(nbins)]
    ihighs= [options.ilow+ii*options.binstep+options.binwidth for ii in range(nbins)]
    for ilow, ihigh in zip(ilows,ihighs):
        deconvolve_bin(ilow,ihigh,options,args)
    if options.noplots:
        return
    #Now write the final tex-file and tex it
    print "Writing final tex-file for the fluxes"
    write_tex(ilows,ihighs,options,args)
    print "Resampling the colors ..."
    for ilow, ihigh in zip(ilows,ihighs):
        plot_deconvolve_colors_all_bin(ilow,ihigh,options,args)
    print "Writing final tex-file for the colors"
    write_tex(ilows,ihighs,options,args,colors=True)
    print "All done"
    
def write_tex(ilows,ihighs,options,args,colors=False):
    """
    NAME:
        write_tex
    PURPOSE:
        write the final tex file
    INPUT:
       ilows, ihighs - bin-edges
       options,args from optparser
       colors - if True, write a file with color-color plots
    OUTPUT:
       writes the tex file
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    if options.qso:
        if options.lowz:
            sampleStr= '_qso_lowz_'
            basefilename= 'qso_lowz_'
        elif options.bossz:
            sampleStr= '_qso_bossz_'
            basefilename= 'qso_bossz_'
        elif options.allqso:
            sampleStr= '_qso_allz_'
            basefilename= 'qso_allz_'
        else:
            sampleStr= '_qso_'
            basefilename= 'qso_'
    else:
        sampleStr= '_all_'
        basefilename= 'dc_'
    if options.galex:
        basefilename+= 'galex_'
    if options.ukidss:
        basefilename+= 'ukidss_'
    if options.z4:
        basefilename+= 'z4_'
    if options.fitz:
        basefilename+= 'fitz_'
    if options.point9:
        basefilename+= 'point9_'
    if colors:
        basefilename+= "colordist_%4.1f_%4.1f_%3.1f_%3.1f_%i_" % (options.ilow,options.ihigh,options.binwidth,options.binstep,options.ngauss) + time.strftime("%Y_%m_%d",time.localtime())
    else:
        basefilename+= "fluxdist_%4.1f_%4.1f_%3.1f_%3.1f_%i_" % (options.ilow,options.ihigh,options.binwidth,options.binstep,options.ngauss) + time.strftime("%Y_%m_%d",time.localtime())
    texfilename= basefilename+".tex"
    pdffilename= basefilename+".pdf"
    texfile= open(os.path.join(options.texdir,texfilename),'w')

    texfile.write(r"\documentclass{article}"+"\n")
    texfile.write(r"\oddsidemargin 0in"+"\n")
    texfile.write(r"\evensidemargin 0in"+"\n")
    texfile.write(r"\textwidth 6.5in"+"\n")
    texfile.write(r"\headheight 0in"+"\n")
    texfile.write(r"\topmargin 0.4in"+"\n")
    texfile.write(r"\textheight 8.5in"+"\n")
    texfile.write(r"\usepackage{graphicx}"+"\n")
    texfile.write(r"\begin{document}"+"\n")

    for ilow, ihigh in zip(ilows,ihighs):
        magbinstr= '%4.1f_i_%4.1f' % (ilow,ihigh)
        magbinngaussstr= magbinstr+'_%i' % options.ngauss
        if options.galex:
            magbinngaussstr+= '_galex'
        if options.ukidss:
            magbinngaussstr+= '_ukidss'
        if options.z4:
            magbinngaussstr+= '_z4'
        if options.fitz:
            magbinngaussstr+= '_fitz'
        if options.point9:
            magbinngaussstr+= '_point9'
        if colors:
            bintexfilename= 'dc_color'+sampleStr+magbinngaussstr
        else:
            bintexfilename= 'dc_flux'+sampleStr+magbinngaussstr         
        texfile.write(r"\include{"+bintexfilename+"}\n")
    
    texfile.write(r"\end{document}"+"\n")
    texfile.close()

    print "Latexing it"
    shutil.copy('makefile.tex',options.texdir)
    pwd= os.getcwd()
    os.chdir(options.texdir)
    #Run make
    try:
        subprocess.call([_MAKE,'-f',
                         'makefile.tex',
                         pdffilename])
    except:
        print _MAKE+" "+pdffilename+" failed ..."
        raise
    os.remove('makefile.tex')
    os.chdir(pwd)
    
def plot_deconvolve_colors_all_bin(ilow,ihigh,options,args):
    """
    NAME:
       plot_deconvolve_colors_all_bin
    PURPOSE:
       plot the colors in a bin
    INPUT:
       ilow - lower bound of the bin
       ihigh - upper bound of the bin
       options, args - from optparse
    OUTPUT:
       writes files
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    if options.galex:
        galexstr= 'galex_'
        galexMakeOption= '1'
    else:
        galexstr= ''
        galexMakeOption= '0'
    if options.ukidss:
        ukidssstr= 'ukidss_'
        ukidssMakeOption= '1'
    else:
        ukidssstr= ''
        ukidssMakeOption= '0'
    if options.z4:
        z4str= 'z4_'
        z4MakeOption= '1'
    else:
        z4str= ''
        z4MakeOption= '0'
    if options.fitz:
        zstr= 'z_'
        zMakeOption= '1'
    else:
        zstr= ''
        zMakeOption= '0'
    if options.point9:
        point9str= 'point9_'
        point9MakeOption= '1'
    else:
        point9str= ''
        point9MakeOption= '0'
    if options.qso:
        makeSuffix='qso'
        if options.lowz:
            filename= os.path.join(options.plotdir,"dc_qso_lowz_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"gr_ug.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_lowz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        elif options.bossz:
            filename= os.path.join(options.plotdir,"dc_qso_bossz_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"gr_ug.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_bossz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        elif options.allqso:
            filename= os.path.join(options.plotdir,"dc_qso_allz_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"gr_ug.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_allz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        else:
            filename= os.path.join(options.plotdir,"dc_qso_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"gr_ug.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
    else:
        makeSuffix='coadd'
        filename= os.path.join(options.plotdir,"dc_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"gr_ug.ps")
        datafilename= os.path.join(options.plotdir,"coadd_data_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
    #Run make
    try:
        subprocess.call([_MAKE,filename,'-f','makefile.'+makeSuffix,
                         'TEXDIR='+options.texdir,
                         'PLOTDIR='+options.plotdir,
                         'SAVEDIR='+options.savedir,
                         'GALEX='+galexMakeOption,
                         'ZFOUR='+z4MakeOption,
                         'FITZ='+zMakeOption,
                         'POINT9='+point9MakeOption,
                         'UKIDSS='+ukidssMakeOption])
    except:
        print _MAKE+" "+filename+" failed ..."
        raise
    #Run make
    try:
        subprocess.call([_MAKE,datafilename,'-f','makefile.'+makeSuffix,
                         'TEXDIR='+options.texdir,
                         'PLOTDIR='+options.plotdir,
                         'SAVEDIR='+options.savedir,
                         'GALEX='+galexMakeOption,
                         'ZFOUR='+z4MakeOption,
                         'FITZ='+zMakeOption,
                         'UKIDSS='+ukidssMakeOption])
    except:
        print _MAKE+" "+coaddfilename+" failed ..."
        raise
    print "Writing tex-files for this bin ..."
    write_tex_bin(ilow,ihigh,options,args,colors=True)
    print "Preparing figures for the tex-file ..."
    prepare_figures_bin(ilow,ihigh,options,args,colors=True)

def deconvolve_bin(ilow,ihigh,options,args):
    """
    NAME:
       deconvolve_bin
    PURPOSE:
       deconvolve sources in a bin in i-band magnitude
    INPUT:
       ilow - lower bound of the bin
       ihigh - upper bound of the bin
       options, args - from optparse
    OUTPUT:
       writes files
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    resampleOption= '1'
    excludes82Option= '0'
    if options.galex:
        galexstr= 'galex_'
        galexMakeOption= '1'
    else:
        galexstr= ''
        galexMakeOption= '0'
    if options.ukidss:
        ukidssstr= 'ukidss_'
        ukidssMakeOption= '1'
    else:
        ukidssstr= ''
        ukidssMakeOption= '0'
    if options.z4:
        z4str= 'z4_'
        z4MakeOption= '1'
    else:
        z4str= ''
        z4MakeOption= '0'
    if options.fitz:
        zstr= 'z_'
        zMakeOption= '1'
    else:
        zstr= ''
        zMakeOption= '0'
    if options.point9:
        point9str= 'point9_'
        point9MakeOption= '1'
    else:
        point9str= ''
        point9MakeOption= '0'
    if options.qso:
        makeSuffix='qso'
        if options.lowz:
            filename= os.path.join(options.plotdir,"dc_qso_lowz_fluxdist_%4.1f_i_%4.1f_%i_"% (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_lowz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        elif options.bossz:
            filename= os.path.join(options.plotdir,"dc_qso_bossz_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_bossz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        elif options.allqso:
            filename= os.path.join(options.plotdir,"dc_qso_allz_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_allz_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        else:
            filename= os.path.join(options.plotdir,"dc_qso_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"qso_data_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
    else:
        if options.full:
            makeSuffix='full'
            filename= os.path.join(options.plotdir,"dc_full_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"full_data_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
        else:
            makeSuffix='coadd'
            filename= os.path.join(options.plotdir,"dc_fluxdist_%4.1f_i_%4.1f_%i_" % (ilow, ihigh, options.ngauss)+galexstr+ukidssstr+z4str+zstr+point9str+"g_u.ps")
            datafilename= os.path.join(options.plotdir,"coadd_data_%4.1f_i_%4.1f_g_u.ps" % (ilow, ihigh))
    if options.noplots:
        resampleOption= '0'
    if options.excludes82:
        excludes82Option= '1'
    #Run make
    try:
        subprocess.call([_MAKE,filename,'-f','makefile.'+makeSuffix,
                         'TEXDIR='+options.texdir,
                         'PLOTDIR='+options.plotdir,
                         'SAVEDIR='+options.savedir,
                         'GALEX='+galexMakeOption,
                         'ZFOUR='+z4MakeOption,
                         'FITZ='+zMakeOption,
                         'EXCLUDES82='+excludes82Option,
                         'POINT9='+point9MakeOption,
                         'RESAMPLE='+resampleOption,
                         'UKIDSS='+ukidssMakeOption])
    except:
        print _MAKE+" "+filename+" failed ..."
        raise
    if options.noplots:
        return
    #Run make
    try:
        subprocess.call([_MAKE,datafilename,'-f','makefile.'+makeSuffix,
                         'TEXDIR='+options.texdir,
                         'PLOTDIR='+options.plotdir,
                         'SAVEDIR='+options.savedir,
                         'GALEX='+galexMakeOption,
                         'ZFOUR='+z4MakeOption,
                         'FITZ='+zMakeOption,
                         'RESAMPLE='+resampleOption,
                         'UKIDSS='+ukidssMakeOption])
    except:
        print _MAKE+" "+datafilename+" failed ..."
        raise
    if options.noplots:
        return
    print "Writing tex-files for this bin ..."
    write_tex_bin(ilow,ihigh,options,args)
    print "Preparing figures for the tex-file ..."
    prepare_figures_bin(ilow,ihigh,options,args)

def prepare_figures_bin(ilow,ihigh,options,args,colors=False):
    """
    NAME:
       prepare_figures_bin
    PURPOSE:
       convert the .ps figures output by idl to better cut .eps figures
    INPUT:
       ilow - lower bound of the bin
       ihigh - upper bound of the bin
       options, args - from optparse
       colors - prepare the colors-figures
    OUTPUT:
       .eps version of .ps figures in the options.plotdir
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    if colors:
        fluxstrs= ['gr_ug','ri_gr','iz_ri']
        if options.galex:
            fluxstrs.append('ug_nu')
            fluxstrs.append('nu_fn')       
    else:
        fluxstrs= ['g_u','r_g','z_r']
        if options.galex:
            fluxstrs.append('nuv_r')
            fluxstrs.append('fuv_r')
    magbinstr= '%4.1f_i_%4.1f_' % (ilow,ihigh)
    magbinngaussstr= magbinstr+'%i_' % options.ngauss
    if options.galex:
        magbinngaussstr+= 'galex_'
    if options.ukidss:
        magbinngaussstr+= 'ukidss_'
    if options.z4:
        magbinngaussstr+= 'z4_'
    if options.fitz:
        magbinngaussstr+= 'fitz_'
    if options.point9:
        magbinngaussstr+= 'point9_'
    if options.qso:
        makeSuffix='qso'
        if options.lowz:
            baseplotstrs= ['dc_qso_lowz_fluxdist_','dc_qso_lowz_fluxdist_resample_','qso_data_lowz_']
        elif options.bossz:
            baseplotstrs= ['dc_qso_bossz_fluxdist_','dc_qso_bossz_fluxdist_resample_','qso_data_bossz_']
        elif options.allqso:
            baseplotstrs= ['dc_qso_allz_fluxdist_','dc_qso_allz_fluxdist_resample_','qso_data_allz_']
        else:
            baseplotstrs= ['dc_qso_fluxdist_','dc_qso_fluxdist_resample_','qso_data_']
    else:
        makeSuffix='coadd'
        baseplotstrs= ['dc_fluxdist_','dc_fluxdist_resample_','coadd_data_']
    for fluxstr in fluxstrs:
        plotstrs= [baseplotstrs[0]+magbinngaussstr,baseplotstrs[1]+magbinngaussstr,baseplotstrs[2]+magbinstr]
        for plotstr in plotstrs:
            epsfilename= os.path.abspath(os.path.join(options.plotdir,plotstr+fluxstr+'.eps'))
            #Run make
            try:
                subprocess.call([_MAKE,epsfilename,
                                 '-f','makefile.'+makeSuffix])
            except:
                print _MAKE+" "+epsfilename+" failed ..."
                raise
        
def write_tex_bin(ilow,ihigh,options,args,colors=False):
    """
    NAME:
       write_tex_bin
    PURPOSE:
       write the tex page corresponding to this bin
    INPUT:
       ilow - lower bound of the bin
       ihigh - upper bound of the bin
       options, args - from optparse
       colors if True, write a file for color-plots
    OUTPUT:
       part of tex file in options.texdir
    HISTORY:
       2010-04-08 - Written - Bovy (NYU)
    """
    if options.galex:
        galexstr= '_galex'
    else:
        galexstr= ''
    if options.ukidss:
        ukidssstr= '_ukidss'
    else:
        ukidssstr= ''
    if options.z4:
        z4str= '_z4'
    else:
        z4str= ''
    if options.fitz:
        zstr= '_fitz'
    else:
        zstr= ''
    if options.point9:
        point9str= '_point9'
    else:
        point9str= ''
    magbinstr= '%4.1f_i_%4.1f' % (ilow,ihigh)
    magbinngaussstr= magbinstr+'_%i' % options.ngauss
    if options.qso:
        captionStr2= 'QSO'
        if options.lowz:
            texPrefix= 'qso_lowz_'
            captionStr= 'QSO ($z < 2.2$)'
            dataStr= 'qso_data_lowz_'
            baseStr= 'dc_qso_lowz_fluxdist_'
            sampleStr= '_qso_lowz_'
        elif options.bossz:
            texPrefix= 'qso_bossz_'
            captionStr= 'QSO ($2.2 \leq z \leq 3.5$)'
            dataStr= 'qso_data_bossz_'
            baseStr= 'dc_qso_bossz_fluxdist_'
            sampleStr= '_qso_bossz_'
        elif options.allqso:
            texPrefix= 'qso_allz_'
            captionStr= 'QSO'
            dataStr= 'qso_data_allz_'
            baseStr= 'dc_qso_allz_fluxdist_'
            sampleStr= '_qso_allz_'
        else:
            texPrefix= 'qso_'
            captionStr= 'QSO ($z > 3.5$)'
            dataStr= 'qso_data_'
            baseStr= 'dc_qso_fluxdist_'
            sampleStr= '_qso_'
    else:
        texPrefix= 'dc_'
        captionStr= "``everything''"
        captionStr2= 'co-added'
        dataStr= 'coadd_data_'
        baseStr= 'dc_fluxdist_'
        sampleStr= '_all_'
    if colors:
        fluxstrs= ['gr_ug','ri_gr','iz_ri']
        texfilename= os.path.join(options.texdir,'dc_color'+sampleStr+magbinngaussstr+galexstr+ukidssstr+z4str+zstr+point9str+'.tex')
        if options.galex:
            fluxstrs.append('ug_nu')
            fluxstrs.append('nu_fn')
    else:
        fluxstrs= ['g_u','r_g','z_r']
        texfilename= os.path.join(options.texdir,'dc_flux'+sampleStr+magbinngaussstr+galexstr+ukidssstr+z4str+zstr+point9str+'.tex')
        if options.galex:
            fluxstrs.append('nuv_r')
            fluxstrs.append('fuv_r')
    texfile= open(texfilename,'w')
    magbinngaussstr+= "_"
    if options.galex:
        magbinngaussstr+= "galex_"
    if options.ukidss:
        magbinngaussstr+= "ukidss_"
    if options.z4:
        magbinngaussstr+= "z4_"
    if options.fitz:
        magbinngaussstr+= "fitz_"
    if options.point9:
        magbinngaussstr+= "point9_"
    if not ilow == options.ilow:
        texfile.write(r"\clearpage"+"\n")
    widthstr=r"width=%.2f\textwidth" % options.panelwidth
    if sys.version_info < (2, 6):
        plotpath= os.path.abspath(options.plotdir)
    else:
        #This is somewhat nicer
        plotpath= os.path.relpath(options.plotdir,options.texdir)

    texfile.write(r"\begin{figure}"+"\n")
    texfile.write(r"\includegraphics["+widthstr+"]{"+str(os.path.join(plotpath,baseStr+magbinngaussstr+fluxstrs[0]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,baseStr+"resample_"+magbinngaussstr+fluxstrs[0]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,dataStr+magbinstr+"_"+fluxstrs[0]+".eps"))+r"}\\"+"\n")

    texfile.write(r"\includegraphics["+widthstr+"]{"+str(os.path.join(plotpath,baseStr+magbinngaussstr+fluxstrs[1]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,baseStr+"resample_"+magbinngaussstr+fluxstrs[1]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,dataStr+magbinstr+"_"+fluxstrs[1]+".eps"))+r"}\\"+"\n")

    texfile.write(r"\includegraphics["+widthstr+"]{"+str(os.path.join(plotpath,baseStr+magbinngaussstr+fluxstrs[2]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,baseStr+"resample_"+magbinngaussstr+fluxstrs[2]+".eps"))+"}\n")
    texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,dataStr+magbinstr+"_"+fluxstrs[2]+".eps")))
    if options.galex:
        texfile.write(r"}\\"+"\n")
    else:
        texfile.write("}\n")

    if options.galex:
        texfile.write(r"\includegraphics["+widthstr+"]{"+str(os.path.join(plotpath,baseStr+magbinngaussstr+fluxstrs[3]+".eps"))+"}\n")
        texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,baseStr+"resample_"+magbinngaussstr+fluxstrs[3]+".eps"))+"}\n")
        texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,dataStr+magbinstr+"_"+fluxstrs[3]+".eps"))+r"}\\"+"\n")
        
        texfile.write(r"\includegraphics["+widthstr+"]{"+str(os.path.join(plotpath,baseStr+magbinngaussstr+fluxstrs[4]+".eps"))+"}\n")
        texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,baseStr+"resample_"+magbinngaussstr+fluxstrs[4]+".eps"))+"}\n")
        texfile.write(r"\includegraphics["+widthstr+",clip=]{"+str(os.path.join(plotpath,dataStr+magbinstr+"_"+fluxstrs[4]+".eps"))+"}\n")
        
    if colors:
        colorStr= 'Color-color'
    else:
        colorStr= 'Flux-flux'
    texfile.write("\caption{"+colorStr+" diagrams for a bin in $i$-band magnitude from the "+captionStr+" catalog. The first column is a sampling from the extreme-deconvolution fit using %i Gaussians, the second column is a sampling from the extreme-deconvolution fit with the errors from the "% options.ngauss + captionStr2+" data added in, and the third column has the "+captionStr2+" data.}\n")
    texfile.write(r"\end{figure}"+"\n")
    texfile.write("\n")
    texfile.close()
    
def get_options():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("--savedir", dest="savedir",type='string',
                      default=_DEFAULTSAVEDIR,
                      help="Directory to save the output of the deconvolution in")
    parser.add_option("--plotdir", dest="plotdir",type='string',
                      default=_DEFAULTPLOTDIR,
                      help="Directory to save the output-plots in")
    parser.add_option("--texdir", dest="texdir",type='string',
                      default=_DEFAULTTEXDIR,
                      help="Directory to save the diagnostic tex-output in")
    parser.add_option("--ilow", dest="ilow",type='float',
                      default=_DEFAULTILOW,
                      help="lower i-band magnitude")
    parser.add_option("--ihigh", dest="ihigh",type='float',
                      default=_DEFAULTIHIGH,
                      help="upper i-band magnitude")
    parser.add_option("--binwidth", dest="binwidth",type='float',
                      default=_DEFAULTBINWIDTH,
                      help="width of bins in i-band magnitude")
    parser.add_option("--binstep", dest="binstep",type='float',
                      default=_DEFAULTBINSTEP,
                      help="step-size for lower bound of bin in i-band magnitude")
    parser.add_option("-g","--ngauss", dest="ngauss",type='int',
                      default=_DEFAULTNGAUSS,
                      help="Number of Gaussians to fit")
    parser.add_option("--panelwidth", dest="panelwidth",type='float',
                      default=_DEFAULTPANELWIDTH,
                      help="Width of a panel in the tex-figure")
    parser.add_option("-q","--qso",action="store_true", dest="qso",
                      default=False,
                      help="Deconvolve QSO's")
    parser.add_option("--lowz",action="store_true", dest="lowz",
                      default=False,
                      help="Deconvolve low redshift QSO's (default QSO: z>3.5 redshift)")
    parser.add_option("--galex",action="store_true", dest="galex",
                      default=False,
                      help="Add GALEX fluxes")
    parser.add_option("--ukidss",action="store_true", dest="ukidss",
                      default=False,
                      help="Add UKIDSS fluxes")
    parser.add_option("--z4",action="store_true", dest="z4",
                      default=False,
                      help="use z=4 as rhe boundary between bossz and hiz")
    parser.add_option("--bossz",action="store_true", dest="bossz",
                      default=False,
                      help="Deconvolve BOSS-redshift QSO's (default QSO: z>3.5 redshift)")
    parser.add_option("--full",action="store_true", dest="full",
                      default=False,
                      help="Deconvolve 'full' DR8 data set")
    parser.add_option("--excludes82",action="store_true", dest="excludes82",
                      default=False,
                      help="excludes82")
    parser.add_option("--noplots",action="store_true", dest="noplots",
                      default=False,
                      help="Don't make intermediate plots, just deconvolve (only in conjunction with '--full' for now")
    parser.add_option("--allz",action="store_true", dest="allqso",
                      default=False,
                      help="Deconvolve all quasars")
    parser.add_option("-z",action="store_true", dest="fitz",
                      default=False,
                      help="Fit the redshifts as well as the relative fluxes, for photo-zs")
    parser.add_option("--point9",action="store_true", dest="point9",
                      default=False,
                      help="Use 90 percent of the quasars to fit")
    return parser
 

if __name__ == '__main__':
    deconvolve(get_options())
    
