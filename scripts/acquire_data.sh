#!/bin/sh
# acquire_data.sh

# Change to the project root directory
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

# Create data directory
mkdir -p data/{raw,processed}

# Download DEM (example with EU-DEM)
if [ -f "data/raw/eudem_aberdeenshire.zip" ]; then
  echo "DEM file already exists: data/raw/eudem_aberdeenshire.zip (skipping download)"
else
  echo "Downloading DEM file..."
  wget -O data/raw/eudem_aberdeenshire.zip \
    "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"
fi

# Download OSM data
if [ -f "data/raw/scotland-latest.osm.pbf" ]; then
  echo "OSM data already exists: data/raw/scotland-latest.osm.pbf (skipping download)"
else
  echo "Downloading OSM data..."
  wget -O data/raw/scotland-latest.osm.pbf \
    "https://download.geofabrik.de/europe/great-britain/scotland-latest.osm.pbf"
fi

# Extract rivers from OSM
if [ -f "data/raw/rivers.osm.pbf" ]; then
  echo "Rivers OSM file already exists: data/raw/rivers.osm.pbf (skipping extraction)"
else
  echo "Extracting rivers from OSM data..."
  osmium tags-filter data/raw/scotland-latest.osm.pbf \
    waterway=river,stream,brook,canal \
    -o data/raw/rivers.osm.pbf
fi

# Convert to shapefile
if [ -f "data/processed/rivers.shp" ]; then
  echo "Rivers shapefile already exists: data/processed/rivers.shp (skipping conversion)"
else
  echo "Converting rivers to shapefile..."
  ogr2ogr -f "ESRI Shapefile" data/processed/rivers.shp \
    data/raw/rivers.osm.pbf lines
fi
