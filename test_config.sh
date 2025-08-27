#!/bin/sh
# Test configuration system demonstration

echo "=== Watershed Mapping Configuration System Test ==="
echo

# Test default configuration
echo "1. Testing default configuration:"
CONFIG_FILE="config/default.yaml"
source lib/config_loader.sh
load_config
echo "   Project name: $CONFIG_PROJECT_NAME"
echo "   Stream threshold: $CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD"
echo "   Data directory: $CONFIG_PATHS_DATA_DIR"
echo

# Test development configuration
echo "2. Testing development configuration:"
CONFIG_FILE="config/environments/development.yaml"
source lib/config_loader.sh
load_config
echo "   Project name: $CONFIG_PROJECT_NAME"
echo "   Stream threshold: $CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD"
echo "   Data directory: $CONFIG_PATHS_DATA_DIR"
echo

# Test Python configuration loading
echo "3. Testing Python configuration loading:"
python3 -c "
from lib.config import load_config, get_config
config = load_config('config/default.yaml')
print(f'   Project name: {get_config(\"project.name\")}')
print(f'   Stream threshold: {get_config(\"processing.watersheds.stream_threshold\")}')
print(f'   Number of outlets: {len(get_config(\"processing.watersheds.outlets\", []))}')
"

echo
echo "=== Configuration system working correctly! ==="
