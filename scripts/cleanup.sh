#!/bin/sh
# cleanup.sh - Remove all downloaded and generated files from watershed mapping pipeline
#
# This script removes all files and directories created by the watershed mapping workflow:
# - Downloaded data (DEM files, OSM data)
# - Processed data (shapefiles, intermediate files) 
# - Output files (maps, metadata)
# - GRASS GIS database
# - Temporary files
#
# Usage: ./scripts/cleanup.sh
#        PROJECT_ROOT=<path> ./scripts/cleanup.sh
#
# The script will prompt for confirmation before removing each category of files.

set -e  # Exit on any error

# Function to safely remove directory with user confirmation
remove_directory() {
  local dir="$1"
  local description="$2"
  
  if [ -d "$dir" ]; then
    echo "Found $description: $dir"
    printf "Remove $description? [y/N]: "
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS])
        echo "Removing $dir..."
        rm -rf "$dir"
        echo "✓ Removed $description"
        ;;
      *)
        echo "Skipping $description"
        ;;
    esac
  else
    echo "No $description found ($dir)"
  fi
}

# Function to safely remove files with user confirmation
remove_files() {
  local pattern="$1"
  local description="$2"
  
  # Use find to check if any files match the pattern
  if find . -maxdepth 1 -name "$pattern" -type f 2>/dev/null | grep -q .; then
    echo "Found $description files matching pattern: $pattern"
    printf "Remove $description files? [y/N]: "
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS])
        echo "Removing $description files..."
        find . -maxdepth 1 -name "$pattern" -type f -delete
        echo "✓ Removed $description files"
        ;;
      *)
        echo "Skipping $description files"
        ;;
    esac
  else
    echo "No $description files found (pattern: $pattern)"
  fi
}

# Change to project root directory
if [ -n "$PROJECT_ROOT" ]; then
  cd "$PROJECT_ROOT"
else
  # Assume we're running from the scripts directory
  cd "$(dirname "$0")/.."
fi

echo "Watershed Mapping Cleanup Script"
echo "================================="
echo "This script will remove all downloaded and generated files."
echo "Current directory: $(pwd)"
echo ""

# Show what would be cleaned up
echo "The following will be checked for cleanup:"
echo "  - Downloaded data (data/raw/)"
echo "  - Processed data (data/processed/)" 
echo "  - Output files (output/)"
echo "  - GRASS GIS database (grassdb/)"
echo "  - GMT temporary files (gmt.conf, gmt.history)"
echo "  - Python cache files (__pycache__/, *.pyc)"
echo ""

printf "Continue with cleanup? [y/N]: "
read -r continue_response
case "$continue_response" in
  [yY]|[yY][eE][sS])
    echo "Starting cleanup..."
    ;;
  *)
    echo "Cleanup cancelled."
    exit 0
    ;;
esac

echo ""

# Remove main data directories
remove_directory "data/raw" "downloaded data directory"
remove_directory "data/processed" "processed data directory"
remove_directory "data" "data directory (if empty)"
remove_directory "output" "output directory"
remove_directory "grassdb" "GRASS GIS database"

# Remove Python cache
remove_directory "__pycache__" "Python cache directory"
remove_files "*.pyc" "Python bytecode"
remove_files "*.pyo" "Python optimized bytecode"
remove_files "*.pyd" "Python extension modules"

# Remove GMT temporary files
remove_files "gmt.conf" "GMT configuration"
remove_files "gmt.history" "GMT history"

# Remove any temporary files
remove_files "*.tmp" "temporary"
remove_files "*.temp" "temporary"
remove_files "*~" "backup"

echo ""
echo "Cleanup completed!"
echo ""
echo "Note: To regenerate all files, run:"
echo "  ./scripts/complete_pipeline.sh"
echo ""
echo "To regenerate just the environment:"
echo "  ./scripts/setup_environment.sh"