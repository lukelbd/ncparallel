#!/usr/bin/env bash
#------------------------------------------------------------------------------#
# Use this file to compile the mppnccombine tool
# Edit the variable as necessary for you system; you should also be
# able to compile with gcc, but this uses the PGI compiler
#------------------------------------------------------------------------------#
# Server
# cpp='pgcc'
# include='-I/usr/include/mpich-x86_64'
# ncflags='-lnetcdff -lnetcdf -lhdf5 -lhdf5_hl' # include netcdf libs
# Macbook
cpp='pgcc'
include='-I/usr/include/mpich-x86_64'
ncflags='-lnetcdff -lnetcdf -lhdf5 -lhdf5_hl' # include netcdf libs
# Compile
$cpp -O -o mppnccombine.x $include $lib $ncflags mppnccombine.c
