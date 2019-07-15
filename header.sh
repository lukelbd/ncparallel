#!/usr/bin/env bash
################################################################################
# Helper functions
################################################################################
# Function prints message to standard error and exits main process
raise() {
  echo "Usage: $usage"
  echo "Error: $1" 1>&2
  exit 1
}
# Function that waits for background processes to finish, and makes
# sure they were all successful
pwait() {
  local cmd pids
  cmd="$1"
  pids=("${@:2}")
  for pid in "${pids[@]}"; do
    wait $pid
    [ $? -ne 0 ] && raise "At least one of the '$cmd' processes failed."
  done
}

