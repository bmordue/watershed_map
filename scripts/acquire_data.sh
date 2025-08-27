#!/bin/sh
# acquire_data.sh

cd "$PROJECT_ROOT"

# Load configuration values
DEM_URL=$(yq '.data_sources.dem.url' config/default.yaml)
DEM_FILENAME=$(yq '.data_sources.dem.filename' config/default.yaml)
DEM_SOURCE=$(yq '.data_sources.dem.source' config/default.yaml)

# Download DEM using configuration
if [ -f "$DATA_DIR/raw/$DEM_FILENAME" ]; then
  echo "DEM file already exists: $DATA_DIR/raw/$DEM_FILENAME (skipping download)"
else
  echo "Downloading $DEM_SOURCE DEM file..."
  wget -q -O "$DATA_DIR/raw/$DEM_FILENAME" "$DEM_URL"
fi

# Download OSM data
OSM_URL=$(yq '.data_sources.osm.url' config/default.yaml)
OSM_FILENAME=$(yq '.data_sources.osm.filename' config/default.yaml)

if [ -f "$DATA_DIR/raw/$OSM_FILENAME" ]; then
  echo "OSM data already exists: $DATA_DIR/raw/$OSM_FILENAME (skipping download)"
else
  echo "Downloading OSM data..."
  wget -q -O "$DATA_DIR/raw/$OSM_FILENAME" "$OSM_URL"
fi

# Extract rivers from OSM
if [ -f "$DATA_DIR/raw/rivers.osm.pbf" ]; then
  echo "Rivers OSM file already exists: $DATA_DIR/raw/rivers.osm.pbf (skipping extraction)"
else
  echo "Extracting rivers from OSM data..."
  osmium tags-filter "$DATA_DIR/raw/$OSM_FILENAME" \
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
