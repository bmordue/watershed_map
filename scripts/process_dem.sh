#!/bin/sh
# process_dem.sh - DEM processing with configuration support

set -eu

# Change to the project root directory
cd "$PROJECT_ROOT"

# Load configuration
. "$PROJECT_ROOT/lib/config_loader.sh"
load_config

# Use configuration values with fallbacks for backward compatibility
DEM_FILENAME="${CONFIG_DATA_SOURCES_DEM_FILENAME:-eudem_aberdeenshire.tif}"
RAW_DATA_PATH="${CONFIG_PATHS_RAW_DATA:-data/raw}"
PROCESSED_DATA_PATH="${CONFIG_PATHS_PROCESSED_DATA:-data/processed}"
STREAM_THRESHOLD="${CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD:-1000}"
OUTLETS="${CONFIG_PROCESSING_WATERSHEDS_OUTLETS:-[]}"
GRASS_DB="${CONFIG_PATHS_GRASSDB:-grassdb}"

echo "DEM Processing Configuration:"
echo "  DEM file: $RAW_DATA_PATH/$DEM_FILENAME"
echo "  Stream threshold: $STREAM_THRESHOLD"
echo "  Output path: $PROCESSED_DATA_PATH"
echo "  GRASS DB: $GRASS_DB"

# ============================================================================
# VALIDATION CHECKS - FAIL EARLY IF DATA IS NOT AVAILABLE OR WRONG FORMAT
# ============================================================================

echo "Validating DEM data availability and format..."

# Check if raw data directory exists
if [ ! -d "$RAW_DATA_PATH" ]; then
    echo "ERROR: Raw data directory does not exist: $RAW_DATA_PATH" >&2
    echo "Please create the directory and add DEM data files." >&2
    exit 1
fi

# Check if DEM file exists
DEM_PATH="$RAW_DATA_PATH/$DEM_FILENAME"
if [ ! -f "$DEM_PATH" ]; then
    echo "ERROR: DEM file not found: $DEM_PATH" >&2
    echo "Available files in $RAW_DATA_PATH:" >&2
    ls -la "$RAW_DATA_PATH" >&2 || echo "  (unable to list files)" >&2
    echo "" >&2
    echo "Expected DEM file: $DEM_FILENAME" >&2
    echo "Common DEM formats: .tif, .tiff, .asc, .dem, .hgt" >&2
    echo "" >&2
    echo "To fix this issue:" >&2
    echo "1. Download DEM data for your area of interest" >&2
    echo "2. Place it in $RAW_DATA_PATH/$DEM_FILENAME" >&2
    echo "3. Or update CONFIG_DATA_SOURCES_DEM_FILENAME in your config" >&2
    exit 1
fi

# Check if file is readable
if [ ! -r "$DEM_PATH" ]; then
    echo "ERROR: DEM file is not readable: $DEM_PATH" >&2
    echo "Please check file permissions." >&2
    exit 1
fi

# Check file size (should be substantial for DEM data)
DEM_SIZE=$(stat -c%s "$DEM_PATH" 2>/dev/null || echo "0")
if [ "$DEM_SIZE" -lt 1024 ]; then
    echo "ERROR: DEM file appears to be too small (${DEM_SIZE} bytes): $DEM_PATH" >&2
    echo "This might be an HTML redirect, error file, or corrupted download." >&2
    echo "File contents preview:" >&2
    head -n 5 "$DEM_PATH" 2>/dev/null | sed 's/^/  /' >&2 || echo "  (unable to read file)" >&2
    exit 1
fi

# Validate DEM format using GDAL
echo "Validating DEM format with GDAL..."
if ! command -v gdalinfo >/dev/null 2>&1; then
    echo "ERROR: gdalinfo not available. Please install GDAL tools." >&2
    echo "Install with: sudo apt install gdal-bin" >&2
    exit 1
fi

