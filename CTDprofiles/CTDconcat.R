### Concatenate CTD profile files
### in wide format. All the variables in the ncdf file
library(ncdf4)
library(dplyr)

library(reticulate)
thredds = import("threddsclient")

## supress warniong messages
options(warn=-1)

basedatadir = "CTDprofiles/"

## get file names
##fnames = readLines(con="CTDprofiles/filelist.txt")

## get urls from thredds catalog
fnames = thredds$opendap_urls("http://thredds.aodn.org.au/thredds/catalog/IMOS/ANMN/NRS/NRSYON/Biogeochem_profiles/catalog.html")


## define empty DF to store variables. Wide format
CTD = data.frame(site.code = character(), 
                 station = character(), 
                 cruise = character(), 
                 dateDay = as.POSIXct(character()),
                 depth = numeric(), 
                 desc = numeric(), 
                 desc.qc = numeric(),
                 presRel = numeric(), 
                 presRel.qc = numeric(), 
                 temp = numeric(), 
                 temp.qc = numeric(),
                 cndc = numeric(), 
                 cndc.qc = numeric(),
                 dens = numeric(), 
                 dens.qc = numeric(),
                 cphl = numeric(), 
                 cphl.qc = numeric(),
                 chlf = numeric(),
                 chlf.qc = numeric(),
                 dox1 = numeric(), 
                 dox1.qc = numeric(), 
                 par = numeric(), 
                 par.qc = numeric(),
                 psal = numeric(), 
                 psal.qc = numeric(), 
                 dox2 = numeric(), 
                 dox2.qc = numeric(), 
                 doxs = numeric(), 
                 doxs.qc = numeric(), 
                 turb = numeric(), 
                 turb.qc = numeric())

## main loop
for (i in 1: length(fnames)){
  
  print(fnames[i])
  nc = nc_open(fnames[i])
  
  ## get attributes
  nc.attr = ncatt_get(nc, 0)
  site.code = nc.attr$site_code
  station = nc.attr$station
  cruise = nc.attr$cruise
  
  ## get variables
  dateDay = as.POSIXct(ncvar_get(nc, "TIME")*(60*60*24), origin = "1950-01-01 00:00:00 UTC", tz="UTC")
  depth = ncvar_get(nc, "DEPTH") 
  desc = tryCatch(ncvar_get(nc, "DESC"), error = function(e) as.numeric(rep(NA, length(depth))))
  desc.qc = tryCatch(ncvar_get(nc, "DESC_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  presRel = tryCatch(ncvar_get(nc, "PRES_REL"), error = function(e) as.numeric(rep(NA, length(depth))))
  presRel.qc = tryCatch(ncvar_get(nc, "PRES_REL_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  temp = tryCatch(ncvar_get(nc, "TEMP"), error = function(e) as.numeric(rep(NA, length(depth))))
  temp.qc = tryCatch(ncvar_get(nc, "TEMP_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  cndc = tryCatch(ncvar_get(nc, "CNDC"), error = function(e) as.numeric(rep(NA, length(depth))))
  cndc.qc = tryCatch(ncvar_get(nc, "CNDC_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  dens = tryCatch(ncvar_get(nc, "DENS"), error = function(e) as.numeric(rep(NA, length(depth))))
  dens.qc = tryCatch(ncvar_get(nc, "DENS_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  cphl = tryCatch(ncvar_get(nc, "CPHL"), error = function(e) as.numeric(rep(NA, length(depth))))
  cphl.qc = tryCatch(ncvar_get(nc, "CPHL_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  chlf = tryCatch(ncvar_get(nc, "CHLF"), error = function(e) as.numeric(rep(NA, length(depth))))
  chlf.qc = tryCatch(ncvar_get(nc, "CHLF_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  dox1 = tryCatch(ncvar_get(nc, "DOX1"), error = function(e) as.numeric(rep(NA, length(depth))))
  dox1.qc = tryCatch(ncvar_get(nc, "DOX1_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  doxs = tryCatch(ncvar_get(nc, "DOXS"), error = function(e) as.numeric(rep(NA, length(depth))))
  doxs.qc = tryCatch(ncvar_get(nc, "DOXS_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  par = tryCatch(ncvar_get(nc, "PAR"), error = function(e) as.numeric(rep(NA, length(depth))))
  par.qc = tryCatch(ncvar_get(nc, "PAR_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  psal = tryCatch(ncvar_get(nc, "PSAL"), error = function(e) as.numeric(rep(NA, length(depth))))
  psal.qc = tryCatch(ncvar_get(nc, "PSAL_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  dox2 = tryCatch(ncvar_get(nc, "DOX2"), error = function(e) as.numeric(rep(NA, length(depth))))
  dox2.qc = tryCatch(ncvar_get(nc, "DOX2_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  turb = tryCatch(ncvar_get(nc, "TURB"), error = function(e) as.numeric(rep(NA, length(depth))))
  turb.qc = tryCatch(ncvar_get(nc, "TURB_quality_control"), error = function(e) as.numeric(rep(NA, length(depth))))
  
  ## bind data
  CTD = bind_rows(CTD, data.frame(site.code = rep(site.code, length(depth)), 
                                  station = rep(station, length(depth)), 
                                  cruise = rep(cruise, length(depth)), 
                                  dateDay = rep(dateDay, length(depth)),
                                  depth, 
                                  desc, 
                                  desc.qc,
                                  presRel, 
                                  presRel.qc, 
                                  temp, 
                                  temp.qc,
                                  cndc, 
                                  cndc.qc,
                                  dens, 
                                  dens.qc,
                                  cphl, 
                                  cphl.qc,
                                  dox1, 
                                  dox1.qc, 
                                  par, 
                                  par.qc,
                                  psal, 
                                  psal.qc, 
                                  dox2, 
                                  dox2.qc))
  
}

## arrange the df with date and depth
CTD = CTD %>% arrange(dateDay, depth)
  
## write datframe
write.csv(file=paste0(basedatadir, site.code, "_CTD.csv"), CTD, row.names = F)
