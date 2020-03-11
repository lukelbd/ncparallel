#!/usr/bin/env bash
# Helper functions sourced by main scripts
# Print message to standard error and exit main process
raise() {
  echo "Usage: $usage"
  echo "Error: $*" 1>&2
  exit 1
}

# Wait for background processes to finish and make sure they were successful
pwait() {
  for pid in "${@:2}"; do
    wait $pid || raise "At least one of the '$1' processes failed."
  done
}
