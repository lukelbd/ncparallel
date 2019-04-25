#!/usr/bin/env bash
#------------------------------------------------------------------------------#
# Function that waits for background processes to finish, and makes
# sure they were all successful
#------------------------------------------------------------------------------#
pwait() {
  local cmd pids
  cmd="$1"
  pids=("${@:2}")
  for pid in "${pids[@]}"; do
    wait $pid
    if [ $? -ne 0 ]; then
      echo "Error: At least one of the '$cmd' processes failed."
      exit 1
    fi
  done
}

