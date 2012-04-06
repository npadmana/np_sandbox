package main

import (
//  "fmt"
  "errors"
  "io"
  "encoding/binary"
  "bytes"
)


// Fortran read 
func fortranRead(ff io.Reader, buf interface{}) (err error) {
  var dummy, dummy1 int32
  err = binary.Read(ff, binary.LittleEndian, &dummy)
  if err != nil {
    return 
  }

  err = binary.Read(ff, binary.LittleEndian, buf)
  if err != nil {
    return 
  }

  err = binary.Read(ff, binary.LittleEndian, &dummy1)
  if err != nil {
    return 
  }

  // Sanity checks
  if dummy!=dummy1 || int(dummy)!=binary.Size(buf) {
    err = errors.New("Error! Block sizes did not match")
  }

  return 
}

// Read in the Gadget header
func ReadHeader(ff io.Reader) (h Header, err error) {
  var buf headerBuf

  // Attempt to read in the file 
  err = fortranRead(ff, buf[:])
  if err != nil {
    return h, err
  }

  // Convert from a binary buffer to the structure
  // This two step process is to avoid having to count in the number of 
  // unused bytes
  err = binary.Read(bytes.NewReader(buf[:]), binary.LittleEndian, &h)

  // All done
  return
}

// Read in particles
// This assumes a single type of particle, with type = 1
func ReadParticles(ff io.Reader, longid bool) (h Header, pp ParticleArr, err error) {

  // Read in the header to figure out the number of particles
  h, err = ReadHeader(ff)
  if err!=nil {
    stderr("Error reading header\n")
    return
  }

  // Allocate memory for particles
  pp = make(ParticleArr, h.Npart[1])
  buf := make([]byte, 3*4*h.Npart[1])
  // Positions
  err = fortranRead(ff, buf)
  if err!=nil {
    stderr("Error reading positions\n")
    return 
  }
  for i := range pp {
    // Don't bother throwing an error
    err = binary.Read(bytes.NewReader(buf[i*12:i*12+12]), binary.LittleEndian, pp[i].pos[:])
  }

  // Velocities 
  err = fortranRead(ff, buf)
  if err!=nil {
    stderr("Error reading velocities\n")
    return 
  }
  for i := range pp {
    // Don't bother throwing an error
    err = binary.Read(bytes.NewReader(buf[i*12:i*12+12]), binary.LittleEndian, pp[i].vel[:])
  }
  // IDs
  var fac uint32 = 4
  if longid {
    fac=8
  }
  err = fortranRead(ff, buf[:h.Npart[1]*fac])
  if err!=nil {
    stderr("Error reading IDs\n")
    return
  }
  var shortid uint32
  for i := range pp {
    i1 := uint32(i)*fac
    i2 := i1 + fac
    if longid {
      err = binary.Read(bytes.NewReader(buf[i1:i2]), binary.LittleEndian, &pp[i].id)
    } else {
      err = binary.Read(bytes.NewReader(buf[i1:i2]), binary.LittleEndian, &shortid)
      pp[i].id = uint64(shortid)
    }
  } 

  // All done
  return
}


