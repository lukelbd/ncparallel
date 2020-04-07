#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
# Use this to benchmark processes
#-----------------------------------------------------------------------------#
# Directory with sample data
cwd=${0%/*}
cd "$cwd" || exit 1
log=./benchmarks.log
input="../test.nc"
output="../tmp.nc"
script="./spectra.py"
# script="./fluxes.py"
export TIMEFORMAT=$'real %0Rs user %0Us sys %0Ss'

# Dimension and splits
# Perhaps parallel along pressure is faster?
dimname=plev
nsplits="1 2 4 10 20"
# dimname=lat
# nsplits="1 2 4 8 16 32 64"
# rm "$log" 2>/dev/null

# Function that loops through numbers of processors *and* parallel files
# NOTE: Passing -n=1 to program just
# for n in 64; do
# for n in 4 8 16 32; do
benchmark() {
  local cmd
  cmd="$1"
  echo "Sample file: $input"
  echo "Sample command: $cmd"
  echo "Splitting along: $dimname"
  for n in $nsplits; do
    p=$n
    echo
    echo "Number of files: $n"
    while [[ $n -gt 1 && $p -gt 1 ]] || [[ $p -gt 0 ]]; do
      echo "Parallelization: $p"
      time {
        # for _ in 1; do  # no repeat
        for _ in {1..3}; do  # repeat to get more robust estimate
          ncparallel -p=$p -n=$n -d=$dimname \
            "$cmd" "$input" "$output" &>/dev/null \
            || { echo "Parallel command failed."; exit 1; }
        done
      }
      p=$((p / 2))
    done
  done
}

# Benchmark simply the divide and combine parts
# benchmark cp 2>&1 | tee -a "$log"

# Benchmark intensive operations
benchmark "python $script" 2>&1 | tee -a "$log"
