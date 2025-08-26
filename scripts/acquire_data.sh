#!/bin/sh
# acquire_data.sh

cd "$PROJECT_ROOT"

# Download DEM (example with EU-DEM)
if [ -f "$DATA_DIR/raw/eudem_aberdeenshire.zip" ]; then
  echo "DEM file already exists: $DATA_DIR/raw/eudem_aberdeenshire.zip (skipping download)"
else
  echo "Downloading DEM file..."
  wget -O "$DATA_DIR/raw/eudem_aberdeenshire.zip" \
    "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"
fi

# Download OSM data
if [ -f "$DATA_DIR/raw/scotland-latest.osm.pbf" ]; then
  echo "OSM data already exists: $DATA_DIR/raw/scotland-latest.osm.pbf (skipping download)"
else
  echo "Downloading OSM data..."
  wget -O "$DATA_DIR/raw/scotland-latest.osm.pbf" \
    "https://download.geofabrik.de/europe/united-kingdom/scotland-latest.osm.pbf"
fi

# Extract rivers from OSM
if [ -f "$DATA_DIR/raw/rivers.osm.pbf" ]; then
  echo "Rivers OSM file already exists: $DATA_DIR/raw/rivers.osm.pbf (skipping extraction)"
else
  echo "Extracting rivers from OSM data..."
  osmium tags-filter "$DATA_DIR/raw/scotland-latest.osm.pbf" \
    waterway=river,stream,brook,canal \
    -o "$DATA_DIR/raw/rivers.osm.pbf"
fi

# Convert to shapefile
if [ -f "$DATA_DIR/processed/rivers.shp" ]; then
  echo "Rivers shapefile already exists: $DATA_DIR/processed/rivers.shp (skipping conversion)"
else
  echo "Converting rivers to shapefile..."
  ogr2ogr -f "ESRI Shapefile" "$DATA_DIR/processed/rivers.shp" \
    "$DATA_DIR/raw/rivers.osm.pbf" lines
fi
