#!/bin/bash

# Set workspace
export WORKSPACE="$(pwd)/../data"
export GRASS_DB="$WORKSPACE/grassdb"
export LOCATION="aberdeenshire_bng"

# Create grassdb directory
mkdir -p "$GRASS_DB"

# Create GRASS location (British National Grid)
grass -c EPSG:27700 "$GRASS_DB/$LOCATION" --exec echo "Location created successfully"
