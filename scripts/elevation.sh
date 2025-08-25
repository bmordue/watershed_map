# Download EU-DEM (25m resolution)
if [ -f "download" ]; then
  echo "EU-DEM file already exists: download (skipping download)"
else
  echo "Downloading EU-DEM..."
  wget "https://cloud.sddi.gov.uk/s/obZAZzLTGYebFex/download"
fi

# Or use SRTM data via GDAL
if [ -f "srtm_aberdeenshire.tif" ]; then
  echo "SRTM file already exists: srtm_aberdeenshire.tif (skipping download)"
else
  echo "Downloading SRTM data..."
  gdal_translate -of GTiff -co COMPRESS=LZW \
    "/vsizip//vsicurl/https://cloud.sddi.gov.uk/index.php/s/X1PGfhPINz2LRjT" \
    srtm_aberdeenshire.tif
fi
