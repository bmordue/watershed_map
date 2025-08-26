#!/bin/sh
# process_dem.sh - DEM processing with configuration support

set -euo pipefail

# Change to the project root directory
cd "$PROJECT_ROOT"

# Load configuration
source "$PROJECT_ROOT/lib/config_loader.sh"
load_config

# Use configuration values with fallbacks for backward compatibility
DEM_FILENAME="${CONFIG_DATA_SOURCES_DEM_FILENAME:-eudem_aberdeenshire.tif}"
RAW_DATA_PATH="${CONFIG_PATHS_RAW_DATA:-data/raw}"
PROCESSED_DATA_PATH="${CONFIG_PATHS_PROCESSED_DATA:-data/processed}"
STREAM_THRESHOLD="${CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD:-1000}"
OUTLETS="${CONFIG_PROCESSING_WATERSHEDS_OUTLETS:-[]}"

echo "DEM Processing Configuration:"
echo "  DEM file: $RAW_DATA_PATH/$DEM_FILENAME"
echo "  Stream threshold: $STREAM_THRESHOLD"
echo "  Output path: $PROCESSED_DATA_PATH"

# Check if required directories exist
mkdir -p "$PROCESSED_DATA_PATH"

# Check if major output files already exist to avoid reprocessing
WATERSHED_FILES_EXIST=false
if [ -f "$PROCESSED_DATA_PATH/watershed_dee.shp" ] && [ -f "$PROCESSED_DATA_PATH/watershed_don.shp" ]; then
  echo "Watershed shapefiles already exist (skipping DEM processing)"
  WATERSHED_FILES_EXIST=true
fi

# Only run processing if output files don't exist
if [ "$WATERSHED_FILES_EXIST" = false ]; then
  echo "Starting DEM processing..."
  
  # Start GRASS session - using configurable location name
  GRASS_LOCATION="${CONFIG_ENVIRONMENT_GRASS_LOCATION:-aberdeenshire_bng}"
  grass "$GRASS_DB/$GRASS_LOCATION/PERMANENT"

# Set region and import DEM using configuration
g.region -s raster=eudem_aberdeenshire
r.in.gdal input="$RAW_DATA_PATH/$DEM_FILENAME" output=dem

# Fill sinks (critical for watershed analysis)
r.fill.dir input=dem output=dem_filled direction=flow_dir areas=problem_areas

# Alternative: use Wang & Liu algorithm for better sink filling
r.terraflow elevation=dem filled=dem_filled direction=flow_dir \
  swatershed=watersheds accumulation=flow_acc

# Calculate flow accumulation
r.flow elevation=dem_filled flowline=flowlines flowlength=flowlength \
  flowaccumulation=flow_acc

# Define stream network threshold using configuration
r.mapcalc "streams = if(flow_acc > $STREAM_THRESHOLD, 1, null())"

# Vectorize streams
r.to.vect input=streams output=stream_network type=line

echo "Processing watershed outlets from configuration..."

# Parse outlets JSON and process each one
python3 -c "
import json
import subprocess
import sys

try:
    outlets_json = '$OUTLETS'
    outlets = json.loads(outlets_json)
    
    for i, outlet in enumerate(outlets):
        name = outlet.get('name', f'outlet_{i}')
        coords = outlet.get('coordinates', [0, 0])
        
        if len(coords) >= 2:
            coord_str = f'{coords[0]},{coords[1]}'
            print(f'Processing outlet {name} at {coord_str}')
            
            # Run GRASS commands for this outlet
            subprocess.run(['r.water.outlet', 
                          f'input=dem_filled', 
                          f'output=basin_{name}', 
                          f'coordinates={coord_str}'], check=True)
            
            subprocess.run(['r.to.vect', 
                          f'input=basin_{name}', 
                          f'output=watershed_{name}', 
                          'type=area'], check=True)
            
            subprocess.run(['v.out.ogr', 
                          f'input=watershed_{name}', 
                          f'output=$PROCESSED_DATA_PATH/watershed_{name}.shp',
                          'format=ESRI_Shapefile'], check=True)
        else:
            print(f'Warning: Invalid coordinates for outlet {name}')
            
except json.JSONDecodeError:
    print('Warning: Could not parse outlets configuration, using fallback method')
    # Fallback to original hard-coded outlets
    subprocess.run(['r.water.outlet', 'input=dem_filled', 'output=basin1', 'coordinates=384500,801500'], check=True)
    subprocess.run(['r.water.outlet', 'input=dem_filled', 'output=basin2', 'coordinates=390000,820000'], check=True)
    subprocess.run(['r.to.vect', 'input=basin1', 'output=watershed_dee', 'type=area'], check=True)
    subprocess.run(['r.to.vect', 'input=basin2', 'output=watershed_don', 'type=area'], check=True)
    subprocess.run(['v.out.ogr', 'input=watershed_dee', f'output=$PROCESSED_DATA_PATH/watershed_dee.shp', 'format=ESRI_Shapefile'], check=True)
    subprocess.run(['v.out.ogr', 'input=watershed_don', f'output=$PROCESSED_DATA_PATH/watershed_don.shp', 'format=ESRI_Shapefile'], check=True)

except Exception as e:
    print(f'Error processing outlets: {e}', file=sys.stderr)
    sys.exit(1)
"

  # Export stream network
  if [ -f "$PROCESSED_DATA_PATH/streams.shp" ]; then
    echo "Stream network shapefile already exists: $PROCESSED_DATA_PATH/streams.shp (skipping export)"
  else
    echo "Exporting stream network..."
    v.out.ogr input=stream_network output="$PROCESSED_DATA_PATH/streams.shp" format=ESRI_Shapefile
  fi

  echo "DEM processing completed successfully"
else
  echo "DEM processing skipped - output files already exist"
fi
