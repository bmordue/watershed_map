# Troubleshooting Guide

This guide helps you diagnose and fix common issues with the Watershed Mapping project.

## Table of Contents

* [Quick Diagnostics](#quick-diagnostics)
* [Installation Issues](#installation-issues)
* [GRASS GIS Issues](#grass-gis-issues)
* [Data Processing Issues](#data-processing-issues)
* [Python Package Issues](#python-package-issues)
* [Performance Issues](#performance-issues)
* [CI/CD Issues](#cicd-issues)
* [Getting More Help](#getting-more-help)

## Quick Diagnostics

### Run System Check

```bash
# Check tool availability
for tool in grass gdal_translate gmt python3 wget; do
  if command -v $tool >/dev/null 2>&1; then
    echo "✓ $tool available"
  else
    echo "✗ $tool NOT FOUND"
  fi
done

# Check Python packages
python3 -c "
import sys
packages = ['geopandas', 'rasterio', 'fiona', 'shapely', 'pyproj', 'numpy', 'rasterstats', 'yaml']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        print(f'✗ {pkg} NOT AVAILABLE')
"

# Check GRASS location
if [ -d "grassdb/aberdeenshire_bng/PERMANENT" ]; then
  echo "✓ GRASS location exists"
else
  echo "✗ GRASS location NOT FOUND - run ./scripts/setup_environment.sh"
fi
```

### Check Environment Variables

```bash
# Verify key environment variables
echo "PROJECT_ROOT: ${PROJECT_ROOT:-NOT SET}"
echo "GRASS_PYTHON: ${GRASS_PYTHON:-NOT SET}"
echo "GDAL_DATA: ${GDAL_DATA:-NOT SET}"
echo "CONFIG_FILE: ${CONFIG_FILE:-NOT SET (using default)}"
```

## Installation Issues

### Nix Installation Fails

**Problem**: `nix-shell` command not found or Nix installation script fails

**Solutions**:

1. **Reinstall Nix**:
   ```bash
   curl -L https://nixos.org/nix/install | sh
   source ~/.nix-profile/etc/profile.d/nix.sh
   ```

2. **Check Nix daemon** (multi-user install):
   ```bash
   sudo systemctl status nix-daemon
   sudo systemctl start nix-daemon
   ```

3. **Try single-user install** (if multi-user fails):
   ```bash
   curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
   ```

### Nix Build Errors

**Problem**: `nix-shell` fails with build errors

**Solutions**:

1. **Update nixpkgs channel**:
   ```bash
   nix-channel --update
   ```

2. **Clear Nix cache**:
   ```bash
   nix-collect-garbage -d
   ```

3. **Try with different nixpkgs version**:
   ```bash
   nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz
   ```

### System Package Installation

**Problem**: Installing without Nix on Ubuntu/Debian

**Solution**:

```bash
# Add UbuntuGIS PPA for latest versions
sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt update

# Install packages
sudo apt install -y \
  grass-core grass-dev \
  gdal-bin libgdal-dev \
  gmt gmt-dcw gmt-gshhg \
  python3 python3-pip python3-dev \
  wget osmium-tool

# Install Python packages
pip3 install --user geopandas rasterio shapely fiona pyproj numpy pyyaml rasterstats
```

**Problem**: Installing on macOS

**Solution**:

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew install grass gdal gmt python3 wget osmium-tool

# Install Python packages
pip3 install geopandas rasterio shapely fiona pyproj numpy pyyaml rasterstats
```

## GRASS GIS Issues

### GRASS Location Not Found

**Problem**: `ERROR: Location <aberdeenshire_bng> not found`

**Solution**:

```bash
# Create GRASS location
./scripts/setup_environment.sh

# Or manually
mkdir -p grassdb
grass -c EPSG:27700 grassdb/aberdeenshire_bng
```

### GRASS Session Errors

**Problem**: `GRASS session already active` or similar

**Solutions**:

1. **Exit any active GRASS sessions**:
   ```bash
   # Press Ctrl+D or type 'exit' in GRASS shell
   exit
   ```

2. **Remove GRASS lock files**:
   ```bash
   rm -f grassdb/aberdeenshire_bng/PERMANENT/.gislock
   ```

3. **Use --exec for non-interactive**:
   ```bash
   grass grassdb/aberdeenshire_bng/PERMANENT --exec g.version
   ```

### GRASS Cannot Import DEM

**Problem**: `r.in.gdal` fails to import DEM

**Solutions**:

1. **Check DEM file exists**:
   ```bash
   ls -lh data/raw/*.tif
   ```

2. **Verify DEM is valid**:
   ```bash
   gdalinfo data/raw/copdem_glo30_aberdeenshire.tif
   ```

3. **Check coordinate system matches**:
   ```bash
   # Get DEM CRS
   gdalsrsinfo data/raw/copdem_glo30_aberdeenshire.tif
   
   # Should match GRASS location (EPSG:27700)
   # If not, reproject:
   gdalwarp -t_srs EPSG:27700 \
     data/raw/dem_original.tif \
     data/raw/dem_reprojected.tif
   ```

4. **Check file permissions**:
   ```bash
   chmod 644 data/raw/*.tif
   ```

### GRASS Coordinate System Errors

**Problem**: Coordinate system mismatches

**Solution**:

```bash
# Check GRASS location projection
grass grassdb/aberdeenshire_bng/PERMANENT --exec g.proj -p

# Verify it matches EPSG:27700 (British National Grid)
# If wrong, recreate location:
rm -rf grassdb/aberdeenshire_bng
grass -c EPSG:27700 grassdb/aberdeenshire_bng
```

## Data Processing Issues

### DEM Download Fails

**Problem**: `wget` fails to download DEM

**Solutions**:

1. **Check internet connection**:
   ```bash
   ping -c 3 google.com
   ```

2. **Verify URL is accessible**:
   ```bash
   curl -I "https://dataspace.copernicus.eu/..."
   ```

3. **Use alternative download method**:
   ```bash
   # Try curl instead of wget
   curl -L -o data/raw/dem.tif "URL_HERE"
   ```

4. **Download manually**: Download DEM from browser, place in `data/raw/`

### Configuration File Not Found

**Problem**: `Error: Configuration file 'config/default.yaml' not found`

**Solutions**:

1. **Check you're in project root**:
   ```bash
   pwd  # Should end in /watershed_map
   ls config/default.yaml  # Should exist
   ```

2. **Verify file exists**:
   ```bash
   find . -name "default.yaml"
   ```

3. **Use absolute path**:
   ```bash
   export CONFIG_FILE=/absolute/path/to/config/default.yaml
   ```

### Watershed Outlets Invalid

**Problem**: Watershed delineation produces no output or errors

**Solutions**:

1. **Verify coordinates are in project bounds**:
   ```yaml
   # config/default.yaml
   project:
     region:
       bounds: [350000, 450000, 780000, 880000]  # [xmin, xmax, ymin, ymax]
   
   # Outlets must be within these bounds
   processing:
     watersheds:
       outlets:
         - coordinates: [384500, 801500]  # Must be within bounds
   ```

2. **Check coordinate system**:
   - Coordinates must be in EPSG:27700 (British National Grid)
   - NOT latitude/longitude!

3. **Test with known good coordinates**:
   ```yaml
   outlets:
     - name: "test"
       coordinates: [400000, 800000]  # Center of region
   ```

### Stream Threshold Issues

**Problem**: No streams detected or too many streams

**Solution**:

```yaml
# Adjust stream threshold in config/default.yaml
processing:
  watersheds:
    stream_threshold: 1000  # Increase for fewer streams, decrease for more
    
# Guidelines:
# - 100-500: Very detailed stream network (small watersheds)
# - 1000-2000: Moderate detail (recommended for regional analysis)
# - 5000+: Only major rivers
```

## Python Package Issues

### Import Errors

**Problem**: `ModuleNotFoundError: No module named 'geopandas'`

**Solutions**:

1. **In Nix environment**:
   ```bash
   # Exit and re-enter nix-shell
   exit
   nix-shell
   
   # Verify Python packages
   python3 -c "import geopandas; print('OK')"
   ```

2. **Outside Nix**:
   ```bash
   # Install missing package
   pip3 install --user geopandas
   
   # Or all packages
   pip3 install --user geopandas rasterio shapely fiona pyproj numpy pyyaml rasterstats
   ```

3. **Check Python path**:
   ```bash
   which python3
   python3 -m site
   ```

### PyYAML Installation Issues

**Problem**: `yaml` module not found

**Solution**:

```bash
# Install PyYAML
pip3 install --user pyyaml

# Verify
python3 -c "import yaml; print(yaml.__version__)"
```

### Rasterstats Issues

**Problem**: `rasterstats` not available in Nix

**Solution**:

```bash
# rasterstats is installed via pip in shell.nix shellHook
# Re-enter nix-shell to trigger installation
exit
nix-shell

# Manually install if needed
pip install --user rasterstats
```

## Performance Issues

### Pipeline Takes Too Long

**Problem**: Processing takes more than 1 hour

**Solutions**:

1. **Use development configuration** (smaller dataset):
   ```bash
   CONFIG_FILE=config/environments/development.yaml ./scripts/complete_pipeline.sh
   ```

2. **Check disk I/O**:
   ```bash
   # Monitor I/O during processing
   iotop  # or iostat
   ```

3. **Increase available memory**:
   ```bash
   # Check memory usage
   free -h
   
   # Close other applications
   # Consider processing smaller regions
   ```

4. **Check for slow network** (during data download):
   ```bash
   # Test download speed
   wget --spider "URL_HERE"
   ```

### Out of Memory Errors

**Problem**: `MemoryError` or system becomes unresponsive

**Solutions**:

1. **Process smaller region**:
   ```yaml
   # config/default.yaml
   project:
     region:
       bounds: [380000, 420000, 790000, 830000]  # Smaller region
   ```

2. **Reduce DEM resolution**:
   ```bash
   # Downsample DEM before processing
   gdalwarp -tr 100 100 \
     data/raw/dem_30m.tif \
     data/raw/dem_100m.tif
   ```

3. **Free up memory**:
   ```bash
   # Clear caches
   sudo sysctl -w vm.drop_caches=3  # Linux
   
   # Close other applications
   ```

### Disk Space Issues

**Problem**: `No space left on device`

**Solutions**:

1. **Check disk usage**:
   ```bash
   df -h
   du -sh data/* output/* grassdb/*
   ```

2. **Clean up old data**:
   ```bash
   # Remove processed data (can be regenerated)
   rm -rf data/processed/*
   rm -rf output/*
   
   # Clean GRASS database
   rm -rf grassdb/*
   
   # Re-run setup
   ./scripts/setup_environment.sh
   ```

3. **Use different location** for data:
   ```bash
   # Link to external drive
   ln -s /mnt/external/watershed_data data
   ```

## CI/CD Issues

### GitHub Actions Timeout

**Problem**: Pipeline workflow times out after 60 minutes

**Solutions**:

1. **Check workflow file**:
   ```yaml
   # .github/workflows/pipeline.yml
   jobs:
     run-pipeline:
       timeout-minutes: 60  # Increase if needed
   ```

2. **Use cached Nix packages**:
   ```yaml
   - name: Setup Nix cache
     uses: cachix/cachix-action@v16
     with:
       name: nixpkgs-unfree
       authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
   ```

3. **Skip slow steps in CI**:
   - Use development configuration
   - Skip optional processing steps

### CI Build Fails on Dependency Installation

**Problem**: Nix installation or package builds fail in CI

**Solutions**:

1. **Check Nix channel**:
   ```yaml
   - name: Install Nix
     uses: cachix/install-nix-action@v31
     with:
       nix_path: nixpkgs=channel:nixos-unstable
   ```

2. **Pin nixpkgs version**:
   ```nix
   # shell.nix
   let
     pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz") {};
   in
   pkgs.mkShell { ... }
   ```

3. **Check CI logs**: Review full build logs for specific errors

## Getting More Help

### Diagnostic Information to Collect

When reporting issues, include:

```bash
# System information
uname -a
lsb_release -a  # Linux

# Tool versions
grass --version
gdalinfo --version
gmt --version
python3 --version

# Environment
env | grep -E 'GRASS|GDAL|PROJ|NIX'

# Disk space
df -h

# Configuration (sanitized)
cat config/default.yaml

# Recent logs
tail -100 pipeline.log  # if available
```

### Where to Get Help

1. **Documentation**:
   - [README.md](README.md)
   - [docs/watershed_mapping_guide.md](docs/watershed_mapping_guide.md)
   - [docs/CONFIG_SYSTEM.md](docs/CONFIG_SYSTEM.md)

2. **GitHub**:
   - Search existing issues: https://github.com/bmordue/watershed_map/issues
   - Create new issue: Use issue templates
   - Discussions: For questions and help

3. **Community Resources**:
   - GRASS GIS mailing list
   - GIS Stack Exchange
   - OSGeo community forums

### Creating a Good Bug Report

Include:
* **Description**: What's wrong?
* **Steps to reproduce**: How to trigger the issue?
* **Expected behavior**: What should happen?
* **Actual behavior**: What actually happens?
* **Environment**: OS, tool versions (see diagnostic commands above)
* **Logs**: Error messages, stack traces
* **Configuration**: Relevant config file sections
* **Data**: Sample data if possible (or description)

---

**Last Updated**: February 2026  
**Maintained by**: Development Team

**Still stuck?** Open an issue with the diagnostic information above!
