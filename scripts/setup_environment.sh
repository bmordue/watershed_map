#!/bin/bash
# setup_environment.sh

# Set workspace
export WORKSPACE=".."
export GRASS_DB="$WORKSPACE/grassdb"
export LOCATION="aberdeenshire_bng"

# Create GRASS location (British National Grid)
grass78 -c EPSG:27700 "$GRASS_DB/$LOCATION"
