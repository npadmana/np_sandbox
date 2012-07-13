library(RPostgreSQL)
source('~/myWork/nputils/R/BOSS/common.R')
source('~/myWork/nputils/R/BOSS/galtarget.R')

# Set up database driver and connection
DBSetup <- function () {
  dri <- dbDriver("PostgreSQL")
  con <- dbConnect(dri,user='np274', dbname='sdss', host='localhost', password='postgres')
  return(list(driver=dri, conn=con))
}


Get.CMASS.SpAll <- function(conn) {
  # Get a data frame of CMASS galaxies from spall
  # Currently hardcode things, but we will change this as necessary
  script <- paste('select "PLATE", "MJD", "FIBERID", "CHUNK", "Z_NOQSO", "ZWARNING_NOQSO", ',
                  '"PLUG_RA", "PLUG_DEC", "BOSS_TARGET1", ',
                  ' "CMODELFLUX_2", "CMODELFLUX_3", "CMODELFLUX_4",',
                  ' "MODELFLUX_2",  "MODELFLUX_3",  "MODELFLUX_4", ',
                  ' "EXTINCTION_2", "EXTINCTION_3", "EXTINCTION_4" ',
                  'from spall_v5_4_45_core natural join spall_v5_4_45_flux',
                  'where ("SPECPRIMARY"=1)  AND (("BOSS_TARGET1" & 2::bigint) = 2)', sep=" ")
  return(dbGetQuery(conn, script))
}

MkCMASS1 <- function(fn) {
  db1 <- DBSetup()
  cmass1 <- Get.CMASS.SpAll(db1$conn)
  save(cmass1, file=fn)
}

MkCMASS1("cmass1.xdr")


