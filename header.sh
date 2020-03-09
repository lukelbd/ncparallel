#!/usr/bin/env bash
# Helper functions sourced by main scripts
# Print message to standard error and exit main process
raise() {
  echo "Usage: $usage"
  echo "Error: $1" 1>&2
  exit 1
}

# Wait for background processes to finish and make sure they were successful
pwait() {
  local cmd pids
  cmd="$1"
  pids=("${@:2}")
  for pid in "${pids[@]}"; do
    wait $pid || raise "At least one of the '$cmd' processes failed."
  done
}

