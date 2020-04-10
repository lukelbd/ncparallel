#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
# Use this to benchmark processes
#-----------------------------------------------------------------------------#
# Directory with sample data
cwd=${0%/*}
cd "$cwd" || exit 1
log=./benchmarks.log
input="/mdata1/ldavis/hs1_base_t42l20s/netcdf/tmp_big.nc"
output="/mdata1/ldavis/hs1_base_t42l20s/netcdf/tmp_big_result.nc"
script="./netcdf4.py"
# input="../test.nc"
# output="../tmp.nc"
# script="./xarray.py"
# script="./spectra.py"
[ -r "$input" ] || echo "Input $input not found."
[ -d "${output%/*}" ] || echo "Output dir ${output%/*} not found."
export TIMEFORMAT=$'real %0Rs user %0Us sys %0Ss'

# Dimension and splits
# Perhaps parallel along pressure is faster?
# dimname=plev
# nsplits="1 2 4 10 20"
dimname=lat
# nsplits="2"
# nsplits="1 64"
nsplits="2 4 8 16 32 1"
# rm "$log" 2>/dev/null

# Function that loops through numbers of processors *and* parallel files
# NOTE: Passing -n=1 to program just
# for n in 64; do
# for n in 4 8 16 32; do
echo2() { echo "$@" >&2; }
benchmark() {
  local cmd
  cmd="$1"
  echo2 "Sample file: $input"
  echo2 "Sample command: $cmd"
  echo2 "Splitting along: $dimname"
  for n in $nsplits; do
    p=$n
    # [ $p -gt 1 ] && p=$((p / 2))
    echo2
    echo2 "Number of files: $n"
    while [ $p -gt 0 ]; do
      echo  # space only for me
      echo2 "Parallelization: $p"
      time {
        # for _ in {1..3}; do  # repeat to get more robust estimate
        for _ in 1; do  # no repeat
          ncparallel -k -p=$p -n=$n -d=$dimname \
            "$cmd" "$input" "$output" 2>&1 \
            || { echo2 "Parallel command failed."; exit 1; }
        done
      }
      p=$((p / 2))
    done
  done
}

# Benchmark simply the divide and combine parts
# benchmark cp

# Benchmark intensive operations, save only our special messages while
# printing
# See: https://stackoverflow.com/a/692407/4970632
benchmark "python $script" 1> >(cat) 2> >(tee -a "$log" >&2)
