from matplotlib.backends.backend_pdf import PdfPages
from transfer import *
import gsl

def plotxi(fn):
  tt = readTransfer(fn)
  r, xi1 = p2xi(*(power(tt, pktype='cdm')))
  r, xi2 = p2xi(*(power(tt, pktype='b')))
  xinorm = 2500.0*gsl.Spline(r, xi1)(50.0)


  plt.clf()
  plt.plot(r, r**2*xi1/xinorm, 'r-', label='CDM')
  plt.plot(r, r**2*xi2/xinorm, 'b--', label='Baryons')
  plt.xlim(50,175)
  plt.ylim(0,1.5)
  plt.legend()


if __name__=="__main__":
  pdf = PdfPages('cdm_bary.pdf')
  for ii,zz in zip([2,3,4,5], [5.0,2.0,1.0,0.0]):
    plotxi('test_transfer_%1i.dat'%ii)
    plt.title('z=%3.1f'%zz)
    pdf.savefig()
  pdf.close()
