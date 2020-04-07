#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
# Use this to benchmark processes
#-----------------------------------------------------------------------------#
# Directory with sample data
cwd=${0%/*}
log=$cwd/benchmarks.log
dir=/mdata1/ldavis/hs1_base_t42l20s/netcdf
file=$dir/2xdaily_inst_full.d00500-d00600.nc
script=$cwd/spectra.py
# script=$cwd/fluxes.py
export TIMEFORMAT=$'real %0Rs user %0Us sys %0Ss (%P%%)'

# Dimension and splits
# Perhaps parallel along pressure is faster?
dimname=plev
nsplits="1 2 4 10 20"
# dimname=lat
# nsplits="1 2 4 8 16 32 64"

# Loop through numbers of processors *and* number of parallel files
# NOTE: Passing -n=1 to program just
# for n in 64; do
# for n in 4 8 16 32; do
{
  echo "Sample file: $file"
  echo "Sample script: $script"
  echo "Splitting along: $dimname"
  for n in $nsplits; do
    p=$n
    echo
    echo "Number of files: $n"
    while [ $p -gt 0 ]; do
      echo "Parallelization: $p"
      time {
        for _ in {1..5}; do  # repeat to get more robust estimate
          ncparallel -p=$p -n=$n -d=$dimname \
            "python $script" $file $dir/tmp.nc &>/dev/null
        done
      }
      p=$((p / 2))
    done
  done
} 2>&1 | tee -a "$log"
