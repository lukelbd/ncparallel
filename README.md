# Overview
This repository introduces the shell script `ncparallel` for
running an arbitrary script on a NetCDF file **in parallel** by
dividing and combining the NetCDF file along an **arbitrary dimension**.
<!-- This is great where your computation bottleneck is RAM due to large file sizes. -->

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
ncparallel -d=lat -p=8 -n=32 script input.nc output.nc
```
Flags are as follows:

* `-s`: If passed, silent mode is enabled.
* `-k`: If passed, temporary files are not deleted.
* `-d=<>`: The dimension name along which we split the file.
* `-n=<>`: The number of file pieces to generate.
* `-p=<>`: The maximum number of parallel processes. This defaults to the `-n` argument but can also be smaller.

The first positional argument is the script written as you would call it from the command line
(for example `'./myscript.py'`), the second argument is the input file, and the
third argument is the output file. Note that **the script must accept an input file and an output file as arguments**.

Parallel processing is achieved by splitting
the input file along some dimension into pieces named (in this case) `input.0000.nc`, `input.0001.nc`, etc.,
calling the input script with (in this case) `script input.0000.nc output.0000.nc`
for each piece, then combining the resulting `output.0000.nc`, `output.0001.nc`, etc. files and deleting the remnants.

If you do not want parallel processing and instead just want to 
split up the file into more manageable pieces for your script,
simply use `-n=1`. This can be very useful for large file sizes!

