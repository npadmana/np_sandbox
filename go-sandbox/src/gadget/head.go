package main

import (
  "math"
  "os"
  "fmt"
  "flag"
  "sort"
)

func main() {
  flag.Parse()

  switch comm:=flag.Arg(0); {
    case comm=="head": head(flag.Arg(1))
    case comm=="dump": dump(flag.Arg(1))
    case comm=="diff": diff(flag.Arg(1), flag.Arg(2))
    default : fmt.Println("Unknown command ", comm)
  }
}

func dump(s string) {
  var h Header
  var pp ParticleArr
  var err error

  ff, err := os.Open(s)
  if err != nil {
    fatal(err)
  }
  defer ff.Close()

  // Now attempt to read in the file
  // note that ff satisfies io.Reader, so that's what we pass around
  h, pp, err = ReadParticles(ff, false)
  if err != nil {
    stderr("Not all blocks were successfully read!")
  }

  // Print it out
  fmt.Printf("%+v \n",h)

  np := pp.Len()
  if np > 50 {
    fmt.Println("Truncating to top 50 particles")
    np = 50
  }
  for i:=0; i< np; i++ {
    fmt.Printf("%+v \n", pp[i])
  }

  return
}


func readAll(s1 string, hc chan Header, ppc chan ParticleArr) {
  ff1, err := os.Open(s1)
  if err!=nil {
    fatal(err)
  }
  defer ff1.Close()
  h, pp, err := ReadParticles(ff1, false)
  if err!=nil {
    fatal(err)
  }

  hc <- h
  ppc <- pp

  return
}


func diff(s1, s2 string) {

  hc := make(chan Header, 2)
  ppc := make(chan ParticleArr)

  go readAll(s1, hc, ppc)
  go readAll(s2, hc, ppc)

  pp1 := <-ppc
  pp2 := <-ppc

  //_, pp1 := readAll(s1)
  //_, pp2 := readAll(s2)

  if l1, l2:=pp1.Len(), pp2.Len(); l1 != l2 {
    fmt.Println("Files appear to have different numbers of particles", l1, l2)
    return
  }

  // Make sure  siles are sorted appropriately
  sort.Sort(pp1)
  sort.Sort(pp2)

  var x0, v0 float64
  var dv, dx, maxdx, maxdv float64 = 0.0, 0.0,0.0, 0.0
  for i := range(pp1) {
    if pp1[i].id != pp2[i].id {
      fmt.Printf("ids differ at %d \n", i)
      fmt.Printf("%+v \n", pp1[i])
      fmt.Printf("%+v \n", pp2[i])
      return
    }
    for j:=0; i<3; i++ {
      dx = math.Abs(float64(pp1[i].pos[j] - pp2[i].pos[j]))
      dv = math.Abs(float64(pp1[i].vel[j] - pp2[i].vel[j]))
      if dx > maxdx {
        maxdx = dx
        x0 = float64(pp1[i].pos[j])
      }
      if dv > maxdv {
        maxdv = dv
        v0 = float64(pp1[i].vel[j])
      }
    }
  }

  fmt.Println("Maximum dx, x, dv, v =", dx, x0, dv, v0)
}


func head(s string) {
  ff, err := os.Open(s)
  if err != nil {
    fatal(err)
  }
  defer ff.Close()

  // Now attempt to read in the file
  // note that ff satisfies io.Reader, so that's what we pass around
  hdr, err := ReadHeader(ff)
  if err != nil {
    fatal(err)
  }

  // Print it out
  fmt.Printf("%+v \n",hdr)
}
