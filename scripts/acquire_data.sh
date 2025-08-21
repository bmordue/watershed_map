#!/bin/bash
# acquire_data.sh

set -e  # Exit on any error

# Create data directory
mkdir -p data/{raw,processed}

echo "Simulating data acquisition..."
echo "Attempting to download non-existent file..."
# This will fail and should stop the pipeline
wget -O /tmp/nonexistent.file "https://nonexistent.domain.invalid/file.zip"
echo "This line should never be reached"
