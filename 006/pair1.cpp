#include <iostream>
#include <vector>
#include <cmath>
#include <numeric>
#include "mkl_vsl.h"
#include "mkl_lapack.h"

const int Nstart = 1000;
const int Ntimes = 7;
const int Nhist = 1000;

using namespace std;

// Define a particle storage class
struct Particles {
  vector<float> x, y, z;
  int N;
};


void makeRandomParticles(VSLStreamStatePtr &stream, int N, Particles &p) {
  // Set number of particles
  p.N = N;

  // Resize the vectors
  p.x.resize(N);
  p.y.resize(N);
  p.z.resize(N);

  // Fill in the vectors
  vsRngUniform(VSL_RNG_METHOD_UNIFORM_STD, stream, N, &p.x[0], 0.0, 1.0);
  vsRngUniform(VSL_RNG_METHOD_UNIFORM_STD, stream, N, &p.y[0], 0.0, 1.0);
  vsRngUniform(VSL_RNG_METHOD_UNIFORM_STD, stream, N, &p.z[0], 0.0, 1.0);

};


double sum(const vector<float> &v, int N) {
  float tot=0.0;
  for (int i=0; i < N; ++i) tot+=v[i];
  return tot/N;
}

void test_particle(const Particles &p) {
  cout << sum(p.x, p.N) 
       << " " << sum(p.y, p.N) 
       << " " << sum(p.z, p.N) << endl;
}


void cpu_paircount(const Particles &p1, const Particles &p2, vector<double>& hist) {
  float x1, y1, z1, dx, dy, dz, dr;
  int idr;
  for (int ii =0; ii < p1.N; ++ii) {
    x1 = p1.x[ii]; y1 = p1.y[ii]; z1 = p1.z[ii];
    for (int jj=0; jj < p2.N; ++jj) {
      dx = p2.x[jj]-x1;
      dy = p2.y[jj]-y1;
      dz = p2.z[jj]-z1;
      dr = sqrt(dx*dx + dy*dy + dz*dz);

      idr = min(Nhist-1, static_cast<int>(dr*Nhist));
      hist[idr]++;
    }
  }
}

void cpu_paircount_v1(const Particles &p1, const Particles &p2, vector<double>& hist) {
  float x1, y1, z1, dx, dy, dz, dr;
  int idr;
  for (int ii =0; ii < p1.N; ++ii) {
    x1 = p1.x[ii]; y1 = p1.y[ii]; z1 = p1.z[ii];
    for (int jj=0; jj < p2.N; ++jj) {
      dx = p2.x[jj]-x1;
      dy = p2.y[jj]-y1;
      dz = p2.z[jj]-z1;
      dr = sqrt(dx*dx + dy*dy + dz*dz);

      idr = int(dr);
      if (idr >= Nhist) idr = Nhist;
      hist[idr]++;
    }
  }
}

void cpu_paircount_v2(const Particles &p1, const Particles &p2, vector<double>& hist) {
  float x1, y1, z1, dx, dy, dz;
  const int nblock=10;
  float dr[nblock];
  int idr;
  for (int ii =0; ii < p1.N; ++ii) {
    x1 = p1.x[ii]; y1 = p1.y[ii]; z1 = p1.z[ii];
    for (int jj=0; jj < p2.N/nblock; ++jj) { 
     for (int kk=0; kk < nblock; ++kk) {
      dx = p2.x[jj*nblock+kk]-x1;
      dy = p2.y[jj*nblock+kk]-y1;
      dz = p2.z[jj*nblock+kk]-z1;
      dr[kk] = sqrt(dx*dx + dy*dy + dz*dz);
     }
    

     for (int kk=0; kk < nblock; ++kk) {
       idr = int(dr[kk]);
       if (idr >= Nhist) idr = Nhist;
       hist[idr]++;
     }


    }
  }
}

double cpu_harness(int N, VSLStreamStatePtr &stream) {
  Particles p1,p2;
  double t0, dt, dr_av, nd;

  vector<double> hist(Nhist);

  cout << "Starting harness with N=" << N << endl;

  // Initialize
  t0 = dsecnd();
  makeRandomParticles(stream, N, p1);
  makeRandomParticles(stream, N, p2);
  dt = dsecnd() - t0;
  cout << "  Time to initialize: " << dt << endl;

  t0 = dsecnd();
  cpu_paircount_v2(p1, p2, hist);
  dt = dsecnd() - t0;  
  dr_av = accumulate(hist.begin(), hist.end(), 0.0);
  cout << "  Time to count pairs: " << dt << endl;
  nd = static_cast<double>(N);
  cout << "  " << dr_av << " " <<  dr_av-(nd*nd) << endl;


  return dt;
}


int main() {
  double timing[Ntimes];
  int i, N1;
  VSLStreamStatePtr stream;

  // Initialize the random number generator
  vslNewStream( &stream, VSL_BRNG_MT19937, 777 );

  cout << "Pair counting timing code...." << endl;


  for (i=0, N1=Nstart; i < Ntimes; ++i, N1*=2) {
    timing[i] = cpu_harness(N1, stream);
  }

  // Clean up the random number generator
  vslDeleteStream(&stream);
}

