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



func diff(s1, s2 string) {
  var err error
  var pp1, pp2 ParticleArr

  ff1, err := os.Open(s1)
  if err!=nil {
    fatal(err)
  }
  defer ff1.Close()
  _, pp1, err = ReadParticles(ff1, false)
  if err!=nil {
    fatal(err)
  }

  ff2, err := os.Open(s2)
  if err!=nil {
    fatal(err)
  }
  defer ff2.Close()
  _, pp2, err = ReadParticles(ff2, false)
  if err!=nil {
    fatal(err)
  }

  if l1, l2:=pp1.Len(), pp2.Len(); l1 != l2 {
    fmt.Println("Files appear to have different numbers of particles", l1, l2)
    return
  }

  // Make sure  siles are sorted appropriately
  sort.Sort(pp1)
  sort.Sort(pp2)

  var dv, dx, maxdx, maxdv float64 = 0.0, 0.0,0.0, 0.0
  for i := range(pp1) {
    if pp1[i].id != pp2[i].id {
      fmt.Printf("ids differ at %d \n", i)
      fmt.Printf("%+v \n", pp1[i])
      fmt.Printf("%+v \n", pp2[i])
      return
    }
    for i:=0; i<3; i++ {
      dx = math.Abs(float64(pp1[i].pos[i] - pp2[i].pos[i]))
      dv = math.Abs(float64(pp1[i].vel[i] - pp2[i].vel[i]))
      if dx > maxdx {
        maxdx = dx
      }
      if dv > maxdv {
        maxdv = dv
      }
    }
  }

  fmt.Println("Maximum dx, dv =", dx, dv)
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
