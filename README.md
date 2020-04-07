# What
This repository introduces the shell command `ncparallel` for
running arbitrary commands on NetCDF files in parallel by
dividing and combining files along arbitrary dimensions.
We use the GFDL Flexible Modelling System `mppnccombine.c` tool for combining datasets along non-record dimensions
(also see the [`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast)
tool developed for the Modular Ocean Modelling system).

# Why
Using this tool won't always result in a speedup. For relatively fast
commands, the overhead of creating a bunch of temporary NetCDF
files can exceed the original command execution time.

However, this tool is exceedingly useful in two situations:

1. For very slow, laborious processes, the parallelization will result in a very obvious speedup.
2. For very large files, e.g. file sizes approaching or greater than the available RAM, your computer may run out of memory and have to use the hard disk for "virtual" RAM. This significantly slows down the process and can grind hard disk access to a crawl, getting in the way of other processes. With this tool, you can use the `-p` and `-n` flags to serially process the file in chunks, eliminating the memory bottleneck.
<!-- This is great where your computation bottleneck is RAM due to large file sizes. -->

# Installation
Download this repository with
```bash
cd $HOME && git clone https://github.com/lukelbd/ncparallel
```
and add the resulting folder to your `PATH` by adding the line
```bash
export PATH="$HOME/ncparallel:$PATH"
```
to your shell configuration file, usually named `$HOME/.bashrc` or `$HOME/.bash_profile`. If the file
does not exist, you can create it, and its contents should be run every time you open up a terminal.

# Usage
Example usage is as follows:
```bash
ncparallel -d=lat -p=8 -n=32 command input1.nc [input2.nc ... inputN.nc] output.nc
```
The first positional argument is the command written as you would type it into the command line -- for example, `./script.sh`, `'python script.py'`, or `'ncap2 -s "math-goes-here"'`. Note that the command must be surrounded by quotes if it consists of more than one word.
The final positional arguments are the input file name(s) and the output file name.
<!-- The command must accept two positional arguments: An input file name, and an output file name. -->

For input file(s) named `input1.nc`, `input2.nc`, etc. and an output file named `output.nc`, parallel processing is achieved as follows:

1. Each input file `inputN.nc` is split up along some dimension into chunks, in this case named `inputN.0000.nc`, `inputN.0001.nc`, etc.
2. The input command is called on the file chunks serially or in parallel (depending on the value passed to `-p`), in this case with  `command input1.0000.nc [input2.0000.nc ... inputN.0000.nc] output.0000.nc`, etc.
3. The resulting output files are combined along the same dimension into the requested output file name, in this case `output.nc`.

The optional arguments are as follows:

* `-d=NAME`: The dimension name along which we split the file. Defaults to `lat`.
* `-n=NUM`: The number of file chunks to generate. Defaults to `8`.
* `-p=NUM`: The maximum number of parallel processes. Defaults to the `-n` argument but can also be smaller.

If you do not want parallel processing and instead just want to
split up the file into more manageable chunks for your available RAM,
simply use `-p=1`.
As explained above, this is very useful
when your command execution time is limited by available memory.

The flags are as follows:

* `-h`: Print help information.
* `-r`: If passed, the output file comes before in the input file(s), rather than after.
* `-f`: If passed and dimension is has unlimited length, it is changed to fixed length.
* `-s`: If passed, silent mode is enabled.
* `-k`: If passed, temporary files are not deleted.

<!-- large file sizes, i.e. -->
<!-- for your command, -->
<!-- your file size is such that
   - the bottleneck in your execution time is due to memory limitations. -->


# Performance

Seeing is believing. The below shows performance metrics for longitude-time Randel
and Held (1991) spectral decompositions of a 400MB file with 64 latitudes
on a high-performance server with 32 cores and 32GB of RAM.

This task is very computationally intensive, and the server is well-suited for
parallelization, so `ncparallel` delivers an obvious speedup. In this case,
the optimal performance was reached by splitting up the latitude dimension
into 16 chunks and running the 16 processes in parallel. Restricting the number
of parallel processes only resulted in a speedup for 64 chunks,
and splitting up the file into more chunks produced diminishing returns.
The optimal performance for you will depend on your data, your code,
and your system architecture.

```sh
```

