# What
This repository introduces the shell script `ncparallel` for
running an arbitrary script on a NetCDF file **in parallel** by
dividing and combining the NetCDF file along an **arbitrary dimension**.
This project uses the highly underrated GFDL Flexible Modelling System `mppnccombine.c` tool for combining datasets along non-record dimensions.
Also see the [`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast) tool developed for the Modular
Ocean Modelling system.

# Why
Using this tool won't always result in a speedup. For relatively fast
scripts, the overhead of creating a bunch of temporary NetCDF
files can exceed the original script computation time.

However, this tool is exceedingly useful in two situations:

1. For very slow, laborious scripts, performing the computation in parallel will result in a very obvious speedup.
2. For enormous files, e.g. file sizes approaching or greater than the available RAM, your computer may run out of memory and have to use the hard disk for "virtual" RAM. This gets incredibly slow and will also grind the computer to a crawl, getting in the way of other processes. With this tool, you can use the `-p` and `-n` flags (see below for details) to serially process the file in chunks, eliminating this memory bottleneck.
<!-- This is great where your computation bottleneck is RAM due to large file sizes. -->

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

* `-d=<>`: The dimension name along which we split the file. Defaults to `lat`.
* `-n=<>`: The number of file pieces to generate. Defaults to `8`.
* `-p=<>`: The maximum number of parallel processes. Defaults to the `-n` argument but can also be smaller.
* `-f`: If passed and dimension is a "record" (i.e. unlimited) dimension, it is changed to fixed length.
* `-s`: If passed, silent mode is enabled.
* `-k`: If passed, temporary files are not deleted.

The first positional argument is the script or command written as you would type it into the command line
(for example, `'python myscript.py'` or `'ncap2 -s "math-goes-here"'`; note the quotation marks),
the second argument is the input file, and the
third argument is the output file.

Parallel processing is achieved by splitting
the input file along some dimension into pieces named (in this case) `input.0000.nc`, `input.0001.nc`, etc.,
calling the input script with (in this case) `script input.0000.nc output.0000.nc`
for each piece, then combining the resulting `output.0000.nc`, `output.0001.nc`, etc. files and deleting the remnants.
Note that the script must accept an input file and an output file as arguments.

If you do not want parallel processing and instead just want to 
split up the file into more manageable pieces for your script,
simply use `-n=1`.
As explained above, this is very useful for large file sizes, i.e.
when your script execution time is limited by available memory.
<!-- your file size is such that
   - the bottleneck in your execution time is due to memory limitations. -->

