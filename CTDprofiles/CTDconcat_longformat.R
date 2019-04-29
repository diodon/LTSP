### Concatenate CTD profile files
### in wide format. All the variables in the ncdf file
library(ncdf4)
library(dplyr)
library(reshape2)


library(reticulate)
thredds = import("threddsclient")

## supress warniong messages
options(warn=-1)

basedatadir = "CTDprofiles/"

NRSname = "NRSYON"

## get file names
##fnames = readLines(con="CTDprofiles/filelist.txt")

## get urls from thredds catalog
fnames = thredds$opendap_urls(paste0("http://thredds.aodn.org.au/thredds/catalog/IMOS/ANMN/NRS/", 
                                     NRSname, "/Biogeochem_profiles/catalog.html"))


## define empty DF to store variables. Wide format
CTD = data.frame(site.code = character(), 
                 station = character(), 
                 cruise = character(), 
                 dateDay = as.POSIXct(character()),
                 depth = numeric(), 
                 ctd.var = character(),
                 ctd.value = numeric())

## main loop
for (i in 1: length(fnames)){
  
  print(paste0(i, " -", fnames[i]))
  nc = nc_open(fnames[i])
  
  ## get attributes
  nc.attr = ncatt_get(nc, 0)
  site.code = nc.attr$site_code
  station = nc.attr$station
  cruise = nc.attr$cruise

  ## get variable names
  CTD.varnames = attributes(nc$var)$names
  
  ## get time and depth
  dateDay = as.POSIXct(ncvar_get(nc, "TIME")*(60*60*24), origin = "1950-01-01 00:00:00 UTC", tz="UTC")
  depth = ncvar_get(nc, "DEPTH") 
  
  ## get all variables
  ## filtering out single value vars
  for (j in 1:length(CTD.varnames)){
    ctd.value = ncvar_get(nc, CTD.varnames[j])
    if (length(ctd.value)>1){
      print(CTD.varnames[j])
      CTD = bind_rows(CTD, data.frame(site.code = rep(site.code, length(ctd.value)),
                                      station = rep(station, length(ctd.value)),
                                      cruise = rep(cruise, length(ctd.value)),
                                      dateDay = rep(dateDay, length(ctd.value)),
                                      depth, 
                                      ctd.var = rep(CTD.varnames[j], length(ctd.value)),
                                      ctd.value))
    }
  }
}


## arrange the df with date and depth
CTD = CTD %>% arrange(dateDay, ctd.var,  depth)
  
## write datframe
write.csv(file=paste0(basedatadir, site.code, "_CTD_long.csv"), CTD, row.names = F)


## convert to wide format
CTD.wide = dcast(site.code+station+cruise+dateDay+depth~ctd.var, data=CTD, value.var = "ctd.value")

## write dataframe wide
write.csv(file=paste0(basedatadir, site.code, "_CTD_wide.csv"), CTD.wide, row.names = F)
