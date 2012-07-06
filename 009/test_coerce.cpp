#include <vector>
#include <iostream>

using namespace std;

template <typename T>
void coerce_void_array(void * ptr, int i, T& el1) {
  el1 = (static_cast<T *> (ptr))[i];
}

int main() {
  vector<double> v1;
  void * p1;
  double el1;
  v1.push_back(1.0); v1.push_back(3.0); v1.push_back(9.0);

  p1 = static_cast<void *> (&v1[0]);

  for (int ii=0; ii < 3; ++ii) {
    coerce_void_array(p1, ii, el1); 
    cout << el1 << endl;
  }
}

