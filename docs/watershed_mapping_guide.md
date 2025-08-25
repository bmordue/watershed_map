# FOSS CLI Watershed Mapping Workflow for Aberdeenshire

## Primary Software Stack

### Core Analysis Tools
- **GRASS GIS** (command-line interface)
- **GDAL/OGR** (geospatial data processing)
- **SAGA-GIS** (command-line tools)
- **WhiteboxTools** (CLI geospatial analysis)

### Visualization and Design
- **QGIS** (for final map composition, scriptable via PyQGIS)
- **GMT (Generic Mapping Tools)** (pure CLI cartography)
- **Inkscape** (vector editing, CLI scriptable)
- **ImageMagick** (raster processing)

### Supporting Tools
- **Python** with GeoPandas, Rasterio, Matplotlib
- **R** with sf, raster, tmap packages
- **PostGIS** (spatial database)

## Data Sources (Open/Free)

### Elevation Data
```bash
# Download EU-DEM (25m resolution)
wget "https://cloud.sddi.gov.uk/s/obZAZzLTGYebFex/download"

# Or use SRTM data via GDAL
gdal_translate -of GTiff -co COMPRESS=LZW \
  "/vsizip//vsicurl/https://cloud.sddi.gov.uk/index.php/s/X1PGfhPINz2LRjT" \
  srtm_aberdeenshire.tif
```

### Hydrographic Data
- **OpenStreetMap**: Rivers and water bodies
- **Natural Earth**: Administrative boundaries
- **GADM**: Country/regional boundaries

## Complete CLI Workflow

### 1. Environment Setup

```bash
#!/bin/bash
# setup_environment.sh

# Set workspace
export WORKSPACE="/path/to/project"
export GRASS_DB="$WORKSPACE/grassdb"
export LOCATION="aberdeenshire_bng"

# Create GRASS location (British National Grid)
grass78 -c EPSG:27700 "$GRASS_DB/$LOCATION"
```

### 2. Data Acquisition Script

```bash
#!/bin/bash
# acquire_data.sh

# Create data directory
mkdir -p data/{raw,processed}

# Download DEM (example with EU-DEM)
wget -O data/raw/eudem_aberdeenshire.zip \
  "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"

# Download OSM data
wget -O data/raw/scotland-latest.osm.pbf \
  "https://download.geofabrik.de/europe/great-britain/scotland-latest.osm.pbf"

# Extract rivers from OSM
osmium tags-filter data/raw/scotland-latest.osm.pbf \
  waterway=river,stream,brook,canal \
  -o data/raw/rivers.osm.pbf

# Convert to shapefile
ogr2ogr -f "ESRI Shapefile" data/processed/rivers.shp \
  data/raw/rivers.osm.pbf lines
```

### 3. DEM Processing with GRASS GIS

```bash
#!/bin/bash
# process_dem.sh

# Start GRASS session
grass78 "$GRASS_DB/$LOCATION/PERMANENT"

# Set region and import DEM
g.region -s raster=eudem_aberdeenshire
r.in.gdal input=data/raw/eudem_aberdeenshire.tif output=dem

# Fill sinks (critical for watershed analysis)
r.fill.dir input=dem output=dem_filled direction=flow_dir areas=problem_areas

# Alternative: use Wang & Liu algorithm for better sink filling
r.terraflow elevation=dem filled=dem_filled direction=flow_dir \
  swatershed=watersheds accumulation=flow_acc

# Calculate flow accumulation
r.flow elevation=dem_filled flowline=flowlines flowlength=flowlength \
  flowaccumulation=flow_acc

# Define stream network threshold
r.mapcalc "streams = if(flow_acc > 1000, 1, null())"

# Vectorize streams
r.to.vect input=streams output=stream_network type=line

# Delineate watersheds at specified outlets
r.water.outlet input=dem_filled output=basin1 coordinates=384500,801500
r.water.outlet input=dem_filled output=basin2 coordinates=390000,820000
# ... continue for each major outlet

# Convert watersheds to vector
r.to.vect input=basin1 output=watershed_dee type=area
r.to.vect input=basin2 output=watershed_don type=area

# Export results
v.out.ogr input=watershed_dee output=data/processed/watershed_dee.shp
v.out.ogr input=stream_network output=data/processed/streams.shp
```

### 4. Alternative Processing with WhiteboxTools

