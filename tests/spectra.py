#!/usr/bin/env python3
################################################################################
# Calculates phase speed and wavenumber spectra for the EP flux and momentum
# and heat flux terms, along with say geopotential and SLP. Should result in
# a longitude by latitude by phase speed, wavenumber by latitude by time, and
# wavenumber by latitude by phase speed files.
################################################################################
# Imports
import os
import re
import sys
import time
import numpy as np
import xarray as xr
import climpy

t1 = time.time()
t0 = t1


def timer(message):
    global t1
    t2 = time.time()
    print(f'{message}: {t2-t1:.3f}s')
    t1 = t2


# File, with optional decoding
# if len(sys.argv)!=4:
#     raise ValueError('Require three input args.')
# archivename = sys.argv[2]
if len(sys.argv[1:]) != 2:
    raise ValueError(f'Require two input args, instead got: {sys.argv[1:]}.')
filename = sys.argv[1]
outname = sys.argv[2]
# ncl = os.path.dirname(__file__) + '/qgpv.ncl' # NCL command for getting QGPV

# Load data
data = xr.open_dataset(filename, decode_times=False)

# Coordinates
days = data['time']
plev = data['plev']
lat = data['lat']
lon = data['lon']
bnds = data['plev_bnds'].values
dp = (bnds[:, 1] - bnds[:, 0])[:, None, None]  # singleton lon, lat dims

# Variables
u = data['u'].values
v = data['v'].values
t = data['t'].values

# Fluxes
# NOTE: Numpy fft by default returns frequency as cycles/<record step>, so we
# divide by <units>/<record step> to convert to desired units. In the case of
# longitude, desired final units are <fraction of latitude circle>.
dt = days.values[1] - days.values[0]  # final units are '1/day'
dlon = lon.values[1] - lon.values[0] / 360.0  # final units are 'cycles'
ustar = u - u.mean(axis=3, keepdims=True)
vstar = v - v.mean(axis=3, keepdims=True)
tstar = t - t.mean(axis=3, keepdims=True)

# Barotropic and baroclinic components
utropic = (u * dp).sum(axis=1, keepdims=True) / dp.sum()
vtropic = (v * dp).sum(axis=1, keepdims=True) / dp.sum()
uclinic = u - utropic
vclinic = u - vtropic
timer(' * Time for initial stuff')

# Get QGPV and delete archive
# if not os.path.exists(archivename):
#     raise ValueError(f'Could not find output file {archivename}.')
# pv = xr.open_dataarray(archivename, decode_times=False).sel(plev=slice(900,1000)).values
# pv = xr.open_dataarray(archivename, decode_times=False).values
# pvstar = pv - pv.mean(axis=3, keepdims=True)

# Get 2D spectral breakdown
# NOTE: The ke terms are not *actually* ke, just the vector components that
# when squared (i.e. the power analysis) correspond to ke. Or something like that.
# Iterate over flux terms
ke = np.sqrt(ustar ** 2 + vstar ** 2)

ke_tropic = np.sqrt(
    (utropic - utropic.mean(axis=3, keepdims=True)) ** 2
    + (vtropic - vtropic.mean(axis=3, keepdims=True)) ** 2
)[:, 0, :, :]

ke_clinic = np.sqrt(
    (uclinic - uclinic.mean(axis=3, keepdims=True)) ** 2
    + (vclinic - vclinic.mean(axis=3, keepdims=True)) ** 2
)

# Parameter settings
params = {
    'ehf': (tstar, vstar),
    'emf': (ustar, vstar),
    'ke': (ke,),
    'ke_tropic': (ke_tropic,),
    'ke_clinic': (ke_clinic,),
}
shorts = {
    'ehf': ('t', 'v', 'ehf'),
    'emf': ('u', 'v', 'emf'),
    'ke': ('ke',),
    'ke_tropic': ('ke_tropic',),
    'ke_clinic': ('ke_clinic',),
}
longs = {
    'ehf': ('temperature', 'meridional wind', 'eddy-heat flux'),
    'emf': ('zonal wind', 'meridional wind', 'eddy-momentum flux'),
    'ke': ('eddy-kinetic energy',),
    'ke_tropic': ('barotropic eddy-kinetic energy',),
    'ke_clinic': ('baroclinic eddy-kinetic energy',),
}
units = {
    'ehf': ('K2', 'm2/s2', 'K*m/s'),
    'emf': ('m2/s2', 'm2/s2', 'm2/s2'),
    'ke': ('m2/s2',),
    'ke_tropic': ('m2/s2',),
    'ke_clinic': ('m2/s2',),
}

# Get eddy flux terms
out = None
for flux in ('ehf', 'emf', 'ke', 'ke_tropic', 'ke_clinic'):
    # Get transform
    # if out is not None and flux in out:
    #     print(f'Already have {longs[flux][2]}.')
    #     continue
    # NOTE: Use boxcar so the power is accurate. See climpy.power2d notes
    print(f'Getting {shorts[flux][-1]}.')
    wintype = 'boxcar'
    params_i, longs_i, shorts_i, units_i = (
        params[flux],
        longs[flux],
        shorts[flux],
        units[flux],
    )
    if params_i[0].ndim == 3:
        axes = (0, 2)
        dims = ('f', 'lat', 'k')
    else:
        axes = (0, 3)
        dims = ('f', 'plev', 'lat', 'k')
    ff, kk, spectrum, *powers = climpy.power2d(
        *params[flux],
        dx=dt,
        dy=dlon,
        axes=axes,
        wintype=wintype,
        nperseg=days.size,
        coherence=False,
    )

    # Coordinates
    if out is None:
        f = xr.Variable(
            ('f',), ff, {'long_name': 'frequency', 'units': 'cycles/day'}
        )
        k = xr.Variable(
            ('k',), kk, {'long_name': 'zonal wavenumber', 'units': 'none'}
        )
        out = xr.Dataset(
            {},
            coords={'f': f, 'plev': plev, 'lat': lat, 'k': k},
            attrs=data.attrs,
        )

    # Save to file
    if powers:  # non-empty, i.e. we got a *co*-spectrum
        # Save power spectra, but make sure not to do so twice
        _, P1, P2 = powers
        for i, P in enumerate((P1, P2)):
            if shorts_i[i] not in out:
                long = f'{longs_i[i]} power spectrum'
                out[shorts_i[i] + '_power'] = xr.Variable(
                    dims, P, {'long_name': long, 'units': units_i[i]}
                )
        # And the co-spectrum
        long = f'{longs_i[2]} co-spectrum'
        out[shorts_i[2] + '_power'] = xr.Variable(
            dims, spectrum, {'long_name': long, 'units': units_i[2]}
        )

    else:
        # We just got a power spectrum; save it
        # TODO: Does removing squeeze cause errors?
        # spectrum = spectrum.squeeze()
        long = f'{longs_i[0]} power spectrum'
        out[shorts_i[0] + '_power'] = xr.Variable(
            dims, spectrum, {'long_name': long, 'units': units_i[0]}
        )

    timer(' * Time for spectral transform')  # stuff after power2d takes ms

# Save file
print('Writing to disk.')
if os.path.exists(outname):  # need this, or get permission denied error!
    os.remove(outname)
out.to_netcdf(outname, mode='w')  # specify whether we did chunking
timer(' * Time for writing to disk')
t1 = t0
timer('TOTAL ELAPSED TIME')
