import numpy as np
import mangle
import ROOTpy as R

npoints1 = 1000

ra1 = np.linspace(0.0, 360.0, num=npoints1, endpoint=False)
dec1 = np.linspace(-0.99999, 1.0, num=npoints1, endpoint=False)
dec1 = 90.0-np.arccos(dec1)*180.0/np.pi

ra, dec = np.meshgrid(ra1, dec1)

ra = ra.flatten()
dec = dec.flatten()

foot = mangle.Mangle("boss_survey.ply")

ids = foot.get_polyids(ra, dec)

ra = ra[ids >=0]
dec = dec[ids >=0]

R.forprint("grid.txt", "%20.10e %20.10e\n", "w", ra, dec)

