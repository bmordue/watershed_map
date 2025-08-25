#!/usr/bin/env python3
# qgis_processing.py

import sys
import os
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
    
    # Check if output already exists
    output_file = 'output/aberdeenshire_watersheds.png'
    hillshade_file = 'data/processed/hillshade.tif'
    
    if os.path.exists(output_file):
        print(f"Map output already exists: {output_file} (skipping map creation)")
        return
    
    print("Creating watershed map with QGIS...")
    
    # Load layers
    dem_layer = QgsRasterLayer('data/processed/dem_filled.tif', 'DEM')
    watershed_layer = QgsVectorLayer('data/processed/watersheds.shp', 'Watersheds')
    rivers_layer = QgsVectorLayer('data/processed/streams.shp', 'Rivers')
    
    # Create hillshade (only if it doesn't exist)
    if os.path.exists(hillshade_file):
        print(f"Hillshade already exists: {hillshade_file} (skipping generation)")
    else:
        print("Generating hillshade...")
        hillshade_params = {
            'INPUT': 'data/processed/dem_filled.tif',
            'BAND': 1,
            'Z_FACTOR': 1,
            'AZIMUTH': 315,
            'V_ANGLE': 45,
            'OUTPUT': hillshade_file
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
    os.makedirs('output', exist_ok=True)
    exporter = QgsLayoutExporter(layout)
    export_settings = QgsLayoutExporter.ImageExportSettings()
    export_settings.dpi = 300
    
    print(f"Exporting map to: {output_file}")
    exporter.exportToImage(output_file, export_settings)
    print("Map creation completed successfully")

if __name__ == '__main__':
    create_watershed_map()
    qgs.exitQgis()
