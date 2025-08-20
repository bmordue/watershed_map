#!/bin/bash
# acquire_data.sh

# Create data directory
DATA_DIR=../data
mkdir -p $DATA_DIR/{raw,processed}

# Download DEM (example with EU-DEM)
wget -O $DATA_DIR/raw/eudem_aberdeenshire.zip \
  "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"

# Download OSM data
wget -O $DATA_DIR/raw/scotland-latest.osm.pbf \
  "https://download.geofabrik.de/europe/great-britain/scotland-latest.osm.pbf"

# Extract rivers from OSM
osmium tags-filter $DATA_DIR/raw/scotland-latest.osm.pbf \
  waterway=river,stream,brook,canal \
  -o $DATA_DIR/raw/rivers.osm.pbf

# Convert to shapefile
ogr2ogr -f "ESRI Shapefile" $DATA_DIR/processed/rivers.shp \
  $DATA_DIR/raw/rivers.osm.pbf lines
