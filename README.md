# Overview
This repository introduces simple shell scripts,
`ncparallel`, `nccombine`, `ncdivide`, for 
running an arbitrary script or function on a NetCDF file **in parallel** by
dividing and combining the NetCDF file along an **arbitrary dimension**.
This is great where your computation bottleneck is RAM due to large file sizes.

This project uses the highly underrated GFDL Flexible Modelling System `mppnccombine.c` tool for
combining datasets along non-record dimensions.
Also see the [`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast) tool developed for the Modular
Ocean Modelling system.

# Installation
Download this utility with
```bash
cd $HOME && git clone https://github.com/lukelbd/ncparallel
```
and add the project to your path by adding the line
```bash
export PATH="$HOME/ncparallel:$PATH"
```
to your shell configuration file, usually named `$HOME/.bashrc` or `$HOME/.bash_profile`. If the file
does not exist, you can create it, and its contents should be run every time you open up a terminal.

# Usage
The usage is as follows:
```bash
ncparallel -r -d=lat -n=8 'command -flag1 -flag2' input.nc output.nc
```
The first argument is the script written as you would call it from the command line,
for example `'./get_fluxes.py'`.
Note that **the script must expect two arguments**: an input file, and an output file.
The second and third arguments are the input and output files.

The `-r` flag says to remove all temporary files.
The `-d` flag is used to specify the dimension along which
the file is divided. The `-n` flag is used to specify the number of files into which we want
to divide the input file.
The default behavior is to divide into `8` files along a latitude
dimension named `lat`, and to not remove any temporary files.

