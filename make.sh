#!/usr/bin/env bash
#------------------------------------------------------------------------------#
# Use this file to compile the mppnccombine tool
# Edit the variable as necessary for you system; you should also be
# able to compile with gcc, but this uses the PGI compiler
#------------------------------------------------------------------------------#
# Variables
cpp='pgcc'
links='-L/usr/lib64/mpich/lib'
include='-I/usr/include/mpich-x86_64'
ncflags='-lnetcdff -lnetcdf -lhdf5 -lhdf5_hl' # include netcdf libs
# Compile
$cpp -O -o mppnccombine.x $include $lib $ncflags mppnccombine.c
