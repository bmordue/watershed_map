#!/bin/sh
# elevation.sh

# Change to the project root directory
cd "$PROJECT_ROOT"

# Download EU-DEM (25m resolution)
if [ -f "$DATA_DIR/raw/eu_dem.tif" ]; then
  echo "EU-DEM file already exists: $DATA_DIR/raw/eu_dem.tif (skipping download)"
else
  echo "Downloading EU-DEM..."
  wget "https://cloud.sddi.gov.uk/s/obZAZzLTGYebFex/download" -O "$DATA_DIR/raw/eu_dem.tif"
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
