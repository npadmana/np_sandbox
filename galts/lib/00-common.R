boss.Flagname2Val <- function (names, flagdefs) {
  # Convert flag names into a bitmask
  #
  # Args :
  #   names : a vector or list of flag names
  #   flagdefs : a list of flag definitions (flagnames -> bit number). 
  #       See boss.target1 for an example
  # 
  # Returns : 
  #    The value to be ANDed against to select these objects
  tmpfun <- function(name1) return(flagdefs[[name1]])
  sum(2L^sapply(names, tmpfun))
}


boss.Flux2Mag <- function(flux) {
  # Convert flux -- assumed to be in nanomaggies into magnitudes
  #
  # Args :
  #   flux : fluxes
  #
  # Returns :
  #   magnitudes. Fluxes below zero are mapped to NA_real_
  flux[flux <= 0] <- NA_real_
  return(22.5-2.5*log10(flux)) 
}