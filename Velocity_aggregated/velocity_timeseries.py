import numpy as np
import bisect
import argparse
import os.path
import json
from datetime import datetime
import glob

import xarray as xr
import pandas as pd

import aggregated_timeseries as TStools


def in_water(nc):
    """
    cut data to in-water only timestamps, dropping resulting NaN.

    :param nc: xarray dataset
    :return: xarray dataset
    """
    time_deployment_start = np.datetime64(nc.attrs['time_deployment_start'][:-1])
    time_deployment_end = np.datetime64(nc.attrs['time_deployment_end'][:-1])
    TIME = nc['TIME'][:]
    return nc.where((TIME >= time_deployment_start) & (TIME <= time_deployment_end), drop=True)




## get file names
files_to_aggregate = [f for f in glob.glob("samples/*.nc")]


var_to_aggregate = ['UCUR', 'VCUR', 'WCUR']

## empty container for metadata
metadata = pd.DataFrame(columns=['source_file', 'instrument_id', 'LATITUDE', 'LONGITUDE', 'NOMINAL_DEPTH'])

## empty np arrays
time_all = np.array([], dtype='datetime64[ns]')
uu_all = np.array([], dtype='float64')
vv_all = np.array([], dtype='float64')
ww_all = np.array([], dtype='float64')
depth_all = np.array([], dtype='float64')

uuqc_all = np.array([], dtype='int')
vvqc_all = np.array([], dtype='int')
wwqc_all = np.array([], dtype='int')
depthqc_all = np.array([], dtype='int')


instrument_index_all = np.array([], dtype='int')

for index, file in enumerate(files_to_aggregate):
    print(file)
    with xr.open_dataset(file) as nc:

        nc = in_water(nc)
        ## get variable list
        varList = list(nc.variables)
        ## get metadata
        metadata = metadata.append({'source_file': file,
                                    'instrument_id': nc.attrs['deployment_code'] + '; ' + nc.attrs['instrument'] + '; ' + nc.attrs['instrument_serial_number'],
                                    'LATITUDE': nc.LATITUDE.squeeze().values,
                                    'LONGITUDE': nc.LONGITUDE.squeeze().values,
                                    'NOMINAL_DEPTH': TStools.get_nominal_depth(nc)},
                                   ignore_index=True)

        uu = nc.UCUR.values.flatten()
        uuqc = nc.UCUR_quality_control.values.flatten()
        vv = nc.VCUR.values.flatten()
        vvqc = nc.VCUR_quality_control.values.flatten()
        if 'WCUR' in varList:
            ww = nc.WCUR.values.flatten()
            wwqc = nc.WCUR_quality_control.values.flatten()
        else:
            ww = np.full(len(uu), np.nan)
            wwqc = np.full(len(uu), np.nan)

        ##calculate depth
        if 'HEIGHT_ABOVE_SENSOR' in varList:
            depth = np.add.outer(nc.DEPTH.values, nc.HEIGHT_ABOVE_SENSOR.values).flatten()
            number_of_cells = len(nc.HEIGHT_ABOVE_SENSOR)
            depthqc = np.array(number_of_cells*[nc.DEPTH_quality_control.values]).flatten()
        else:
            depth = nc.DEPTH.values
            number_of_cells = 1
            depthqc = nc.DEPTH_quality_control.values

        ## TIME and Instrument index
        time = np.array(number_of_cells*[nc.TIME.values]).flatten()
        instrument_index = np.array([index]*len(time)).flatten()

    ## Concatenate arrays
    uu_all = np.concatenate((uu_all, uu))
    uuqc_all = np.concatenate((uuqc_all, uuqc))

    vv_all = np.concatenate((vv_all, vv))
    vvqc_all = np.concatenate((vvqc_all, vvqc))

    ww_all = np.concatenate((ww_all, ww))
    wwqc_all = np.concatenate((wwqc_all, wwqc))

    depth_all = np.concatenate((depth_all, depth))
    depthqc_all = np.concatenate((depthqc_all, depthqc))

    time_all = np.concatenate((time_all, time))
    instrument_index_all = np.concatenate((instrument_index_all, instrument_index))



ds = xr.Dataset({'UCUR': (['OBSERVATION'], uu_all),
                 'UCUR_quality_control': (['OBSERVATION'], uuqc_all),
                 'VCUR': (['OBSERVATION'], vv_all),
                 'VCUR_quality_control': (['OBSERVATION'], vvqc_all),
                 'WCUR': (['OBSERVATION'], ww_all),
                 'WCUR_quality_control': (['OBSERVATION'], wwqc_all),
                 'DEPTH': (['OBSERVATION'], depth_all),
                 'DEPTH_quality_control': (['OBSERVATION'], depthqc_all),
                 'TIME': (['OBSERVATION'], time_all),
                 'instrument_index': (['OBSERVATION'], instrument_index_all)})


metadata.index.rename('INSTRUMENT', inplace=True)

ds = xr.merge([ds, xr.Dataset.from_dataframe(metadata)])




## set compression
comp = dict(zlib=True, complevel=5)
encoding = {var: comp for var in ds.data_vars}

# encoding.update({'TIME':                     {'_FillValue': False,python geo  
#                                          'units': time_units,
#                                          'calendar': time_calendar},
#             'LONGITUDE':                {'_FillValue': False},
#             'LATITUDE':                 {'_FillValue': False},
#             'instrument_id':            {'dtype': '|S256'},
#             'source_file':              {'dtype': '|S256'}})




## add attributes

## write output file

ds.to_netcdf('VelocityTest.nc', encoding=encoding)
