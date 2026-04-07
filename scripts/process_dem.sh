#!/bin/sh
# process_dem.sh - New version that delegates to a Python script

set -eu

# Ensure PROJECT_ROOT is set, fallback to finding it
if [ -z "$PROJECT_ROOT" ]; then
  # Find the project root by looking for the .git directory
  CURRENT_DIR=$(pwd)
  while [ "$CURRENT_DIR" != "/" ]; do
    if [ -d "$CURRENT_DIR/.git" ]; then
      PROJECT_ROOT="$CURRENT_DIR"
      break
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
  done
  
  if [ -z "$PROJECT_ROOT" ]; then
    echo "Error: Could not determine PROJECT_ROOT. Please set it manually."
    exit 1
  fi
fi

cd "$PROJECT_ROOT"

echo "Delegating DEM processing to Python script..."

# Call the new Python script that will use the dem_processing module
# The config file can be passed as an argument if needed, e.g.
# python3 scripts/run_dem_processing.py config/default.yaml
python3 scripts/run_dem_processing.py
