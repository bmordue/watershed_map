#!/bin/sh
# setup_environment.sh - Environment setup with configuration support

# TODO: move all of this script to shell.nix

# Change to the project root directory
cd "$PROJECT_ROOT"

# Load configuration
export SCRIPT_DIR="$PROJECT_ROOT/scripts"
. "$PROJECT_ROOT/lib/config_loader.sh"
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

export DATA_DIR="$PROJECT_ROOT/data"
mkdir -p "$DATA_DIR"

# Create GRASS location with configurable coordinate system
echo "Creating GRASS location '$LOCATION' with $COORDINATE_SYSTEM..."
if [ -d "$GRASS_DB/$LOCATION" ]; then
    echo "Location '$LOCATION' already exists, skipping creation"
else
    grass -c "$COORDINATE_SYSTEM" "$GRASS_DB/$LOCATION" --exec echo "Location created successfully"
fi

echo "Environment setup completed successfully"
