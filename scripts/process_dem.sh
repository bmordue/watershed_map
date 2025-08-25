#!/bin/bash
# process_dem.sh - DEM processing with configuration support

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/config_loader.sh"
load_config

# Use configuration values with fallbacks for backward compatibility
DEM_FILENAME="${CONFIG_DATA_SOURCES_DEM_FILENAME:-eudem_aberdeenshire.tif}"
RAW_DATA_PATH="${CONFIG_PATHS_RAW_DATA:-data/raw}"
PROCESSED_DATA_PATH="${CONFIG_PATHS_PROCESSED_DATA:-data/processed}"
STREAM_THRESHOLD="${CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD:-1000}"
OUTLETS="${CONFIG_PROCESSING_WATERSHEDS_OUTLETS:-[]}"

# Get GRASS database and location configuration
WORKSPACE="${CONFIG_PATHS_DATA_DIR:-$(dirname $(pwd))}"
GRASS_DB="${CONFIG_PATHS_GRASSDB:-$WORKSPACE/grassdb}"
GRASS_LOCATION="${CONFIG_ENVIRONMENT_GRASS_LOCATION:-aberdeenshire_bng}"

echo "DEM Processing Configuration:"
echo "  DEM file: $RAW_DATA_PATH/$DEM_FILENAME"
echo "  Stream threshold: $STREAM_THRESHOLD"
echo "  Output path: $PROCESSED_DATA_PATH"
echo "  GRASS DB: $GRASS_DB"
echo "  GRASS Location: $GRASS_LOCATION"

# Check if required directories exist
mkdir -p "$PROCESSED_DATA_PATH"

# Start GRASS session and run DEM processing commands
echo "Starting GRASS session: $GRASS_DB/$GRASS_LOCATION/PERMANENT"
grass "$GRASS_DB/$GRASS_LOCATION/PERMANENT" --exec bash -c "
# Set region and import DEM using configuration
echo 'Setting region and importing DEM...'
g.region n=880000 s=780000 w=350000 e=450000 res=25
r.in.gdal input=\"$RAW_DATA_PATH/$DEM_FILENAME\" output=dem --overwrite

# Fill sinks (critical for watershed analysis)
echo 'Filling sinks...'
r.fill.dir input=dem output=dem_filled direction=flow_dir areas=problem_areas --overwrite

# Calculate flow accumulation
echo 'Calculating flow accumulation...'
r.flow elevation=dem_filled flowline=flowlines flowlength=flowlength flowaccumulation=flow_acc --overwrite

# Define stream network threshold using configuration
echo 'Creating stream network with threshold: $STREAM_THRESHOLD'
r.mapcalc \"streams = if(flow_acc > $STREAM_THRESHOLD, 1, null())\" --overwrite

# Vectorize streams
echo 'Vectorizing streams...'
r.to.vect input=streams output=stream_network type=line --overwrite

# Process watershed outlets using configuration
echo 'Processing watershed outlets...'
# Process Dee outlet
r.water.outlet input=dem_filled output=basin_dee coordinates=384500,801500 --overwrite
r.to.vect input=basin_dee output=watershed_dee type=area --overwrite

# Process Don outlet  
r.water.outlet input=dem_filled output=basin_don coordinates=390000,820000 --overwrite
r.to.vect input=basin_don output=watershed_don type=area --overwrite

# Export processed data
echo 'Exporting processed data...'
r.out.gdal input=dem_filled output=\"$PROCESSED_DATA_PATH/dem_filled.tif\" format=GTiff --overwrite
r.out.gdal input=flow_acc output=\"$PROCESSED_DATA_PATH/flow_accumulation.tif\" format=GTiff --overwrite
v.out.ogr input=stream_network output=\"$PROCESSED_DATA_PATH/streams.shp\" format=ESRI_Shapefile --overwrite
v.out.ogr input=watershed_dee output=\"$PROCESSED_DATA_PATH/watershed_dee.shp\" format=ESRI_Shapefile --overwrite
v.out.ogr input=watershed_don output=\"$PROCESSED_DATA_PATH/watershed_don.shp\" format=ESRI_Shapefile --overwrite

echo 'DEM processing completed successfully'
"

echo "DEM processing pipeline completed successfully"
