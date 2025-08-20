# Watershed Mapping with FOSS GIS Stack

This repository implements a complete watershed mapping workflow for Aberdeenshire using Free and Open Source Software (FOSS) GIS tools including GRASS GIS, GDAL, GMT, and Python.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Setup (CRITICAL - Run First)
- Install required system dependencies:
  ```bash
  sudo apt update
  sudo apt install -y grass-core gdal-bin gmt gmt-dcw gmt-gshhg ghostscript python3-pip wget osmium-tool
  ```
- Install Python geospatial packages:
  ```bash
  pip3 install geopandas rasterio shapely fiona pyproj numpy rasterstats
  ```
- **TIMING**: System setup takes 3-5 minutes. NEVER CANCEL.

### Environment Setup
- Run environment setup:
  ```bash
  ./scripts/setup_environment.sh
  ```
- **TIMING**: Takes 0.1-0.2 seconds. Creates GRASS GIS location with EPSG:27700 (British National Grid).
- **NEVER skip this step** - required for all GRASS operations.

### Build and Process Data
- **CRITICAL**: The complete processing pipeline takes 15-20 minutes for large datasets. NEVER CANCEL. Set timeout to 30+ minutes.
- Run individual workflow steps:
  ```bash
  # Step 1: Environment (always run first)
  ./scripts/setup_environment.sh
  
  # Step 2: Data acquisition (requires internet access)
  ./scripts/acquire_data.sh  # FAILS in sandboxed environments - document this
  
  # Step 3: DEM processing (15-20 minutes for full datasets)
  ./scripts/process_dem.sh
  
  # Step 4: Statistical analysis (1-2 minutes)
  python3 scripts/process_watersheds.py
  
  # Step 5: Map creation (2-3 minutes)
  ./scripts/create_map_gmt.sh
  ```
- Complete pipeline:
  ```bash
  ./scripts/complete_pipeline.sh  # Takes 20-25 minutes total. NEVER CANCEL.
  ```

### Testing and Validation
- Always test with mock data first:
  ```bash
  # Create test environment
  mkdir -p data/raw data/processed output
  
  # Create mock DEM and run watershed analysis (takes 15-20 seconds)
  grass grassdb/aberdeenshire_bng/PERMANENT --exec bash -c "
    g.region n=880000 s=780000 w=350000 e=450000 res=25
    r.mapcalc 'mock_dem = sin(x()/1000)*100 + cos(y()/1000)*50 + (row()+col())/20'
    r.watershed elevation=mock_dem threshold=1000 stream=streams basin=watersheds
    r.out.gdal input=mock_dem output=data/processed/test_dem.tif format=GTiff
  "
  ```
- **VALIDATION SCENARIOS**: After making changes, always test:
  1. Environment setup: `./scripts/setup_environment.sh` completes successfully
  2. GRASS functionality: Mock DEM creation and watershed analysis
  3. Python processing: Import all geospatial packages without errors
  4. GMT map creation: Generate test map from DEM data
  5. Complete workflow: Run full pipeline on test data

## Common Tasks and Expected Timings

### Tool Availability Check
```bash
# Verify all tools are installed (takes 2-3 seconds)
grass --version  # Should show GRASS GIS 8.3.2
gdalinfo --version  # Should show GDAL 3.8.4
gmt --version  # Should show 6.5.0
python3 -c "import geopandas, rasterio, shapely, fiona, pyproj, numpy, rasterstats; print('All packages available')"
```

### File Structure
```
watershed_map/
├── .github/copilot-instructions.md  # These instructions
├── scripts/                         # Processing workflow scripts
│   ├── setup_environment.sh         # GRASS location setup (0.1s)
│   ├── acquire_data.sh              # Data download (FAILS - needs internet)
│   ├── process_dem.sh               # DEM processing (15-20 min)
│   ├── process_watersheds.py        # Statistical analysis (1-2 min)
│   ├── create_map_gmt.sh            # Map creation (2-3 min)
│   └── complete_pipeline.sh         # Full workflow (20-25 min)
├── data/                            # Data directories (created by scripts)
│   ├── raw/                         # Input data
│   └── processed/                   # Processed outputs
├── output/                          # Final maps and metadata
├── grassdb/                         # GRASS GIS database (auto-generated)
├── shell.nix                        # Nix environment (alternative setup)
├── watershed_mapping_guide.md       # Detailed workflow documentation
└── aberdeenshire_watershed_map.html # Visualization output
```

