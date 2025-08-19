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
