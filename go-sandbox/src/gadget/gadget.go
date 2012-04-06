package main

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


type Particle struct {
  pos [3]float32
  vel [3]float32
  id uint64 // Store the particle position internally as ints
}

type ParticleArr []Particle


// Define sort functions
func (p ParticleArr) Len() int {
  return len(p)
}

func (p ParticleArr) Less(i,j int) bool {
  return p[i].id < p[j].id
}

func (p ParticleArr) Swap(i,j int) {
  p[i], p[j] = p[j], p[i]
}


