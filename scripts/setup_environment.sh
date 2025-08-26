#!/bin/sh
# setup_environment.sh - Environment setup with configuration support

# Change to the project root directory
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/config_loader.sh"
load_config

# Use configuration values with fallbacks for backward compatibility
WORKSPACE="${CONFIG_PATHS_DATA_DIR:-$(pwd)}"
GRASS_DB="${CONFIG_PATHS_GRASSDB:-$WORKSPACE/grassdb}"
LOCATION="${CONFIG_ENVIRONMENT_GRASS_LOCATION:-aberdeenshire_bng}"
COORDINATE_SYSTEM="${CONFIG_PROJECT_COORDINATE_SYSTEM:-EPSG:27700}"

echo "Environment Setup Configuration:"
echo "  Workspace: $WORKSPACE"
echo "  GRASS DB: $GRASS_DB"
echo "  Location: $LOCATION"
echo "  Coordinate System: $COORDINATE_SYSTEM"

# Set workspace
export WORKSPACE="$WORKSPACE"
export GRASS_DB="$GRASS_DB"
export LOCATION="$LOCATION"

# Create grassdb directory
mkdir -p "$GRASS_DB"

# Create GRASS location with configurable coordinate system
echo "Creating GRASS location '$LOCATION' with $COORDINATE_SYSTEM..."
if [ -d "$GRASS_DB/$LOCATION" ]; then
    echo "Location '$LOCATION' already exists, skipping creation"
else
    grass -c "$COORDINATE_SYSTEM" "$GRASS_DB/$LOCATION" --exec echo "Location created successfully"
fi

echo "Environment setup completed successfully"
