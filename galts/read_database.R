library(RPostgreSQL)
source('~/myWork/nputils/R/BOSS/common.R')
source('~/myWork/nputils/R/BOSS/galtarget.R')

# Set up database driver and connection
DBSetup <- function () {
  dri <- dbDriver("PostgreSQL")
  con <- dbConnect(dri,user='np274', dbname='sdss', host='localhost', password='postgres')
  return(list(driver=dri, conn=con))
}


Get.Sample.SpAll <- function(conn, galtype=c("GAL_CMASS")) {
  # Get a data frame of CMASS galaxies from spall
  # Currently hardcode things, but we will change this as necessary
  colstr <- sprintf('("BOSS_TARGET1" & %i::bigint)::integer', 
                    boss.Flagname2Val(galtype, boss.target1))
  selectstr <- sprintf('%s as "TARGET1"',colstr)
  wherestr <- sprintf('(%s > 0)', colstr)
  script <- paste('select "PLATE", "MJD", "FIBERID", "CHUNK", "Z_NOQSO", "ZWARNING_NOQSO", ',
                  '"PLUG_RA", "PLUG_DEC", "BOSS_TARGET1", ',
                  ' "CMODELFLUX_2", "CMODELFLUX_3", "CMODELFLUX_4",',
                  ' "MODELFLUX_2",  "MODELFLUX_3",  "MODELFLUX_4", ',
                  ' "EXTINCTION_2", "EXTINCTION_3", "EXTINCTION_4",',
                  selectstr,
                  'from spall_v5_4_45_core natural join spall_v5_4_45_flux',
                  'where ("SPECPRIMARY"=1)  AND',wherestr, sep=" ")
  return(dbGetQuery(conn, script))
}

Make.Sample.Spall <- function(fn) {
  driv <- DBSetup()
  spall <- Get.Sample.SpAll(driv$conn, c("GAL_LOZ", "GAL_CMASS", "GAL_CMASS_SPARSE"))
  save(spall, file=fn)
  dbDisconnect(driv$conn)
}

Make.Sample.Spall("spall.xdr")