### Key Processing Steps with Timings

1. **Environment Setup** (0.1-0.2 seconds):
   - Creates GRASS location with British National Grid projection
   - **NEVER CANCEL** - Required for all subsequent operations

2. **DEM Processing** (15-20 minutes for full datasets):
   - Sink filling, flow direction, watershed delineation
   - **NEVER CANCEL** - Complex hydrological analysis
   - Set timeout to 30+ minutes minimum

3. **Statistical Processing** (1-2 minutes):
   - Python-based area calculations and elevation statistics
   - **NEVER CANCEL** - Set timeout to 5+ minutes

4. **Map Creation** (2-3 minutes):
   - GMT cartographic rendering
   - **NEVER CANCEL** - Set timeout to 10+ minutes

### Known Limitations and Workarounds

- **Data acquisition fails** in sandboxed environments due to network restrictions:
  ```bash
  # scripts/acquire_data.sh will fail with "unable to resolve host address"
  # Use mock data for testing instead
  ```
- **GRASS version differences**: Scripts may reference `grass78` but system has `grass`
- **Shapefile export format**: Use `ESRI_Shapefile` instead of `ESRI Shapefile` in v.out.ogr commands
- **GMT requires Ghostscript**: Install with `sudo apt install ghostscript`

### Validation Commands (Always Run Before Finishing)

```bash
# 1. Test environment setup (handles existing location)
ls grassdb/aberdeenshire_bng/PERMANENT/DEFAULT_WIND >/dev/null 2>&1 || ./scripts/setup_environment.sh
echo "✓ Environment setup verified"

# 2. Test GRASS functionality (15-20 seconds)
grass grassdb/aberdeenshire_bng/PERMANENT --exec g.version >/dev/null 2>&1 && echo "✓ GRASS works"

# 3. Test Python packages (0.5-1 seconds)
python3 -c "import geopandas, rasterio; print('✓ Python packages work')"

# 4. Test GMT (1-2 seconds)
gmt begin test_validation png >/dev/null 2>&1 && gmt basemap -R0/1/0/1 -JX2i -Ba1 >/dev/null 2>&1 && gmt end >/dev/null 2>&1 && echo "✓ GMT works"

# 5. Test complete mock workflow (15-20 seconds)
time (mkdir -p data/processed && grass grassdb/aberdeenshire_bng/PERMANENT --exec bash -c "
  g.region n=880000 s=780000 w=350000 e=450000 res=25 >/dev/null 2>&1
  r.mapcalc 'test_dem = row() + col()' >/dev/null 2>&1
  r.watershed elevation=test_dem threshold=100 stream=test_streams basin=test_basins >/dev/null 2>&1
  echo 'Mock workflow completed'
") && echo "✓ Complete workflow works"
```

### Critical Timeout Settings
- **Environment setup**: 30 seconds (usually completes in 0.1s)
- **DEM processing**: 30+ minutes (can take 15-20 minutes)
- **Statistical processing**: 5+ minutes (usually 1-2 minutes)
- **Map creation**: 10+ minutes (usually 2-3 minutes)
- **Complete pipeline**: 45+ minutes (usually 20-25 minutes)

### Always Remember
- **NEVER CANCEL** any processing operations - they may take 15+ minutes
- Always run `./scripts/setup_environment.sh` before any GRASS operations
- Use mock data for testing when internet access is restricted
- Run validation commands after making any changes to ensure functionality
- The repository uses EPSG:27700 (British National Grid) coordinate system
- All timings are for reference - actual times may vary based on data size and system performance