#!/bin/sh
# create_map_gmt.sh

# Change to the project root directory
cd "$PROJECT_ROOT"

# Check if output maps already exist
if [ -f "$OUTPUT_DIR/aberdeenshire_watersheds.png" ] && [ -f "$OUTPUT_DIR/aberdeenshire_watersheds.pdf" ]; then
  echo "Map outputs already exist: $OUTPUT_DIR/aberdeenshire_watersheds.png and $OUTPUT_DIR/aberdeenshire_watersheds.pdf (skipping map creation)"
  exit 0
fi

echo "Creating watershed maps..."

# Change to output directory so GMT files are created there
cd "$OUTPUT_DIR"

# GMT modern mode
gmt begin aberdeenshire_watersheds png,pdf
# Set region (Aberdeenshire bounds in British National Grid)
gmt basemap -R350000/450000/780000/880000 -JX15c -Ba20000 -BWSne

# Create color palette for watersheds
gmt makecpt -Crainbow -T1/7/1 -H > watersheds.cpt

# Plot DEM as background
gmt grdimage "$DATA_DIR/processed/dem_filled.tif" -Cgray -t70

# Plot watersheds with colors from the palette
gmt plot "$DATA_DIR/processed/watersheds.shp" -Cwatersheds.cpt -W0.5p,black

# Plot rivers
gmt plot "$DATA_DIR/processed/streams.shp" -W1p,blue

# Add title
gmt basemap -B+t"Aberdeenshire Watersheds"

# Add north arrow
gmt plot -Sv0.2c+e+a40+gblack+h0.5 -W2p,black << EOF
13c 10c 90 2c
EOF

gmt end show

# Change back to project root
cd "$PROJECT_ROOT"

echo "Map creation completed successfully"
