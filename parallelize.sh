#!/usr/bin/env bash
#------------------------------------------------------------------------------#
# Pass this function an arbitrary command with an arbitrary NetCDF
# file argument, and it will parallelize that process along the
# latitude dimension
# TODO: Also offer parallelizing in time? This would be better since time
# dimension is leftmost, right?
#------------------------------------------------------------------------------#
# First generate files
files=($(./mppncdivide "$@"))
if [ $? -ne 0 ]; then
  echo "Error: mppncdivide failed"
fi
# Next run some command on each file in parallel
# Insert command here
for file in "${files[@]}"; do
  command "$file" &
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
# Finally run
./mppnccombine.x -r result.nc ${files[@]}