# Check if GDAL can read the file
if ! gdalinfo "$DEM_PATH" >/dev/null 2>&1; then
    echo "ERROR: GDAL cannot read DEM file: $DEM_PATH" >&2
    echo "This file may not be a valid raster format." >&2
    echo "File type detection:" >&2
    file "$DEM_PATH" 2>/dev/null | sed 's/^/  /' >&2 || echo "  (unable to detect file type)" >&2
    echo "" >&2
    echo "Supported formats include: GeoTIFF, ASCII Grid, ESRI Grid, HGT, etc." >&2
    echo "Use 'gdalinfo $DEM_PATH' to debug format issues." >&2
    exit 1
fi

# Get DEM info and validate key properties
DEM_INFO=$(gdalinfo "$DEM_PATH" 2>/dev/null) || {
    echo "ERROR: Failed to get DEM information" >&2
    exit 1
}

# Extract key information
DEM_WIDTH=$(echo "$DEM_INFO" | grep -E "Size is" | sed -n 's/Size is \([0-9]*\), [0-9]*/\1/p')
DEM_HEIGHT=$(echo "$DEM_INFO" | grep -E "Size is" | sed -n 's/Size is [0-9]*, \([0-9]*\)/\1/p')
DEM_BANDS=$(echo "$DEM_INFO" | grep -c "Band [0-9]*" || echo "0")
HAS_PROJECTION=$(echo "$DEM_INFO" | grep -q "Coordinate System is" && echo "yes" || echo "no")

echo "DEM Properties:"
echo "  Dimensions: ${DEM_WIDTH}x${DEM_HEIGHT} pixels"
echo "  Bands: $DEM_BANDS"
echo "  Has projection: $HAS_PROJECTION"
echo "  Size: $DEM_SIZE bytes"

# Validate dimensions
if [ -z "$DEM_WIDTH" ] || [ -z "$DEM_HEIGHT" ] || [ "$DEM_WIDTH" -eq 0 ] || [ "$DEM_HEIGHT" -eq 0 ]; then
    echo "ERROR: Invalid DEM dimensions: ${DEM_WIDTH}x${DEM_HEIGHT}" >&2
    exit 1
fi

# Validate number of bands (should be 1 for elevation data)
if [ "$DEM_BANDS" -ne 1 ]; then
    echo "WARNING: DEM has $DEM_BANDS bands. Expected 1 band for elevation data." >&2
    echo "This may still work, but verify that the first band contains elevation data." >&2
fi

# Check for projection information
if [ "$HAS_PROJECTION" = "no" ]; then
    echo "WARNING: DEM file has no coordinate system information." >&2
    echo "GRASS GIS may have trouble importing this file." >&2
    echo "Consider reprojecting to a proper coordinate system first." >&2
fi

# Validate GRASS environment
echo "Validating GRASS GIS environment..."
GRASS_LOCATION="${CONFIG_ENVIRONMENT_GRASS_LOCATION:-aberdeenshire_bng}"
GRASS_LOCATION_PATH="$GRASS_DB/$GRASS_LOCATION/PERMANENT"

if [ ! -d "$GRASS_LOCATION_PATH" ]; then
    echo "ERROR: GRASS location does not exist: $GRASS_LOCATION_PATH" >&2
    echo "Please run setup_environment.sh first to create the GRASS location." >&2
    exit 1
fi

# Test GRASS accessibility
if ! command -v grass >/dev/null 2>&1; then
    echo "ERROR: GRASS GIS not available in PATH" >&2
    echo "Please install GRASS GIS: sudo apt install grass-core" >&2
    exit 1
fi

echo "✓ All validation checks passed. DEM data is ready for processing."

# ============================================================================
# END VALIDATION CHECKS
# ============================================================================

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
  echo "Using GRASS location: $GRASS_DB/$GRASS_LOCATION/PERMANENT"
  
  grass "$GRASS_DB/$GRASS_LOCATION/PERMANENT" --exec bash -c "
# Import DEM using configuration with validation
echo 'Importing DEM into GRASS GIS...'
if ! r.in.gdal input=\"$RAW_DATA_PATH/$DEM_FILENAME\" output=dem; then
    echo 'ERROR: Failed to import DEM into GRASS GIS' >&2
    echo 'This may indicate:' >&2
    echo '  - Incompatible file format' >&2
    echo '  - Projection mismatch with GRASS location' >&2
    echo '  - Corrupted or invalid raster data' >&2
    exit 1
