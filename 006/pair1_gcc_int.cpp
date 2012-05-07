#include <iostream>
#include <vector>
#include <cmath>
#include <ctime>
#include <numeric>

const int Nstart = 1000;
const int Ntimes = 6;
const int Nhist = 1000;


using namespace std;

// Define a particle storage class
struct Particles {
  vector<float> x, y, z;
  int N;
};


void makeRandomParticles(int N, Particles &p) {
  // Set number of particles
  p.N = N;

  // Resize the vectors
  p.x.resize(N);
  p.y.resize(N);
  p.z.resize(N);

  // Fill in the vectors
  for (int ii=0; ii < N; ++ii) {
    p.x[ii] = float(rand())/float(RAND_MAX);
    p.y[ii] = float(rand())/float(RAND_MAX);
    p.z[ii] = float(rand())/float(RAND_MAX);
  }

};


void cpu_paircount_v2(const Particles &p1, const Particles &p2, vector<int>& hist) {
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

double cpu_harness(int N) {
  Particles p1,p2;
  clock_t t0;
  double dt;
  int dr_av;


  cout << "Starting harness with N=" << N << endl;

  // Initialize
  t0 = clock();
  makeRandomParticles(N, p1);
  makeRandomParticles(N, p2);
  dt = difftime(clock(), t0)/double(CLOCKS_PER_SEC);
  cout << "  Time to initialize: " << dt << endl;

  {
    vector<int> hist(Nhist,0);
    t0 = clock();
    cpu_paircount_v2(p1, p2, hist);
    dt = difftime(clock(), t0)/double(CLOCKS_PER_SEC);
    dr_av = accumulate(hist.begin(), hist.end(), 0);
    cout << "  Time to count pairs v2: " << dt << endl;
    cout << "  " << dr_av << " " <<  dr_av-(N*N) << endl;
  }


  return dt;
}


int main() {
  double timing[Ntimes];
  int i, N1;

  cout << "Pair counting timing code...." << endl;


  for (i=0, N1=Nstart; i < Ntimes; ++i, N1*=2) {
    timing[i] = cpu_harness(N1);
  }

}

