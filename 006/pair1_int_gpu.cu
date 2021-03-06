#include <iostream>
#include <vector>
#include <cmath>
#include <ctime>
#include <numeric>
#include "book.h"

const int Nstart = 1000;
const int Ntimes = 4;
const int Nhist = 100;


using namespace std;

// Define a particle storage class
struct Particles {
  vector<float> x, y, z;
  int N;
};


struct ParticlesGPU {
  float *x, *y, *z;
};

void AllocCopyGPU(Particles &p, ParticlesGPU &p2) {
  // x
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.x, p.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.x, &p.x[0], p.N * sizeof(float), cudaMemcpyHostToDevice));

  // y
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.y, p.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.y, &p.y[0], p.N * sizeof(float), cudaMemcpyHostToDevice));


  // z
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.z, p.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.z, &p.z[0], p.N * sizeof(float), cudaMemcpyHostToDevice));
}

void FreeGPU(ParticlesGPU &p) {
  cudaFree(p.x);
  cudaFree(p.y);
  cudaFree(p.z);
}


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

// Define the GPU kernel here 
__global__ void paircount_kernel(
    int N1, float *x1, float *y1, float *z1, 
    int N2, float *x2, float *y2, float *z2, 
    int Nh, int *hist) {

  // We distribute p1, but loop through all of p2
  int ii, jj, idr;
  int stride = blockDim.x * gridDim.x;
  float x, y, z, dx, dy, dz, dr;
  ii = threadIdx.x + blockIdx.x * blockDim.x;

  while (ii < N1) {
    x = x1[ii]; y = y1[ii]; z = z1[ii];
    for (jj = 0; jj < N2; ++jj) {
      dx = x2[jj] - x;
      dy = y2[jj] - y;
      dz = z2[jj] - z;
      dr = sqrtf(dx*dx + dy*dy + dz*dz);
      idr = (int) (dr*Nh);
      if (idr < Nh) atomicAdd( &hist[idr], 1);
    }
    ii += stride;
  }

}

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
       idr = (int)(dr[kk]*Nhist);
       if (idr < Nhist) hist[idr]++;
     }


    }
  }
}

double cpu_harness(int N, int blocks) {
  Particles p1,p2;
  ParticlesGPU pg1, pg2;
  clock_t t0;
  double dt;
  float gpu_dt;


  cout << "Starting harness with N=" << N << endl;

  // Initialize
  t0 = clock();
  makeRandomParticles(N, p1);
  makeRandomParticles(N, p2);
  dt = difftime(clock(), t0)/double(CLOCKS_PER_SEC);
  cout << "  Time to initialize: " << dt << endl;

  // Set up GPU timers
  cudaEvent_t     start, stop;
  HANDLE_ERROR( cudaEventCreate( &start ) );
  HANDLE_ERROR( cudaEventCreate( &stop ) );

  // Move data to GPU
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );
  AllocCopyGPU(p1, pg1);
  AllocCopyGPU(p2, pg2);
  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  HANDLE_ERROR( cudaEventElapsedTime( &gpu_dt,
                                      start, stop ) );
  cout << "  Time to move data on to GPU (ms): " << gpu_dt << endl;


  // Set up the gpu_hist
  int *gpu_hist;

  HANDLE_ERROR( cudaMalloc( (void**)&gpu_hist, Nhist*sizeof(int)));
  HANDLE_ERROR( cudaMemset( gpu_hist, 0, Nhist*sizeof(int)));
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );
  paircount_kernel<<<blocks, 512>>>(N, pg1.x, pg1.y, pg1.z, 
      N, pg2.x, pg2.y, pg2.z, Nhist, gpu_hist);
  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  HANDLE_ERROR( cudaEventElapsedTime( &gpu_dt,
                                      start, stop ) );
  cout << "  Time for GPU paircounts (ms): " << gpu_dt << endl;

  // Suck back the histogram array
  vector<int> hist1(Nhist);
  HANDLE_ERROR( cudaMemcpy( &hist1[0], gpu_hist, Nhist*sizeof(int), cudaMemcpyDeviceToHost));


  // Clean up
  cudaFree(gpu_hist);
  FreeGPU(pg1); FreeGPU(pg2);


  // Clean up GPU timers
  HANDLE_ERROR( cudaEventDestroy( start ) );
  HANDLE_ERROR( cudaEventDestroy( stop ) );

  // CPU paircounting
  vector<int> hist(Nhist,0);
  t0 = clock();
  cpu_paircount_v2(p1, p2, hist);
  dt = difftime(clock(), t0)/double(CLOCKS_PER_SEC);
  cout << "  Time to count pairs v2: " << dt << endl;

  //for (int ii = 0; ii < Nhist; ++ii) {
  //  cout << ii << " " << hist[ii] << " "  << hist1[ii] << endl;
  //}

  // Now compare histograms
  int dhist, error = 0; int eval = 0;
  for (int ii =0; ii < Nhist; ++ii) {
    dhist = abs(hist[ii] - hist1[ii]);
    if (dhist > error) {
      error = dhist;
      eval = hist[ii];
    }
  }
  cout << "  Difference in histograms : " << error << " " << eval << endl;

  return dt;
}


int main() {
  double timing[Ntimes];
  int i, N1;

  cout << "Pair counting timing code...." << endl;

  // kernel launch - 2x the number of mps gave best timing
  cudaDeviceProp  prop;
  HANDLE_ERROR( cudaGetDeviceProperties( &prop, 0 ) );
  int blocks = prop.multiProcessorCount * 2;
  cout << "Using blocks = " << blocks << endl;

  for (i=0, N1=Nstart; i < Ntimes; ++i, N1*=2) {
    timing[i] = cpu_harness(N1, blocks);
  }

}

