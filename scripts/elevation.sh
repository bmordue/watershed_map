#!/bin/sh
# elevation.sh

# Change to the project root directory
cd "$PROJECT_ROOT"

# Download Copernicus GLO-30 DEM (30m resolution)
if [ -f "$DATA_DIR/raw/copdem_glo30.tif" ]; then
  echo "Copernicus GLO-30 DEM file already exists: $DATA_DIR/raw/copdem_glo30.tif (skipping download)"
else
  echo "Downloading Copernicus GLO-30 DEM..."
  wget "https://dataspace.copernicus.eu/browser/download/COP-DEM_GLO-30_DGED__20210329T000000_20210329T235959_sample.tif" -O "$DATA_DIR/raw/copdem_glo30.tif"
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