```bash
#!/bin/bash
# whitebox_processing.sh

# WhiteboxTools CLI approach
WBT="/path/to/WhiteboxTools"

# Fill depressions
$WBT -r=FillDepressions -v --wd="data/processed" \
  -i="dem.tif" -o="dem_filled.tif"

# Flow direction (D8 algorithm)
$WBT -r=D8FlowDirection -v --wd="data/processed" \
  -i="dem_filled.tif" -o="flow_dir.tif"

# Flow accumulation
$WBT -r=D8FlowAccumulation -v --wd="data/processed" \
  -i="flow_dir.tif" -o="flow_acc.tif"

# Extract streams
$WBT -r=ExtractStreams -v --wd="data/processed" \
  -i="flow_acc.tif" -o="streams_raster.tif" --threshold=1000

# Watershed delineation
$WBT -r=Watershed -v --wd="data/processed" \
  -i="flow_dir.tif" --pour_pts="outlets.shp" -o="watersheds.tif"
```

### 5. Python Processing Script

```python
#!/usr/bin/env python3
# process_watersheds.py

import geopandas as gpd
import rasterio
import numpy as np
from rasterio.features import shapes
import fiona

def vectorize_watersheds(raster_path, output_path):
    """Convert watershed raster to vector polygons"""
    with rasterio.open(raster_path) as src:
        image = src.read(1)
        mask = image != src.nodata
        
        results = (
            {'properties': {'watershed_id': v}, 'geometry': s}
            for i, (s, v) in enumerate(
                shapes(image, mask=mask, transform=src.transform))
        )
    
    with fiona.open(output_path, 'w', 
                    driver='ESRI Shapefile',
                    crs=src.crs,
                    schema={'properties': [('watershed_id', 'int')],
                           'geometry': 'Polygon'}) as dst:
        dst.writerecords(results)

def calculate_watershed_stats(watersheds_path, dem_path):
    """Calculate watershed statistics"""
    watersheds = gpd.read_file(watersheds_path)
    
    with rasterio.open(dem_path) as dem:
        # Calculate area (already in GeoDataFrame)
        watersheds['area_km2'] = watersheds.geometry.area / 1000000
        
        # Calculate mean elevation for each watershed
        from rasterstats import zonal_stats
        stats = zonal_stats(watersheds, dem_path, stats=['mean', 'min', 'max'])
        
        for i, stat in enumerate(stats):
            watersheds.loc[i, 'mean_elev'] = stat['mean']
            watersheds.loc[i, 'min_elev'] = stat['min']
            watersheds.loc[i, 'max_elev'] = stat['max']
    
    return watersheds

# Usage
vectorize_watersheds('data/processed/watersheds.tif', 
                    'data/processed/watersheds.shp')
                    
watershed_stats = calculate_watershed_stats('data/processed/watersheds.shp',
                                          'data/processed/dem_filled.tif')
watershed_stats.to_file('data/processed/watersheds_with_stats.shp')
```

### 6. Map Creation with GMT

```bash
#!/bin/bash
# create_map_gmt.sh

# GMT modern mode
gmt begin aberdeenshire_watersheds png,pdf

# Set region (Aberdeenshire bounds in British National Grid)
gmt basemap -R350000/450000/780000/880000 -JX15c -Ba20000 -BWSne

# Create color palette for watersheds
gmt makecpt -Cset1 -T1/7/1 -H > watersheds.cpt

# Plot DEM as hillshade background
gmt grdimage data/processed/dem_filled.tif -Igradient.grd -Cgray -t70

# Plot watersheds with colors
gmt plot data/processed/watersheds.shp -Cwatershed_id@watersheds.cpt -W0.5p,black

# Plot rivers
gmt plot data/processed/streams.shp -W1p,blue

# Add settlements
gmt plot settlements.txt -Sc0.3c -Gred -W0.25p,black

# Add labels
gmt text labels.txt -F+f12p,Helvetica-Bold,black

# Add legend
gmt legend legend.txt -Dx0.5c/0.5c+w8c+jBL -F+p1p+gwhite

# Add scale bar
gmt basemap -Lx1c/1c+c57+w50k+f+u

# Add north arrow
gmt plot -Sv0.2c+e+a40+gblack+h0.5 -W2p,black << EOF
13c 10c 90 2c
EOF

gmt end show
```

### 7. Alternative: QGIS Processing via Python

