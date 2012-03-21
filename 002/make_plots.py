import scipy.ndimage as nd
import pyfits
from numpy import *
from pylab import *

# Read in the file
def readspt(fn='spt.fits'):
  """ Assumes the SPT data from the first year """
  ff = pyfits.open(fn)
  arr = ff[0].data
  ff.close
  # Trim the array
  arr = arr[500:2500, 500:2500]
  return arr


def try_smooth(arr, rr, clip=1.e-5):
  tmp = nd.gaussian_filter(arr, rr)
  clf()
  imshow(tmp, cm.jet, origin='lower', vmin=-clip, vmax=clip)
  colorbar()

def plot1(arr):
  tmp = nd.gaussian_filter(arr, 5.0)
  tmp = tmp[800:1600, 1000:1800]
  #tmp1 = nd.zoom(tmp, 10, order=3)
  #tmp1 = nd.gaussian_filter(tmp1, 1.0)
  clf()
  im = imshow(tmp, cm.jet, origin='lower', vmin=-1.e-4, vmax=1.e-4)
  ax = im.get_axes()
  ax.xaxis.set_visible(False)
  ax.yaxis.set_visible(False)
  show()
  savefig('plot1.png', dpi=500)



