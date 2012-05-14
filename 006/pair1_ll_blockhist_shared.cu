// GPU paircounting 
//  -- histograms are accumulated block by block (in global memory)
//  -- buffer the second particle data into shared memory in chunks
#include <iostream>
#include <vector>
#include <cmath>
#include <ctime>
#include <numeric>
#include "book.h"

const int Nstart = 1200;
const int Ntimes = 4;
const int Nhist = 100;


#define HISTINT long long
// Set the shared memory buffer
#define BUFFER 256  

using namespace std;

// Define a particle storage class
struct Particles {
  vector<float> x, y, z;
  vector<int> w;
  int N;
};


struct ParticlesGPU {
  float *x, *y, *z;
  int *w;
  int N;
};

void AllocCopyGPU(Particles &p, ParticlesGPU &p2) {
  // Figure out how much to pad with
  p2.N = ((p.N + BUFFER - 1)/BUFFER) * BUFFER; 

  // x
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.x, p2.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.x, &p.x[0], p.N * sizeof(float), cudaMemcpyHostToDevice));

  // y
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.y, p2.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.y, &p.y[0], p.N * sizeof(float), cudaMemcpyHostToDevice));


  // z
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.z, p2.N * sizeof(float)));
  HANDLE_ERROR( cudaMemcpy ( p2.z, &p.z[0], p.N * sizeof(float), cudaMemcpyHostToDevice));

  // w
  HANDLE_ERROR( cudaMalloc ( (void**)&p2.w, p2.N * sizeof(int)));
  HANDLE_ERROR( cudaMemset ( p2.w, 0, p2.N * sizeof(int)));
  HANDLE_ERROR( cudaMemcpy ( p2.w, &p.w[0], p.N * sizeof(int), cudaMemcpyHostToDevice));
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
  p.w.resize(N);

  // Fill in the vectors
  for (int ii=0; ii < N; ++ii) {
    p.x[ii] = float(rand())/float(RAND_MAX);
    p.y[ii] = float(rand())/float(RAND_MAX);
    p.z[ii] = float(rand())/float(RAND_MAX);
    p.w[ii] = 1;
  }

};

// Define the GPU kernel here 
__global__ void paircount_kernel(
    int N1, float *x1, float *y1, float *z1, int *w1, 
    int N2, float *x2, float *y2, float *z2, int *w2,
    int Nh, HISTINT *hist) {
  
  // Define shared memory buffer
  __shared__ float bx[BUFFER], by[BUFFER], bz[BUFFER];
  __shared__ int bw[BUFFER];


  // We distribute p1, but loop through all of p2
  int ii, jj, kk, idr;
  int stride = blockDim.x * gridDim.x;
  float x, y, z, dx, dy, dz, dr;
  int w;
  ii = threadIdx.x + blockIdx.x * blockDim.x;
  int offset = blockIdx.x * Nh;

  while (ii < N1) {
    x = x1[ii]; y = y1[ii]; z = z1[ii]; w = w1[ii];
    for (jj = 0; jj < (N2 + BUFFER - 1)/BUFFER; ++jj) {
      // Fill the buffer
      // We assume that we will pad the array out to the nearest BUFFER multiple
      // This avoids a number of internal checks
      if (threadIdx.x < BUFFER) {
        bx[threadIdx.x] = x2[jj*BUFFER + threadIdx.x];
        by[threadIdx.x] = y2[jj*BUFFER + threadIdx.x];
        bz[threadIdx.x] = z2[jj*BUFFER + threadIdx.x];
        bw[threadIdx.x] = w2[jj*BUFFER + threadIdx.x];
      }
      __syncthreads();

      for (kk=0; kk < BUFFER; ++kk) {
        dx = bx[kk] - x;
        dy = by[kk] - y;
        dz = bz[kk] - z;
        dr = sqrtf(dx*dx + dy*dy + dz*dz);
        idr = (int) (dr*Nh);
        // THE LINE BELOW IS WRONG! USE FOR SPEED TESTING ONLY!
        //if (idr < Nh) hist[idr+offset] += (w * bw[kk]);
        // THE LINE BELOW IS CORRECT
        if (idr < Nh) atomicAdd( (unsigned long long*) &hist[idr + offset], (unsigned long long) (w * bw[kk]));
      }
    }
    ii += stride;
  }

}

// Define the histogram summing kernel here 
__global__ void reduce_histogram(int Nh, HISTINT *hist) {
  int ii = threadIdx.x ;
  int offset = blockIdx.x * Nh;
  if (blockIdx.x > 0)  {
    while (ii < Nh) {
      atomicAdd( (unsigned long long*) &hist[ii], (unsigned long long) hist[ii+offset]);
      ii += blockDim.x;
    }
  }
}



// Remove all the blocking --- it's fine if this is slow-ish
void cpu_paircount(const Particles &p1, const Particles &p2, vector<HISTINT>& hist) {
  float x1, y1, z1, dx, dy, dz, dr;
  int idr, w1;
  for (int ii =0; ii < p1.N; ++ii) {
    x1 = p1.x[ii]; y1 = p1.y[ii]; z1 = p1.z[ii]; w1 = p1.w[ii]; 
    for (int jj=0; jj < p2.N; ++jj) { 
      dx = p2.x[jj]-x1;
      dy = p2.y[jj]-y1;
      dz = p2.z[jj]-z1;
      dr = sqrt(dx*dx + dy*dy + dz*dz);
      idr = (int)(dr*Nhist);
      if (idr < Nhist) hist[idr] += w1*p2.w[jj];
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
  HISTINT *gpu_hist;

  HANDLE_ERROR( cudaMalloc( (void**)&gpu_hist, Nhist*blocks*sizeof(HISTINT)));
  HANDLE_ERROR( cudaMemset( gpu_hist, 0, Nhist*blocks*sizeof(HISTINT)));
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );
  paircount_kernel<<<blocks, 512>>>(pg1.N, pg1.x, pg1.y, pg1.z, pg1.w,
      pg2.N, pg2.x, pg2.y, pg2.z, pg2.w, Nhist, gpu_hist);
  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  HANDLE_ERROR( cudaEventElapsedTime( &gpu_dt,
                                      start, stop ) );
  cout << "  Time for GPU paircounts (ms): " << gpu_dt << endl;
  // reduce histogram
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );
  reduce_histogram<<<blocks, 512>>>(Nhist, gpu_hist);
  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  HANDLE_ERROR( cudaEventElapsedTime( &gpu_dt,
                                      start, stop ) );
  cout << "  Time to reduce GPU paircounts (ms): " << gpu_dt << endl;

  // Suck back the histogram array
  vector<HISTINT> hist1(Nhist);
  HANDLE_ERROR( cudaMemcpy( &hist1[0], gpu_hist, Nhist*sizeof(HISTINT), cudaMemcpyDeviceToHost));


  // Clean up
  cudaFree(gpu_hist);
  FreeGPU(pg1); FreeGPU(pg2);


  // Clean up GPU timers
  HANDLE_ERROR( cudaEventDestroy( start ) );
  HANDLE_ERROR( cudaEventDestroy( stop ) );

  // CPU paircounting
  vector<HISTINT> hist(Nhist,0);
  t0 = clock();
  cpu_paircount(p1, p2, hist);
  dt = difftime(clock(), t0)/double(CLOCKS_PER_SEC);
  cout << "  Time to count pairs v2: " << dt << endl;

  //for (int ii = 0; ii < Nhist; ++ii) {
  //  cout << ii << " " << hist[ii] << " "  << hist1[ii] << endl;
  //}

  // Now compare histograms
  HISTINT dhist = 0, error = 0, eval = 0;
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

