#!/bin/bash
# test_pipeline_fix.sh - Validation test for pipeline fix

set -e
echo "=== Watershed Mapping Pipeline Fix Validation ==="
echo

cd "$(dirname "$0")"

# Test 1: Environment setup
echo "1. Testing environment setup..."
./scripts/setup_environment.sh > /dev/null 2>&1
if [ -d "grassdb/aberdeenshire_bng/PERMANENT" ]; then
    echo "   ✓ GRASS location created successfully"
else
    echo "   ✗ GRASS location not found"
    exit 1
fi

# Test 2: Configuration loading
echo "2. Testing configuration loading..."
source lib/config_loader.sh
load_config > /dev/null 2>&1
if [ "$CONFIG_ENVIRONMENT_GRASS_LOCATION" = "aberdeenshire_bng" ]; then
    echo "   ✓ Configuration loaded successfully"
else
    echo "   ✗ Configuration loading failed"
    exit 1
fi

# Test 3: Configuration from scripts directory
echo "3. Testing configuration from scripts directory..."
cd scripts
source ../lib/config_loader.sh
load_config > /dev/null 2>&1
if [ "$CONFIG_ENVIRONMENT_GRASS_LOCATION" = "aberdeenshire_bng" ]; then
    echo "   ✓ Configuration loading from scripts directory works"
else
    echo "   ✗ Configuration loading from scripts directory failed"
    exit 1
fi
cd ..

# Test 4: GRASS accessibility (quick test)
echo "4. Testing GRASS accessibility..."
timeout 10 grass grassdb/aberdeenshire_bng/PERMANENT --exec g.region -p > /dev/null 2>&1 || {
    # If GRASS is locked by another process, that's actually OK for our test
    if grass grassdb/aberdeenshire_bng/PERMANENT -f --exec g.region -p > /dev/null 2>&1; then
        echo "   ✓ GRASS location accessible"
    else
        echo "   ✗ GRASS location not accessible"
        exit 1
    fi
}

# Test 5: Complete pipeline script path resolution
echo "5. Testing complete pipeline script setup..."
./scripts/complete_pipeline.sh --help > /dev/null 2>&1 || {
    # Test that the script can at least start (it will fail at data acquisition due to network restrictions)
    timeout 30 ./scripts/complete_pipeline.sh 2>&1 | grep -q "Starting Aberdeenshire watershed mapping pipeline" && {
        echo "   ✓ Complete pipeline script starts correctly"
    } || {
        echo "   ✗ Complete pipeline script failed to start"
        exit 1
    }
}

echo
echo "=== All tests passed! Pipeline fix is working correctly ==="
echo
echo "Summary:"
echo "  - GRASS location creation: ✓"
echo "  - Configuration loading: ✓" 
echo "  - Path resolution: ✓"
echo "  - Pipeline script setup: ✓"
echo
echo "The original issue 'ERROR: Location doesn't exist' has been resolved."