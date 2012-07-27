# Specify the BOSS_TARGET1 galaxy flags; these are all in the lower 32 bits
# so we don't need to worry about the lack of a native 64 bit int in R
boss.target1 <- list()
boss.target1[["GAL_LOZ"]] <- 0L
boss.target1[["GAL_CMASS"]] <- 1L
boss.target1[["GAL_CMASS_COMM"]] <- 2L
boss.target1[["GAL_CMASS_SPARSE"]] <- 3L
boss.target1[["SDSS_GAL_KNOWN"]] <- 6L
boss.target1[["GAL_CMASS_ALL"]] <- 7L


boss.ComputeAuxColors <- function(data) {
  # Computes the BOSS galaxy TS auxiliary colors cperp, cpar and dperp
  #
  # Args :
  #   data : a data table/frame with MODELFLUX_[2,3,4] and EXTINCTION_[2,3,4] 
  #      The naming conventions come from STILTS loading an SQL database
  #
  # Returns :
  #   A modified data table/frame with cperp, cpar, and dperp
  #
  # NOTE : This is not necessarily memory efficient. But it's designed to 
  # be easy to read.
  within(data,{
    
    # Model colors
    g <- boss.Flux2Mag(MODELFLUX_2) - EXTINCTION_2
    r <- boss.Flux2Mag(MODELFLUX_3) - EXTINCTION_3
    i <- boss.Flux2Mag(MODELFLUX_4) - EXTINCTION_4
    z <- boss.Flux2Mag(MODELFLUX_5) - EXTINCTION_5
    gr <- g-r
    ri <- r-i
    dperp <- (ri) - (gr)/8.0
    cperp <- (ri) - (gr)/4.0 - 0.18
    cpar <- 0.7*(gr) + 1.2*(ri-0.18)
    
    # Fluxes and magnitudes
    rcmodel <- boss.Flux2Mag(CMODELFLUX_3) - EXTINCTION_3
    icmodel <- boss.Flux2Mag(CMODELFLUX_4) - EXTINCTION_4
    rpsf <- boss.Flux2Mag(PSFFLUX_3) - EXTINCTION_3
    ipsf <- boss.Flux2Mag(PSFFLUX_4) - EXTINCTION_4
    zpsf <- boss.Flux2Mag(PSFFLUX_5) - EXTINCTION_5
    ifib2 <- boss.Flux2Mag(FIBER2FLUX_4) - EXTINCTION_4
  })
}

boss.SelectCMASS_Helper <- function(data, intercept=19.86) {
  # Selects CMASS objects and adds in a new column in the dataframe : is.CMASS
  #
  # Args :
  #    data : A data frame with appropriate fluxes etc calculated. 
  #      Assumed that ComputeAuxColors has been run on this
  #
  # Result : 
  #    A new data frames with is.CMASS appended to it.
  #
  with(data, {
    is.CMASS <- icmodel < (intercept + 1.6*(dperp-0.8))
    is.CMASS <- is.CMASS & (dperp > 0.55)
    is.CMASS <- is.CMASS & (icmodel > 17.5) & (icmodel < 19.9)
    is.CMASS <- is.CMASS & ((ipsf-i) > (0.2 + 0.2*(20.0-i)))
    is.CMASS <- is.CMASS & ((zpsf-z) > 9.125 - 0.46*z)
    is.CMASS <- is.CMASS & (ri < 2)
    is.CMASS <- is.CMASS & (ifib2 < 21.5)
    # Eliminate NA
    is.CMASS[!is.finite(is.CMASS)] <- FALSE
    return(is.CMASS)
  })
}

boss.SelectCMASS <- function(data) {
  data[, is.CMASS := boss.SelectCMASS_Helper(data)]
}

boss.SelectLOWZ <- function(data) {
  # Selects LOWZ objects and adds in a new column in the dataframe : is.LOWZ
  #
  # Args :
  #    data : A data frame with appropriate fluxes etc calculated. 
  #      Assumed that ComputeAuxColors has been run on this
  #
  # Result : 
  #    A new data frames with is.LOWZ appended to it.
  #
  within(data, {
    is.LOWZ <- rcmodel < (13.5 + cpar/0.3)
    is.LOWZ <- is.LOWZ & (abs(cperp) < 0.2)
    is.LOWZ <- is.LOWZ & (rcmodel > 16) & (rcmodel < 19.6)
    is.LOWZ <- is.LOWZ & ((rpsf - rcmodel) > 0.3)
    # Eliminate NA
    is.LOWZ[!is.finite(is.LOWZ)] <- FALSE
  })
}

boss.SelectSPARSE <- function(data) {
  # Selects SPARSE objects and adds in a new column in the dataframe : is.SPARSE
  #
  # Args :
  #    data : A data frame with appropriate fluxes etc calculated. 
  #      Assumed that ComputeAuxColors has been run on this
  #
  # Result : 
  #    A new data frames with is.SPARSE appended to it.
  #
  if (!("is.CMASS" %in% names(data))) {
    data <- boss.SelectCMASS(data)
  }
  data[, is.SPARSE := !(is.CMASS) & boss.SelectCMASS_Helper(data, intercept=20.14)]
}

boss.galTypes <- list()
boss.galTypes[["LOWZ"]] <- list(name="GAL_LOZ", func=boss.SelectLOWZ)
boss.galTypes[["CMASS"]] <- list(name="GAL_CMASS", func=boss.SelectCMASS)
boss.galTypes[["SPARSE"]] <- list(name="GAL_CMASS_SPARSE", func=boss.SelectSPARSE)