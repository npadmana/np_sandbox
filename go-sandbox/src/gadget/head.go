package main

import (
  "os"
  "fmt"
  "flag"
)

func main() {
  flag.Parse()

  switch comm:=flag.Arg(0); {
    case comm=="head": head(flag.Arg(1))
    default : fmt.Println("Unknown command ", comm)
  }
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
