# Overview
This repository introduces simple shell scripts,
`nccombine` and `ncdivide`, for dividing
and combining existing NetCDF files along an **arbitrary dimension** so that the resulting,
much smaller files can be processed **in parallel** and recombined. This is great where
your computation bottleneck is RAM due to massive file sizes.

This project uses the highly underrated GFDL Flexible Modelling System `mppnccombine.c` tool for
combining datasets along non-record dimensions.
Also see the [`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast) tool developed for the Modular
Ocean Modelling system.

# Usage
Download this utility with `cd $HOME && git clone https://github.com/lukelbd/ncparallel`, and add the `nccombine` and
`ncdivide` scripts to your path by adding the line `export PATH="$HOME/ncparallel:$PATH"` to your shell configuration
files (usually named `$HOME/.bashrc` or `$HOME/.bash_profile`; if it does not exist, you can create it, and its
contents should be run every time you open up a terminal).

The below sample script demonstrates how to use this tool. For `ncdivide`, the `-d` flag is used to specify the dimension along which
the file is divided, and the `-n` flag is used to specify the number of files into which we want
to divide the input file. For `nccombine`, the first argument is the destination file, the next arguments
are the input files,
and the `-r` flag tells the script to remove the input files after they
are combined.

The default `ncdivide` behavior is to divide into `8` files along a latitude
dimension named `lat`. The default `nccombine` behavior is to not remove the input files.

```bash
#!/usr/bin/env bash
# Divide into smaller files and collect names in a bash array
# Format will be input.0000.nc, input.0001.nc, etc.
files=($(./ncdivide -d=lat -n=8 input.nc))
[ $? -ne 0 ] && echo "Error: ncdivide failed." && exit 1

# Generate background processes for each file, for example a python script
# that creates a new NetCDF file from some input NetCDF file.
# WARNING: Make sure that your command preserves the 'domain_decomposition' dimension
# attribute and 'NumFilesInSet' global attribute on the output NetCDF file!
for file in "${files[@]}"; do
  output="output.${file#*.}" # e.g. if 'file' is input.0000.nc, becomes output.0000.nc
  <command> "$file" "$output" & # trailing ampersand sends process to background
  outputs+=("$output") # store output files in a bash array
  pids+=($!) # store process IDs in another bash array
done

# Wait for background processes to finish, and make sure they were all successful
for pid in ${pids[@]}; do
  wait $pid
  if [ $? -ne 0 ]; then
    echo "Error: One of the processes failed."
    rm "${files[@]}" &>/dev/null # cleanup
    exit 1
  fi
done

# Finally combine, and remove the temporary files
# generated for parallel processing
rm "${files[@]}"
./nccombine -r output.nc "${outputs[@]}"
[ $? -ne 0 ] && echo "Error: nccombine failed." && exit 1
```
