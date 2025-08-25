#!/bin/bash

set -e

# Create data directory
mkdir -p data/{raw,processed}

# Download DEM (example with EU-DEM)
wget -O data/raw/eudem_aberdeenshire.zip \
  "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"

# Download OSM data
wget -O data/raw/scotland-latest.osm.pbf \
  "https://download.geofabrik.de/europe/united-kingdom/scotland-latest.osm.pbf"

# Extract rivers from OSM
osmium tags-filter data/raw/scotland-latest.osm.pbf \
  waterway=river,stream,brook,canal \
  -o data/raw/rivers.osm.pbf

# Convert to shapefile
ogr2ogr -f "ESRI Shapefile" data/processed/rivers.shp \
  data/raw/rivers.osm.pbf lines
