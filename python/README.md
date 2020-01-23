# Python tools 

## geoserverCatalog.py

Tool to get the URLs of IMOS-AODN files using different filters as argument of the function. Just redirect the output to a text file.

### usage
```
usage: geoserverCatalog.py [-h] [-var VARNAME] [-site SITE] [-ft FEATURETYPE]
                           [-fv FILEVERSION] [-ts TIMESTART] [-te TIMEEND]
                           [-dc DATACATEGORY] [-realtime REALTIME]
                           [-exc FILTEROUT [FILTEROUT ...]]
                           [-inc FILTERIN [FILTERIN ...]]

Get a list of urls from the AODN geoserver

optional arguments:
  -h, --help            show this help message and exit
  -var VARNAME          name of the variable of interest, like TEMP
  -site SITE            site code, like NRMMAI
  -ft FEATURETYPE       feature type, like timeseries
  -fv FILEVERSION       file version, like 1
  -ts TIMESTART         start time like 2015-12-01
  -te TIMEEND           end time like 2018-06-30
  -dc DATACATEGORY      data category like Temperature
  -realtime REALTIME    yes or no. If absent, all modes will be retrieved
  -exc FILTEROUT [FILTEROUT ...]
                        regex to filter out the url list. Case sensitive
  -inc FILTERIN [FILTERIN ...]
                        regex to include files in the url list. case sensitive

```

### example

Get the URLs of all files containing temperature from Yongala National Reference Station, not from realtime files, excluding any velocity measuring instrument, aggregated, hourly or gridded timeseries product, and since Jan 2018. Save the results in NRSYON_temp.txt text file.

```
python geoserverCatalog.py -var TEMP -site NRSYON -realtime no -ts 2018-01-01 -exc velocity aggregated_timeseries hourly_timeseries gridded_timeseries >NRSYON_temp.txt

## Number of files returned
wc -l NRSYON_temp.txt
85 NRSYON_temp.txt

## first 10 URLs
head NRSYON_temp.txt 
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/aggregated_timeseries/IMOS_ANMN-NRS_TZ_20080623_NRSYON_FV01_TEMP-aggregated-timeseries_END-20180509_C-20190819.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/non-QC/IMOS_ANMN-NRS_CFKTUZ_20170926T071459Z_NRSYON_FV00_NRSYON-1709-SUB-SBE16plus-28.8_END-20180512T105959Z_C-20190308T024600Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/IMOS_ANMN-NRS_CFKSTUZ_20170926T071459Z_NRSYON_FV01_NRSYON-1709-SUB-SBE16plus-28.8_END-20180512T105959Z_C-20190308T024600Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Velocity/non-QC/IMOS_ANMN-NRS_AETVZ_20170926T073900Z_NRSYON_FV00_NRSYON-1709-SUB-Sentinel-or-Monitor-Workhorse-ADCP-28.4_END-20180418T095900Z_C-20190308T024602Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Velocity/IMOS_ANMN-NRS_AETVZ_20170926T073900Z_NRSYON_FV01_NRSYON-1709-SUB-Sentinel-or-Monitor-Workhorse-ADCP-28.4_END-20180418T095900Z_C-20190308T024602Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Temperature/IMOS_ANMN-NRS_TZ_20170928T120000Z_NRSYON_FV01_NRSYON-1709-SRF-SBE56-0.9_END-20180512T052759Z_C-20190308T030454Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Temperature/non-QC/IMOS_ANMN-NRS_TZ_20170928T120000Z_NRSYON_FV00_NRSYON-1709-SRF-SBE56-0.9_END-20180512T052759Z_C-20190308T030454Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/non-QC/IMOS_ANMN-NRS_CKOTUZ_20170928T222929Z_NRSYON_FV00_NRSYON-1709-SRF-WQM-0.9_END-20180509T211530Z_C-20190308T030454Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/IMOS_ANMN-NRS_CKOSTUZ_20170928T222929Z_NRSYON_FV01_NRSYON-1709-SRF-WQM-0.9_END-20180509T211530Z_C-20190308T030454Z.nc
http://thredds.aodn.org.au/thredds/dodsC/IMOS/ANMN/NRS/NRSYON/Biogeochem_timeseries/burst-averaged/IMOS_ANMN-NRS_CKOSTUZ_20170929T204458Z_NRSYON_FV02_NRSYON-1709-SRF-WQM-0.9-burst-averaged_END-20180505T091459Z_C-20190620T060702Z.nc

```

### notes

The THREDDS server could be very slow if you plan to open more than few files or a very fat one, even producing a time-out error. It is better if you download the files locally using for example `wget`. For that just change '/dodC/'in the URL by '/fileServer/'and you can download it.

Another option os to get the file directly from IMOS-AODN Amazon S3 storage. Just replace "http://thredds.aodn.org.au/thredds/dodsC/" in your URL with "https://s3-ap-southeast-2.amazonaws.com/imos-data/", you get a URL that you can download directly from S3 with e.g. wget.

