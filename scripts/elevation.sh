#!/bin/sh
# elevation.sh - Alternative elevation data download script
# 
# This script provides an alternative way to download elevation data,
# including both the primary source (configured DEM) and backup SRTM data.
# This is separate from acquire_data.sh to allow for standalone elevation
# data operations without downloading the full dataset.

# Change to the project root directory
cd "$PROJECT_ROOT"

# Load configuration values
DEM_URL=$(yq '.data_sources.dem.url' config/default.yaml)
DEM_FILENAME=$(yq '.data_sources.dem.filename' config/default.yaml)
DEM_SOURCE=$(yq '.data_sources.dem.source' config/default.yaml)

# Download primary DEM from configuration
if [ -f "$DATA_DIR/raw/$DEM_FILENAME" ]; then
  echo "$DEM_SOURCE DEM file already exists: $DATA_DIR/raw/$DEM_FILENAME (skipping download)"
else
  echo "Downloading $DEM_SOURCE DEM..."
  wget "$DEM_URL" -O "$DATA_DIR/raw/$DEM_FILENAME"
fi

# Or use SRTM data via GDAL
if [ -f "$DATA_DIR/raw/srtm_aberdeenshire.tif" ]; then
  echo "SRTM file already exists: $DATA_DIR/raw/srtm_aberdeenshire.tif (skipping download)"
else
  echo "Downloading SRTM data..."
  gdal_translate -of GTiff -co COMPRESS=LZW \
    "/vsizip//vsicurl/https://cloud.sddi.gov.uk/index.php/s/X1PGfhPINz2LRjT" \
    "$DATA_DIR/raw/srtm_aberdeenshire.tif"
fi
