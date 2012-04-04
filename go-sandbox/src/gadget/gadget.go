package main

import (
  "errors"
  "io"
  "encoding/binary"
  "bytes"
)

// Useful constants will go here
const (
  headerSize = 256 // Gadget-2 header size
)

// Define a buffer type for the Gadget header
type headerBuf [headerSize]byte

// Define the Gadget header
type Header struct {
  Npart [6]uint32 // Number of particles in this file
  MassArr [6]float64 // Masses of particles in this file
  Time float64
  Redshift float64
  FlagSFR int32
  FlagFeedback int32
  Nall [6]uint32
  FlagCooling int32
  NumFiles int32 // Number of files written out
  BoxSize float64
  Omega0 float64
  OmegaLambda float64
  HubbleParam float64
  FlagAge int32
  FlagMetals int32
  NallHW [6]uint32
  FlagEntrICS int32
}

// Fortran read 
func fortranRead(ff io.Reader, buf []byte) (err error) {
  var dummy, dummy1 int32
  err = binary.Read(ff, binary.LittleEndian, &dummy)
  if err != nil {
    return err
  }

  _, err = io.ReadFull(ff, buf)
  if err != nil {
    return err
  }

  err = binary.Read(ff, binary.LittleEndian, &dummy)
  if err != nil {
    return err
  }

  // Sanity checks
  if dummy!=dummy1 && int(dummy)!=len(buf) {
    return errors.New("Error! Block sizes did not match")
  }

  return nil
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
