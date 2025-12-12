#!/bin/sh
# acquire_data.sh

cd "$PROJECT_ROOT"

# Ensure data directories exist
mkdir -p "$DATA_DIR/raw" "$DATA_DIR/processed"

# Load configuration values
DEM_URL=$(yq '.data_sources.dem.url' config/default.yaml)
DEM_FILENAME=$(yq '.data_sources.dem.filename' config/default.yaml)
DEM_SOURCE=$(yq '.data_sources.dem.source' config/default.yaml)

# Download DEM using configuration
if [ -f "$DATA_DIR/raw/$DEM_FILENAME" ]; then
  echo "DEM file already exists: $DATA_DIR/raw/$DEM_FILENAME (skipping download)"
else
  echo "Downloading $DEM_SOURCE DEM file..."
  if ! wget -q -O "$DATA_DIR/raw/$DEM_FILENAME" "$DEM_URL"; then
    echo "ERROR: Failed to download DEM file from $DEM_URL" >&2
    echo "This may be due to network restrictions in CI/sandboxed environments." >&2
    echo "Please provide the DEM file manually or use mock data for testing." >&2
    rm -f "$DATA_DIR/raw/$DEM_FILENAME"  # Remove potentially corrupt/partial file
    exit 1
  fi
  echo "DEM file downloaded successfully: $DATA_DIR/raw/$DEM_FILENAME"
fi

# Download OSM data
OSM_URL=$(yq '.data_sources.osm.url' config/default.yaml)
OSM_FILENAME=$(yq '.data_sources.osm.filename' config/default.yaml)

if [ -f "$DATA_DIR/raw/$OSM_FILENAME" ]; then
  echo "OSM data already exists: $DATA_DIR/raw/$OSM_FILENAME (skipping download)"
else
  echo "Downloading OSM data..."
  if ! wget -q -O "$DATA_DIR/raw/$OSM_FILENAME" "$OSM_URL"; then
    echo "WARNING: Failed to download OSM data from $OSM_URL" >&2
    echo "Continuing without OSM data..." >&2
    rm -f "$DATA_DIR/raw/$OSM_FILENAME"  # Remove potentially corrupt/partial file
  else
    echo "OSM data downloaded successfully: $DATA_DIR/raw/$OSM_FILENAME"
  fi
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
