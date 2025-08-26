#!/bin/sh
# complete_pipeline.sh

set -e  # Exit on any error

# Change to the project root directory
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

echo "Starting Aberdeenshire watershed mapping pipeline..."

# Step 1: Setup
echo "Setting up environment..."
./scripts/setup_environment.sh

# Step 2: Data acquisition
echo "Acquiring data..."
./scripts/acquire_data.sh

# Step 3: DEM processing
echo "Processing DEM..."
./scripts/process_dem.sh

# Step 4: Calculate statistics
echo "Calculating watershed statistics..."
python3 scripts/process_watersheds.py

# Step 5: Create publication map
echo "Creating publication map..."
./scripts/create_map_gmt.sh

# Step 6: Generate metadata
echo "Generating metadata..."
if [ -f "./output/metadata.txt" ]; then
  echo "Metadata file already exists: ./output/metadata.txt (skipping generation)"
else
  echo "Creating metadata file..."
  cat > ./output/metadata.txt << EOF
Aberdeenshire Watershed Map
Created: $(date)
DEM Source: EU-DEM 25m
Processing: GRASS GIS $(grass --version)
Coordinate System: EPSG:27700 (British National Grid)
Software: FOSS stack (GRASS, GDAL, GMT)
EOF
fi

echo "Pipeline complete. Output in 'output/' directory."
