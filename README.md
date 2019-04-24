# Overview
This repository introduces simple shell scripts,
`mppnccombine` and `mppncdivide`, for dividing
and combining existing NetCDF files along an **arbitrary dimension** so that the resulting,
much smaller files can be processed **in parallel** and recombined. This is great where
your computation bottleneck is RAM due to massive file sizes.

This project uses the highly underrated GFDL Flexible Modelling System `mppnccombine.c` tool for
combining datasets along non-record dimensions.
Also see the [`mppnccombine-fast.c`](https://github.com/coecms/mppnccombine-fast) tool developed for the Modular
Ocean Modelling system.

# Usage
A sample script is provided below. The `-d` flag is used to specify the dimension along which
the file is divided, and the `-n` flag is used to specify the number of files into which we want
to divide the input file. The default behavior is to divide into 8 files along the latitude dimension.

```bash
#!/usr/bin/env bash
# Divide
files=($(./mppncdivide -d=lat -n=8 input.nc))
if [ $? -ne 0 ]; then
  echo "Error: mppncdivide failed"
fi
# Next run some command on each file in parallel
# Also store the process IDs so we can use 'wait' to check their exit
# statuses individually!
for file in "${files[@]}"; do
  <command> "$file" &
  pids+=($!)
done
for pid in ${pids[@]}; do
  wait $pid
  if [ $? -ne 0 ]; then
    echo "Error: One of the processes failed."
    rm "${files[@]}" &>/dev/null # cleanup
    exit 1
  fi
done
# Finally combine, and remove the temporary files
./mppnccombine -r output.nc "${files[@]}"
```
