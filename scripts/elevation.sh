# Download EU-DEM (25m resolution)
wget "https://cloud.sddi.gov.uk/s/obZAZzLTGYebFex/download"

# Or use SRTM data via GDAL
gdal_translate -of GTiff -co COMPRESS=LZW \
  "/vsizip//vsicurl/https://cloud.sddi.gov.uk/index.php/s/X1PGfhPINz2LRjT" \
  srtm_aberdeenshire.tif
