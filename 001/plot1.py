from matplotlib.backends.backend_pdf import PdfPages
from transfer import *
import gsl

def plotxi(fn, norm=True, cross=False):
  tt = readTransfer(fn)
  r, xi1 = p2xi(*(power(tt, pktype='cdm')))
  r, xi2 = p2xi(*(power(tt, pktype='b')))
  r, xi3 = p2xi(*(power(tt, pktype='b', pktype2='cdm')))
  if norm :
    xinorm = 2500.0*gsl.Spline(r, xi1)(50.0)
  else :
    xinorm = 1

  plt.clf()
  plt.plot(r, r**2*xi1/xinorm, 'r-', label='CDM')
  plt.plot(r, r**2*xi2/xinorm, 'b--', label='Baryons')
  if cross :
    plt.plot(r, r**2*xi3/xinorm, 'g:', label='Cross')
  plt.xlim(10,175)
  if norm :
    plt.ylim(0,1.5)
  plt.legend()


def p1():
  pdf = PdfPages('cdm_bary.pdf')
  for ii,zz in zip([2,3,4,5], [5.0,2.0,1.0,0.0]):
    plotxi('test_transfer_%1i.dat'%ii)
    plt.title('z=%3.1f'%zz)
    pdf.savefig()
  pdf.close()

def p2():
  pdf = PdfPages('cdm_bary_hiz.pdf')
  for ii,zz in zip([1,2,3,4,5], [200.0,100.0,50.0,25.0,10]):
    plotxi('hiz_transfer_%1i.dat'%ii, norm=False, cross=True)
    plt.title('z=%3.1f'%zz)
    pdf.savefig()
  pdf.close()

if __name__=="__main__":
  #p1()
  p2()