fi

# Verify DEM import was successful
if ! g.list type=raster pattern=dem >/dev/null 2>&1; then
    echo 'ERROR: DEM import failed - no raster named \"dem\" found in GRASS database' >&2
    exit 1
fi

# Get and validate DEM information in GRASS
DEM_GRASS_INFO=\$(r.info map=dem 2>/dev/null) || {
    echo 'ERROR: Cannot get information about imported DEM' >&2
    exit 1
}

echo 'DEM successfully imported into GRASS:'
echo \"\$DEM_GRASS_INFO\" | grep -E '(rows|cols|north|south|east|west|min|max)' | sed 's/^/  /'

# Set region from imported DEM
echo 'Setting computational region from DEM...'
if ! g.region -s raster=dem; then
    echo 'ERROR: Failed to set region from DEM' >&2
    exit 1
fi

# Fill sinks (critical for watershed analysis)
r.fill.dir input=dem output=dem_filled direction=flow_dir areas=problem_areas

# Alternative: use Wang & Liu algorithm for better sink filling
r.terraflow elevation=dem filled=dem_filled direction=flow_dir swatershed=watersheds accumulation=flow_acc

# Calculate flow accumulation
r.flow elevation=dem_filled flowline=flowlines flowlength=flowlength flowaccumulation=flow_acc

# Define stream network threshold using configuration
r.mapcalc \"streams = if(flow_acc > $STREAM_THRESHOLD, 1, null())\"

# Vectorize streams
r.to.vect input=streams output=stream_network type=line

echo 'Processing watershed outlets from configuration...'

# Parse outlets JSON and process each one - using grass commands directly
python3 -c \"
import json
import subprocess
import sys
import os

try:
    outlets_json = '$OUTLETS'
    outlets = json.loads(outlets_json)
    
    for i, outlet in enumerate(outlets):
        name = outlet.get('name', f'outlet_{i}')
        coords = outlet.get('coordinates', [0, 0])
        
        if len(coords) >= 2:
            coord_str = f'{coords[0]},{coords[1]}'
            print(f'Processing outlet {name} at {coord_str}')
            
            # Run GRASS commands for this outlet using os.system for direct execution
            os.system(f'r.water.outlet input=dem_filled output=basin_{name} coordinates={coord_str}')
            os.system(f'r.to.vect input=basin_{name} output=watershed_{name} type=area')
            os.system(f'v.out.ogr input=watershed_{name} output=$PROCESSED_DATA_PATH/watershed_{name}.shp format=ESRI_Shapefile')
        else:
            print(f'Warning: Invalid coordinates for outlet {name}')
            
except json.JSONDecodeError:
    print('Warning: Could not parse outlets configuration, using fallback method')
    # Fallback to original hard-coded outlets
    os.system('r.water.outlet input=dem_filled output=basin1 coordinates=384500,801500')
    os.system('r.water.outlet input=dem_filled output=basin2 coordinates=390000,820000')
    os.system('r.to.vect input=basin1 output=watershed_dee type=area')
    os.system('r.to.vect input=basin2 output=watershed_don type=area')
    os.system(f'v.out.ogr input=watershed_dee output=$PROCESSED_DATA_PATH/watershed_dee.shp format=ESRI_Shapefile')
    os.system(f'v.out.ogr input=watershed_don output=$PROCESSED_DATA_PATH/watershed_don.shp format=ESRI_Shapefile')

except Exception as e:
    print(f'Error processing outlets: {e}', file=sys.stderr)
    sys.exit(1)
\"

# Export stream network
if [ -f \"$PROCESSED_DATA_PATH/streams.shp\" ]; then
  echo \"Stream network shapefile already exists: $PROCESSED_DATA_PATH/streams.shp (skipping export)\"
else
  echo \"Exporting stream network...\"
  v.out.ogr input=stream_network output=\"$PROCESSED_DATA_PATH/streams.shp\" format=ESRI_Shapefile
fi

echo 'DEM processing completed successfully'
"
else
  echo "DEM processing skipped - output files already exist"
fi
