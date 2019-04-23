# Parallel processing for large NetCDF files
This repository documents the GFDL Flexible Modelling System `mppnccombine.c` tool for
combining massively parallel-processed NetCDF files output by the model
along the latitude dimension, and introduces a simple shell script `mppncdivide` for dividing
existing NetCDF files along their latitude dimension so that the resulting,
much smaller files can be processed in parallel and recombined with `mppnccombine`.
Also see the
[`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast) tool developed for the Modular
Ocean Modelling system.
