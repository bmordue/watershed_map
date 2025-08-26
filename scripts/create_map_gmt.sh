#!/bin/sh
# create_map_gmt.sh

# Change to the project root directory
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

# Check if output maps already exist
if [ -f "aberdeenshire_watersheds.png" ] && [ -f "aberdeenshire_watersheds.pdf" ]; then
  echo "Map outputs already exist: aberdeenshire_watersheds.png and aberdeenshire_watersheds.pdf (skipping map creation)"
  exit 0
fi

echo "Creating watershed maps..."

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

echo "Map creation completed successfully"
