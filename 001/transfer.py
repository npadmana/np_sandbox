from ROOTpy import *
twopi2 = 2.0*pi**2



def readTransfer(fn):
  """ Read in a transfer function """
  a = loadtxt(fn)
  out = {}
  out['kh'] = a[:,0]
  out['cdm'] = a[:,1]
  out['b'] = a[:,2]

  return out

def primPower(k, ns, As, k0=0.05):
  return As * (k/k0)**(ns-1)

def power(transfer, ns=1.0, As=2.1e-9, h=0.7, pktype='cdm'):
  kh = transfer['kh'] + 0.0
  k = h*kh
  pp = primPower(k, ns, As)
  pk = twopi2 * h**3 * k * pp * transfer[pktype]**2
  return (kh, pk)

def p2xi(kh, pk):
  kclip = clip(kh*1.0, 0.0, 5.0)
  d2 = kh**3 * pk/twopi2 * exp(-kclip**2)
  rr, xi = cosmo.special.delta2_to_xi(kh, d2)
  ww = nonzero(rr < 250.0)
  return (rr[ww], xi[ww])


