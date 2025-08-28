#!/bin/sh

set -e  # Exit on any error

# PROJECT_ROOT is expected to be set by the Nix environment (shell.nix)
cd "$PROJECT_ROOT/scripts"

echo "Starting Aberdeenshire watershed mapping pipeline..."

# Step 1: Setup
echo "Setting up environment..."
./setup_environment.sh

# Step 2: Data acquisition
echo "Acquiring data..."
./acquire_data.sh

# Step 3: DEM processing
echo "Processing DEM..."
./process_dem.sh

# Step 4: Calculate statistics
echo "Calculating watershed statistics..."
python3 process_watersheds.py

# Step 5: Create publication map
echo "Creating publication map..."
./create_map_gmt.sh

# Step 6: Generate metadata
echo "Generating metadata..."

if [ -f "../output/metadata.txt" ]; then
  echo "Metadata file already exists: ../output/metadata.txt (skipping generation)"
else
  echo "Creating metadata file..."
  # Load configuration values for metadata
  DEM_SOURCE=$(yq '.data_sources.dem.source' config/default.yaml)
  DEM_RESOLUTION=$(yq '.data_sources.dem.resolution' config/default.yaml)
  PROJECT_NAME=$(yq '.project.name' config/default.yaml)
  COORD_SYSTEM=$(yq '.project.coordinate_system' config/default.yaml)
  
  cat > ../output/metadata.txt << EOF
$PROJECT_NAME
Created: $(date)
DEM Source: $DEM_SOURCE ${DEM_RESOLUTION}m
Processing: GRASS GIS $(grass --version)
Coordinate System: $COORD_SYSTEM (British National Grid)
Software: FOSS stack (GRASS, GDAL, GMT)
EOF
fi

echo "Pipeline complete. Output in '../output/' directory."