```python
#!/usr/bin/env python3
# qgis_processing.py

import sys
from qgis.core import *
from qgis.analysis import QgsNativeAlgorithms

# Initialize QGIS
QgsApplication.setPrefixPath('/usr', True)
qgs = QgsApplication([], False)
qgs.initQgis()

# Add processing providers
from processing.core.Processing import Processing
Processing.initialize()

import processing

def create_watershed_map():
    """Create publication-quality map using QGIS processing"""
    
    # Load layers
    dem_layer = QgsRasterLayer('data/processed/dem_filled.tif', 'DEM')
    watershed_layer = QgsVectorLayer('data/processed/watersheds.shp', 'Watersheds')
    rivers_layer = QgsVectorLayer('data/processed/streams.shp', 'Rivers')
    
    # Create hillshade
    hillshade_params = {
        'INPUT': 'data/processed/dem_filled.tif',
        'BAND': 1,
        'Z_FACTOR': 1,
        'AZIMUTH': 315,
        'V_ANGLE': 45,
        'OUTPUT': 'data/processed/hillshade.tif'
    }
    
    processing.run("gdal:hillshade", hillshade_params)
    
    # Style watersheds with different colors
    watershed_layer.loadNamedStyle('styles/watersheds.qml')
    
    # Create map layout
    project = QgsProject.instance()
    project.addMapLayer(dem_layer)
    project.addMapLayer(watershed_layer)
    project.addMapLayer(rivers_layer)
    
    # Export high-resolution map
    layout_manager = project.layoutManager()
    layout = QgsPrintLayout(project)
    layout.initializeDefaults()
    
    # Configure and export
    exporter = QgsLayoutExporter(layout)
    export_settings = QgsLayoutExporter.ImageExportSettings()
    export_settings.dpi = 300
    
    exporter.exportToImage('output/aberdeenshire_watersheds.png', export_settings)

if __name__ == '__main__':
    create_watershed_map()
    qgs.exitQgis()
```

### 8. Complete Processing Pipeline

```bash
#!/bin/bash
# complete_pipeline.sh

set -e  # Exit on any error

echo "Starting Aberdeenshire watershed mapping pipeline..."

# Step 1: Setup
echo "Setting up environment..."
./setup_environment.sh

# Step 2: Data acquisition
echo "Acquiring data..."
./acquire_data.sh

# Step 3: DEM processing
echo "Processing DEM..."
./process_dem.sh

# Step 4: Calculate statistics
echo "Calculating watershed statistics..."
python3 process_watersheds.py

# Step 5: Create publication map
echo "Creating publication map..."
./create_map_gmt.sh

# Step 6: Generate metadata
echo "Generating metadata..."
cat > output/metadata.txt << EOF
Aberdeenshire Watershed Map
Created: $(date)
DEM Source: EU-DEM 25m
Processing: GRASS GIS $(grass78 --version)
Coordinate System: EPSG:27700 (British National Grid)
Software: FOSS stack (GRASS, GDAL, GMT)
EOF

echo "Pipeline complete. Output in 'output/' directory."
```

### 9. Quality Control Scripts

```bash
#!/bin/bash
# quality_control.sh

# Check for topological errors
ogr2ogr -f "ESRI Shapefile" -nlt PROMOTE_TO_MULTI \
  data/processed/watersheds_clean.shp \
  data/processed/watersheds.shp

# Validate geometry
ogrinfo -sql "SELECT *, ST_IsValid(geometry) as valid FROM watersheds_clean" \
  data/processed/watersheds_clean.shp

# Check watershed areas
python3 -c "
import geopandas as gpd
ws = gpd.read_file('data/processed/watersheds_clean.shp')
print('Watershed areas (km²):')
print(ws[['watershed_i', 'area_km2']].sort_values('area_km2', ascending=False))
print(f'Total area: {ws.area_km2.sum():.1f} km²')
"
```

### 10. Automation and Reproducibility

```makefile
# Makefile for watershed mapping

.PHONY: all clean setup data process map

all: setup data process map

setup:
	./setup_environment.sh

data:
	./acquire_data.sh

process: data
	./process_dem.sh
	python3 process_watersheds.py

map: process
	./create_map_gmt.sh

clean:
	rm -rf data/processed/*
	rm -rf output/*

validate: process
	./quality_control.sh

# Docker containerization
docker:
	docker build -t watershed-mapping .
	docker run -v $(PWD):/workspace watershed-mapping make all
```

## Key Advantages of This Approach

1. **Fully Reproducible**: Every step is scripted
2. **Version Controllable**: All code can be tracked in git
3. **Scalable**: Easy to apply to other regions
4. **Professional Output**: GMT and QGIS produce publication-quality maps
5. **No Licensing Costs**: Entirely FOSS stack
6. **Command-line Efficiency**: Can be automated and batch-processed

## Output Quality

This workflow produces:
- **300+ DPI raster outputs** suitable for print
- **Vector formats** for further editing
- **Standardized symbology** and cartographic design
- **Complete metadata** and processing documentation
- **Reproducible results** through version control

The combination of GRASS GIS for analysis, GMT for cartography, and Python for data processing provides a powerful, scriptable alternative to commercial GIS software while maintaining professional mapping standards.