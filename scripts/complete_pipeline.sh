
set -e  # Exit on any error

echo "Starting Aberdeenshire watershed mapping pipeline..."

# Step 1: Setup
echo "Setting up environment..."
sh scripts/setup_environment.sh

# Step 2: Data acquisition
echo "Acquiring data..."
sh scripts/acquire_data.sh

# Step 3: DEM processing
echo "Processing DEM..."
sh scripts/process_dem.sh

# Step 4: Calculate statistics
echo "Calculating watershed statistics..."
python3 process_watersheds.py

# Step 5: Create publication map
echo "Creating publication map..."
sh scripts/create_map_gmt.sh

# Step 6: Generate metadata
echo "Generating metadata..."
cat > output/metadata.txt << EOF
Aberdeenshire Watershed Map
Created: $(date)
DEM Source: EU-DEM 25m
Processing: GRASS GIS $(grass --version)
Coordinate System: EPSG:27700 (British National Grid)
Software: FOSS stack (GRASS, GDAL, GMT)
EOF

echo "Pipeline complete. Output in 'output/' directory."
