#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
# Run the benchmark tests
#-----------------------------------------------------------------------------#
# Sample data
cwd=${0%/*}
cd "$cwd" || exit 1
log=./run.log
input=/mdata1/ldavis/hs1_base_t42l20s/netcdf/tmp_big.nc
output=/mdata1/ldavis/hs1_base_t42l20s/netcdf/tmp_big_result.nc
# input="../test.nc"
# output="../tmp.nc"
[ -r "$input" ] || echo "Input '$input' not found."
[ -d "${output%/*}" ] || echo "Output dir '${output%/*}' not found."

# Sample commands
# cmd='python ./xarray.py'
# cmd='python ./spectra.py'
cmd='python ./netcdf4.py'
nrepeat=1  # number of repeats

# Dimension and splits
# Perhaps parallel along pressure is faster?
# dimname=plev
# nsplits="2"
# nsplits="1 2 4 10 20"
# nsplits="1 64"
dimname=lat
nsplits="2 4 8 16 32 1"

# Function that loops through numbers of processors *and* parallel files
echoerr() {
  echo "$@" >&2
}
benchmark() {
  export TIMEFORMAT=$'real %0Rs user %0Us sys %0Ss'
  echoerr "Sample command: $1"
  echoerr "Sample file: $input"
  echoerr "Splitting along: $dimname"
  for n in $nsplits; do
    p=$n
    # [ $p -gt 1 ] && p=$((p / 2))
    echoerr
    echoerr "Number of files: $n"
    while [ $p -gt 0 ]; do
      echo  # space only for me
      echoerr "Parallelization: $p"
      time {
        for _ in $(seq 1 $nrepeat); do
          ncparallel -k -p=$p -n=$n -d=$dimname \
            "$1" "$input" "$output" 2>&1 \
            || { echoerr "Parallel command failed."; exit 1; }
        done
      }
      p=$((p / 2))
    done
  done
}

# Benchmark intensive operations, save only our special messages while printing
# See: https://stackoverflow.com/a/692407/4970632
benchmark "$cmd" 1> >(cat) 2> >(tee -a "$log" >&2)

# Benchmark simply the divide and combine parts
# benchmark cp
