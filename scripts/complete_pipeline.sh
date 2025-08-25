
set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Change to the repository root directory
cd "$SCRIPT_DIR/.."

echo "Starting Aberdeenshire watershed mapping pipeline..."
echo "Working directory: $(pwd)"

# Step 1: Setup
echo "Setting up environment..."
#<<<<<<< copilot/fix-14
./scripts/setup_environment.sh

# Step 2: Data acquisition
echo "Acquiring data..."
./scripts/acquire_data.sh

# Step 3: DEM processing
echo "Processing DEM..."
./scripts/process_dem.sh
#=======
#sh scripts/setup_environment.sh

# Step 2: Data acquisition
#echo "Acquiring data..."
#sh scripts/acquire_data.sh

# Step 3: DEM processing
#echo "Processing DEM..."
#sh scripts/process_dem.sh
#>>>>>>> exit-scripts

# Step 4: Calculate statistics
echo "Calculating watershed statistics..."
python3 scripts/process_watersheds.py

# Step 5: Create publication map
echo "Creating publication map..."
#<<<<<<< copilot/fix-14
./scripts/create_map_gmt.sh
#=======
#sh scripts/create_map_gmt.sh
#>>>>>>> exit-scripts

# Step 6: Generate metadata
echo "Generating metadata..."
cat > output/metadata.txt << EOF
Aberdeenshire Watershed Map
Created: $(date)
DEM Source: EU-DEM 25m
#<<<<<<< copilot/fix-14
Processing: GRASS GIS $(grass --version | head -1)
#=======
#Processing: GRASS GIS $(grass --version)
#>>>>>>> exit-scripts
Coordinate System: EPSG:27700 (British National Grid)
Software: FOSS stack (GRASS, GDAL, GMT)
EOF

echo "Pipeline complete. Output in 'output/' directory."
