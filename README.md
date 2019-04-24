# Overview
This repository introduces the shell script `ncparallel` for
running an arbitrary script on a NetCDF file **in parallel** by
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
Example usage is as follows:
```bash
ncparallel -d=lat -p=8 -n=8 'command -flag1 -flag2 ...' input.nc output.nc
```
The first argument is the script written as you would call it from the command line
(for example `'./_myscript.py'`), the second argument is the input file, and the
third argument is the output file.
Note that **the script must expect an input file and an output file as arguments**.

The optional flags are as follows:

* `-s`: If passed, silent mode is enabled.
* `-k`: If passed, temporary files are kept (i.e. not deleted).
* `-d=dname`: The dimension name along which we split the file.
* `-n=nfiles`: The number of files to generate.
* `-p=nparallel`: The maximum number of parallel processes. This can be less than `nfiles`.

The default behavior is to divide into `8` files along a latitude
dimension named `lat` and run `8` parallel processes.

