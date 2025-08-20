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
    dem_layer = QgsRasterLayer('../data/processed/dem_filled.tif', 'DEM')
    watershed_layer = QgsVectorLayer('../data/processed/watersheds.shp', 'Watersheds')
    rivers_layer = QgsVectorLayer('../data/processed/streams.shp', 'Rivers')
    
    # Create hillshade
    hillshade_params = {
        'INPUT': '../data/processed/dem_filled.tif',
        'BAND': 1,
        'Z_FACTOR': 1,
        'AZIMUTH': 315,
        'V_ANGLE': 45,
        'OUTPUT': '../data/processed/hillshade.tif'
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
