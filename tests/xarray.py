#!/usr/bin/env python3
# Get fluxes with python
import os
import sys
import xarray as xr

# Read data
input = sys.argv[1]
output = sys.argv[2]
data = xr.open_dataset(input, decode_times=False)

# Perform calculations
emf = (
    (data['u'] - data['u'].mean('lon')) * (data['v'] - data['v'].mean('lon'))
).mean('lon')
ehf = (
    (data['t'] - data['t'].mean('lon')) * (data['v'] - data['v'].mean('lon'))
).mean('lon')
emf.name = 'emf'
ehf.name = 'ehf'
emf.attrs = {'long_name': 'eddy momentum flux', 'units': 'm**2/s**2'}
ehf.attrs = {'long_name': 'eddy heat flux', 'units': 'K*m/s'}

# Save file
out = xr.Dataset({'emf': emf, 'ehf': ehf})
if os.path.exists(output):
    os.remove(output)
out.to_netcdf(output, mode='w')  # specify whether we did chunking
