#!/bin/sh
# acquire_data.sh

cd "$PROJECT_ROOT"

# Download DEM (Copernicus GLO-30)
if [ -f "$DATA_DIR/raw/copdem_glo30_aberdeenshire.tif" ]; then
  echo "DEM file already exists: $DATA_DIR/raw/copdem_glo30_aberdeenshire.tif (skipping download)"
else
  echo "Downloading Copernicus GLO-30 DEM file..."
  wget -q -O "$DATA_DIR/raw/copdem_glo30_aberdeenshire.tif" \
    "https://dataspace.copernicus.eu/browser/download/COP-DEM_GLO-30_DGED__20210329T000000_20210329T235959_sample_aberdeenshire.tif"
fi

# Download OSM data
if [ -f "$DATA_DIR/raw/scotland-latest.osm.pbf" ]; then
  echo "OSM data already exists: $DATA_DIR/raw/scotland-latest.osm.pbf (skipping download)"
else
  echo "Downloading OSM data..."
  wget -q -O "$DATA_DIR/raw/scotland-latest.osm.pbf" \
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
