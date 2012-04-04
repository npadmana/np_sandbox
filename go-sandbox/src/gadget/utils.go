package main

import (
  "fmt"
  "os"
)

// Print message to stderr
func stderr(s interface{}) {
  fmt.Fprintln(os.Stderr, s)
}

// cleanly exit code
func fatal(msg interface{}) {
  stderr(msg)
  os.Exit(2)
}

